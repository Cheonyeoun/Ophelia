import 'dart:io';

import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:sqlite3/common.dart' show SqliteException;

import '../../core/domain/local_file_source_port.dart';
import '../../core/domain/track.dart';
import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../local_db/database.dart';

/// Real [LocalFileSourcePort] adapter: `package:file_picker` for the OS
/// folder/file picker, `dart:io` for scanning, and the same
/// [OpheliaDatabase] `DriftLibraryAdapter` uses (via the `linked_folders`
/// table) for remembering which folders are linked — see that port's own
/// doc comment for why this is a separate adapter class rather than an
/// extension of `DriftLibraryAdapter`.
///
/// ## Platform behavior — read before trusting this on a real device
///
/// **Android:** folder access goes through the Storage Access Framework
/// (SAF), the only way to browse an arbitrary user-chosen folder under
/// scoped storage. `file_picker` 12.2.0's *current, non-deprecated*
/// `getDirectoryPath()` returns a **best-effort file path** reconstructed
/// from the picked SAF tree URI (via the plugin's own internal
/// `getFullPathFromTreeUri` — found by reading its Kotlin source
/// directly, since this isn't documented in the package's README) and
/// does **not** call `takePersistableUriPermission`. In practice that
/// means: the returned path may not be directly readable on every
/// device/Android version, and even where it is today, the OS makes no
/// contractual promise of continued access after the app restarts,
/// since no persistable grant was ever taken.
///
/// Getting an actual persisted `content://` URI would require
/// `file_picker`'s own `@Deprecated('Use androidOptions instead.')`
/// `androidSafOptions` map parameter (undocumented keys `grant`/
/// `access`/`autoPersist` — again only known from its Kotlin source, not
/// from any published API doc) — and even then, re-scanning a
/// `content://` URI's contents later needs SAF tree traversal
/// (`DocumentFile`), which neither `file_picker` nor any other
/// currently-maintained package provides (the one that did,
/// `shared_storage`, is discontinued).
///
/// This adapter deliberately uses the plain, non-deprecated,
/// forward-compatible call instead of that deprecated escape hatch.
/// **Practical effect, needing real on-device verification this
/// codebase cannot substitute for:** linking a folder outside this app's
/// own storage may stop scanning successfully after an app restart or
/// device reboot, on some devices/Android versions but not necessarily
/// others.
///
/// **iOS:** there is no realistic equivalent of Android's SAF for
/// recursively scanning an arbitrary, user-picked folder under the app
/// sandbox. [pickFolder] on iOS picks individual audio files instead
/// (`file_picker`'s file picker, not its directory picker); [scanFolder]
/// then returns exactly those files, non-recursively, treating the
/// picked *set* as the "folder." Whether the underlying security-scoped
/// access continues to resolve across app restarts — likely to differ
/// between iCloud Drive/other-provider files and local-only ones — is
/// untested and needs real on-device verification too.
///
/// **Desktop:** [pickFolder]/[scanFolder] use plain `dart:io` directory
/// listing (Linux/macOS/Windows) — no SAF-style access model to work
/// around there.
///
/// **Web:** not supported. There's no meaningful "local device folder"
/// concept in a browser sandbox, and `file_picker` itself doesn't
/// support directory picking on web either way. Both methods fail fast
/// with [StorageFailure] instead of touching `file_picker` or `dart:io`.
///
/// **No tag reading:** track metadata is inferred from the file name and
/// parent folder name only (`title` = file name without extension,
/// `album` = parent folder name) — not real ID3/etc. tags. Adding a tag
/// reader is future work, not attempted here.
///
/// **Duration is always `0`** for the same reason: getting the real
/// duration needs either a tag reader or actually decoding the audio
/// (e.g. via `just_audio` once the engine loads it), neither of which
/// happens at scan time. `PlaybackScrubber` already treats a zero
/// duration as "nothing to show" rather than dividing by it, so this
/// doesn't crash anything -- but it does mean the scrubber and seek
/// controls are effectively non-functional for a local track until this
/// is addressed.
class LocalFileSourceAdapter implements LocalFileSourcePort {
  final OpheliaDatabase _db;

  LocalFileSourceAdapter(this._db);

  static const _audioExtensions = {
    '.mp3',
    '.m4a',
    '.aac',
    '.wav',
    '.flac',
    '.ogg',
    '.opus',
    '.wma',
  };

  /// Prefixes a track id produced by [scanFolder] with the file's own
  /// path, so [getSourcePath] can resolve it straight back without a
  /// separate persisted track registry — see that method.
  static const _idPrefix = 'local:';

  /// Prefixes the synthetic "folder" identifier used for a set of
  /// individually-picked iOS files (see the class doc comment) — the
  /// picked paths follow, newline-separated.
  static const _iosFileSetPrefix = 'ios-files:';

  @override
  Future<Result<String?, Failure>> pickFolder() async {
    if (kIsWeb) {
      return const Result.failure(
        StorageFailure('local folder browsing is not supported on web'),
      );
    }
    try {
      if (Platform.isIOS) {
        return await _pickIosFileSet();
      }
      final path = await fp.FilePicker.getDirectoryPath();
      return Result.success(path);
    } catch (e) {
      return Result.failure(StorageFailure('folder picker failed: $e'));
    }
  }

  Future<Result<String?, Failure>> _pickIosFileSet() async {
    // allowMultiple is deprecated in favor of the single-file pickFile(),
    // but there's no non-deprecated multi-pick alternative yet, and
    // picking one file at a time isn't a realistic substitute for
    // "linking a folder's worth of songs" -- see the class doc comment.
    final files = await fp.FilePicker.pickFiles(
      type: fp.FileType.audio,
      // ignore: deprecated_member_use
      allowMultiple: true,
    );
    final paths = [
      for (final file in files)
        if (file.path != null) file.path!,
    ];
    if (paths.isEmpty) return const Result.success(null);
    return Result.success('$_iosFileSetPrefix${paths.join('\n')}');
  }

  @override
  Future<Result<List<Track>, Failure>> scanFolder(String pathOrUri) async {
    if (kIsWeb) {
      return const Result.failure(
        StorageFailure('local folder browsing is not supported on web'),
      );
    }
    try {
      if (pathOrUri.startsWith(_iosFileSetPrefix)) {
        final paths = pathOrUri
            .substring(_iosFileSetPrefix.length)
            .split('\n')
            .where((path) => path.isNotEmpty);
        return Result.success([
          for (final path in paths) _trackForFile(File(path)),
        ]);
      }

      final dir = Directory(pathOrUri);
      if (!await dir.exists()) {
        return Result.failure(NotFoundFailure('no such folder: $pathOrUri'));
      }
      final tracks = <Track>[];
      await _scanInto(dir, tracks, isTopLevel: true);
      return Result.success(tracks);
    } on FileSystemException catch (e) {
      return Result.failure(StorageFailure(e.message));
    } catch (e) {
      return Result.failure(StorageFailure(e.toString()));
    }
  }

  /// Walks [dir] for audio files, recursing into subfolders one level at
  /// a time (rather than a single `dir.list(recursive: true)` stream) so
  /// that a subfolder this app can't actually read -- a real risk given
  /// the Android SAF path-persistence uncertainty documented on this
  /// class -- is skipped instead of failing the *entire* scan and
  /// discarding tracks already found in perfectly fine sibling folders.
  ///
  /// [isTopLevel] is the one exception: if the folder [scanFolder] was
  /// asked to scan can't be read at all, that's a real failure the
  /// caller needs to see, not a silently empty track list that would
  /// read as "no audio files" instead of "couldn't access this folder".
  Future<void> _scanInto(
    Directory dir,
    List<Track> tracks, {
    bool isTopLevel = false,
  }) async {
    List<FileSystemEntity> entities;
    try {
      entities = await dir.list(followLinks: false).toList();
    } on FileSystemException {
      if (isTopLevel) rethrow;
      return;
    }
    for (final entity in entities) {
      if (entity is Directory) {
        await _scanInto(entity, tracks);
      } else if (entity is File && _isAudioFile(entity.path)) {
        tracks.add(_trackForFile(entity));
      }
    }
  }

  bool _isAudioFile(String path) =>
      _audioExtensions.contains(p.extension(path).toLowerCase());

  Track _trackForFile(File file) => Track(
        id: '$_idPrefix${file.path}',
        title: p.basenameWithoutExtension(file.path),
        artist: 'Unknown artist',
        album: p.basename(file.parent.path),
        durationMs: 0,
        sourceType: TrackSourceType.local,
      );

  @override
  Future<Result<void, Failure>> linkFolder(String pathOrUri) async {
    try {
      await _db
          .into(_db.linkedFolders)
          .insertOnConflictUpdate(
            LinkedFoldersCompanion.insert(
              path: pathOrUri,
              linkedAt: DateTime.now(),
            ),
          );
      return const Result.success(null);
    } on SqliteException catch (e) {
      return Result.failure(StorageFailure(e.message));
    }
  }

  @override
  Future<Result<List<String>, Failure>> getLinkedFolders() async {
    try {
      final rows = await _db.select(_db.linkedFolders).get();
      return Result.success([for (final row in rows) row.path]);
    } on SqliteException catch (e) {
      return Result.failure(StorageFailure(e.message));
    }
  }

  @override
  Future<Result<void, Failure>> removeLinkedFolder(String pathOrUri) async {
    try {
      final deletedCount = await (_db.delete(
        _db.linkedFolders,
      )..where((f) => f.path.equals(pathOrUri))).go();
      if (deletedCount == 0) {
        return Result.failure(
          NotFoundFailure('folder not linked: $pathOrUri'),
        );
      }
      return const Result.success(null);
    } on SqliteException catch (e) {
      return Result.failure(StorageFailure(e.message));
    }
  }

  @override
  Future<Result<String, Failure>> getSourcePath(String trackId) async {
    if (!trackId.startsWith(_idPrefix)) {
      return Result.failure(NotFoundFailure('not a local track id: $trackId'));
    }
    return Result.success(trackId.substring(_idPrefix.length));
  }
}

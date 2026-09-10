import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:ophelia/core/domain/track.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/data/local_db/database.dart';
import 'package:ophelia/data/local_files/local_file_source_adapter.dart';

import '../../support/result_test_helpers.dart';

/// Covers everything [LocalFileSourceAdapter] can be exercised for
/// without a real device: [LocalFileSourceAdapter.scanFolder] against a
/// real temporary directory (plain `dart:io`, no platform plugin
/// involved), the linked-folders bookkeeping against a real in-memory
/// database (same pattern as `drift_library_adapter_test.dart`), and
/// [LocalFileSourceAdapter.getSourcePath]'s pure id-parsing logic.
///
/// Deliberately **not** covered: [LocalFileSourceAdapter.pickFolder].
/// It calls into `package:file_picker`'s static `FilePicker` methods,
/// which delegate to `FilePickerPlatform.instance` -- a real platform
/// plugin registered per-platform (Android/iOS/desktop native code) that
/// simply doesn't exist in `flutter test`'s Dart-VM test harness. There
/// is no meaningful way to fake "the OS folder picker returned this"
/// without also faking away the exact thing this method exists to do.
/// Whether the folder picker actually opens, and whether a folder
/// picked on a real device keeps scanning successfully after an app
/// restart (see the class's own doc comment on Android SAF/iOS sandbox
/// limitations), can only be verified by running the app for real
/// (`flutter run` on a device or emulator) -- not something to fake a
/// passing test for.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  // Not covered below: `_scanInto`'s tolerance for a nested subfolder
  // that can't be read (see the adapter's own doc comment on Android SAF
  // path-persistence uncertainty). Reliably inducing a real permission
  // error on a subdirectory is OS-specific (chmod semantics differ, and
  // don't reliably restrict directory listing on Windows at all), so
  // there's no portable, deterministic way to exercise that exact path
  // in an automated test -- flagging this rather than skipping it
  // silently, same as `pickFolder` below.
  group('scanFolder', () {
    late Directory tempDir;
    late OpheliaDatabase database;
    late LocalFileSourceAdapter adapter;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('ophelia_scan_test');
      database = OpheliaDatabase(NativeDatabase.memory());
      adapter = LocalFileSourceAdapter(database);
    });

    tearDown(() async {
      await database.close();
      await tempDir.delete(recursive: true);
    });

    test(
      'finds audio files by extension, ignoring non-audio files, and '
      'returns them as sourceType: local tracks',
      () async {
        final songPath = p.join(tempDir.path, 'song.mp3');
        await File(songPath).create();
        await File(p.join(tempDir.path, 'cover.jpg')).create();
        await File(p.join(tempDir.path, 'notes.txt')).create();

        final tracks = unwrapValue(await adapter.scanFolder(tempDir.path));

        expect(tracks, hasLength(1));
        expect(tracks.single.title, 'song');
        expect(tracks.single.sourceType, TrackSourceType.local);
        expect(tracks.single.id, 'local:$songPath');
      },
    );

    test('scans nested subfolders recursively', () async {
      final subDir = Directory(p.join(tempDir.path, 'Album'))..createSync();
      await File(p.join(subDir.path, 'track1.flac')).create();
      await File(p.join(subDir.path, 'track2.ogg')).create();

      final tracks = unwrapValue(await adapter.scanFolder(tempDir.path));

      expect(tracks, hasLength(2));
      expect(tracks.map((t) => t.album), everyElement('Album'));
    });

    test('uses the parent folder name as the album', () async {
      final subDir = Directory(p.join(tempDir.path, 'My Album'))
        ..createSync();
      await File(p.join(subDir.path, 'song.wav')).create();

      final tracks = unwrapValue(await adapter.scanFolder(tempDir.path));

      expect(tracks.single.album, 'My Album');
    });

    test('fails with NotFoundFailure for a folder that does not exist', () async {
      final failure = unwrapFailure(
        await adapter.scanFolder(p.join(tempDir.path, 'does-not-exist')),
      );

      expect(failure, isA<NotFoundFailure>());
    });

    test('returns an empty list for a folder with no audio files', () async {
      await File(p.join(tempDir.path, 'readme.txt')).create();

      final tracks = unwrapValue(await adapter.scanFolder(tempDir.path));

      expect(tracks, isEmpty);
    });

    test(
      'recognizes voice/call-recorder formats (.amr, .3gp), not just '
      'typical music formats -- a real folder full of these used to scan '
      'clean and report "no audio files found"',
      () async {
        await File(p.join(tempDir.path, 'memo.amr')).create();
        await File(p.join(tempDir.path, 'call.3gp')).create();

        final tracks = unwrapValue(await adapter.scanFolder(tempDir.path));

        expect(tracks.map((t) => t.title), containsAll(['memo', 'call']));
      },
    );
  });

  group('scanFolder permission handling', () {
    late Directory tempDir;
    late OpheliaDatabase database;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('ophelia_scan_test');
      database = OpheliaDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
      await tempDir.delete(recursive: true);
    });

    test(
      'fails with PermissionFailure, not an empty success, when the '
      'injected permission check reports denial -- a denied permission '
      'must surface as a real failure, never look like "no audio files '
      'here"',
      () async {
        await File(p.join(tempDir.path, 'song.mp3')).create();
        final adapter = LocalFileSourceAdapter(
          database,
          ensureAudioPermission: () async => false,
        );

        final failure = unwrapFailure(await adapter.scanFolder(tempDir.path));

        expect(failure, isA<PermissionFailure>());
      },
    );

    test(
      'scans normally once the injected permission check reports granted',
      () async {
        await File(p.join(tempDir.path, 'song.mp3')).create();
        final adapter = LocalFileSourceAdapter(
          database,
          ensureAudioPermission: () async => true,
        );

        final tracks = unwrapValue(await adapter.scanFolder(tempDir.path));

        expect(tracks, hasLength(1));
      },
    );

    test(
      'pickFolder fails with PermissionFailure when the injected '
      'permission check reports denial, without ever reaching the '
      'platform folder picker',
      () async {
        final adapter = LocalFileSourceAdapter(
          database,
          ensureAudioPermission: () async => false,
        );

        final failure = unwrapFailure(await adapter.pickFolder());

        expect(failure, isA<PermissionFailure>());
      },
    );
  });

  group('linked folders', () {
    late OpheliaDatabase database;
    late LocalFileSourceAdapter adapter;

    setUp(() {
      database = OpheliaDatabase(NativeDatabase.memory());
      adapter = LocalFileSourceAdapter(database);
    });

    tearDown(() => database.close());

    test('getLinkedFolders is empty against a fresh database', () async {
      expect(unwrapValue(await adapter.getLinkedFolders()), isEmpty);
    });

    test('linkFolder makes a folder show up in getLinkedFolders', () async {
      unwrapValue(await adapter.linkFolder('/music'));

      expect(unwrapValue(await adapter.getLinkedFolders()), ['/music']);
    });

    test('linkFolder is idempotent -- linking the same path twice does '
        'not duplicate it', () async {
      unwrapValue(await adapter.linkFolder('/music'));
      unwrapValue(await adapter.linkFolder('/music'));

      expect(unwrapValue(await adapter.getLinkedFolders()), ['/music']);
    });

    test('removeLinkedFolder removes a linked folder', () async {
      await adapter.linkFolder('/music');

      unwrapValue(await adapter.removeLinkedFolder('/music'));

      expect(unwrapValue(await adapter.getLinkedFolders()), isEmpty);
    });

    test(
      'removeLinkedFolder fails with NotFoundFailure for a folder that '
      'was never linked',
      () async {
        final failure = unwrapFailure(
          await adapter.removeLinkedFolder('/never-linked'),
        );

        expect(failure, isA<NotFoundFailure>());
      },
    );
  });

  group('getSourcePath', () {
    late OpheliaDatabase database;
    late LocalFileSourceAdapter adapter;

    setUp(() {
      database = OpheliaDatabase(NativeDatabase.memory());
      adapter = LocalFileSourceAdapter(database);
    });

    tearDown(() => database.close());

    test('resolves a track id produced by scanFolder back to its path', () async {
      final path = unwrapValue(
        await adapter.getSourcePath('local:/music/song.mp3'),
      );

      expect(path, '/music/song.mp3');
    });

    test(
      'fails with NotFoundFailure for an id this adapter did not produce',
      () async {
        final failure = unwrapFailure(
          await adapter.getSourcePath('t1'),
        );

        expect(failure, isA<NotFoundFailure>());
      },
    );
  });
}

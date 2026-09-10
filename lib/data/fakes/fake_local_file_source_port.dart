import '../../core/domain/local_file_source_port.dart';
import '../../core/domain/track.dart';
import '../../core/error/failure.dart';
import '../../core/error/result.dart';

/// **Temporary, UI-development-only fake — not a production adapter.**
///
/// In-memory stand-in for [LocalFileSourcePort]: no real folder picker,
/// no real filesystem access — [nextPickedFolder] stands in for whatever
/// the OS picker would have returned, and [tracksByFolder] stands in for
/// what a real scan of that folder would find.
class FakeLocalFileSourcePort implements LocalFileSourcePort {
  final List<String> _linkedFolders;
  final Map<String, List<Track>> _tracksByFolder;

  /// What [pickFolder] returns next — set this before calling it to
  /// simulate the user picking a folder, or leave it `null` to simulate
  /// cancelling the picker.
  String? nextPickedFolder;

  FakeLocalFileSourcePort({
    List<String>? linkedFolders,
    Map<String, List<Track>>? tracksByFolder,
    this.nextPickedFolder,
  })  : _linkedFolders = List.of(linkedFolders ?? const []),
        _tracksByFolder = Map.of(tracksByFolder ?? const {});

  @override
  Future<Result<String?, Failure>> pickFolder() async {
    return Result.success(nextPickedFolder);
  }

  @override
  Future<Result<List<Track>, Failure>> scanFolder(String pathOrUri) async {
    final tracks = _tracksByFolder[pathOrUri];
    if (tracks == null) {
      return Result.failure(NotFoundFailure('no such folder: $pathOrUri'));
    }
    return Result.success(List.unmodifiable(tracks));
  }

  @override
  Future<Result<void, Failure>> linkFolder(String pathOrUri) async {
    if (!_linkedFolders.contains(pathOrUri)) {
      _linkedFolders.add(pathOrUri);
    }
    return const Result.success(null);
  }

  @override
  Future<Result<List<String>, Failure>> getLinkedFolders() async {
    return Result.success(List.unmodifiable(_linkedFolders));
  }

  @override
  Future<Result<void, Failure>> removeLinkedFolder(String pathOrUri) async {
    final removed = _linkedFolders.remove(pathOrUri);
    if (!removed) {
      return Result.failure(
        NotFoundFailure('folder not linked: $pathOrUri'),
      );
    }
    return const Result.success(null);
  }

  @override
  Future<Result<String, Failure>> getSourcePath(String trackId) async {
    for (final tracks in _tracksByFolder.values) {
      for (final track in tracks) {
        if (track.id == trackId) {
          return Result.success('/fake-local/$trackId');
        }
      }
    }
    return Result.failure(NotFoundFailure('no local track with id $trackId'));
  }

  /// Track ids [sourceExists] should report as missing — set this to
  /// simulate a linked folder's file having been deleted/moved since it
  /// was last scanned. Everything else this fake still knows about
  /// (see [getSourcePath]) reports as existing.
  final Set<String> missingTrackIds = {};

  @override
  Future<Result<bool, Failure>> sourceExists(String trackId) async {
    if (missingTrackIds.contains(trackId)) return const Result.success(false);
    final pathResult = await getSourcePath(trackId);
    return switch (pathResult) {
      Success() => const Result.success(true),
      ResultFailure() => const Result.success(false),
    };
  }
}

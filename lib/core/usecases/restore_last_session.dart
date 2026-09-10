import '../domain/download_port.dart';
import '../domain/local_file_source_port.dart';
import '../domain/local_library_port.dart';
import '../domain/playback_session_snapshot.dart';
import '../domain/track.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Run once at app startup to bring back whatever was playing last time,
/// paused at the position it was left at (see
/// features/playback_ui/playback_controller.dart's `restoreSession` — this
/// use case only decides *whether* there's a valid session to restore, not
/// how the UI/engine reflect it).
///
/// A track from a linked local folder may no longer be reachable by the
/// time the app restarts — the folder could have been unlinked, moved, or
/// (for a removable folder) simply not mounted yet — so this checks
/// [LocalFileSourcePort.sourceExists] before handing the snapshot back,
/// and a downloaded track's [DownloadPort.isDownloaded] similarly. A
/// missing source fails gracefully: this returns `Success(null)` (nothing
/// to restore), never a crash or a mini-player pointed at a file that
/// isn't there. A streamed track's source isn't checked at all -- the
/// media API is the one place that could tell, and doing that check is no
/// different from just trying to play it, which `PlaybackController`
/// already handles failing gracefully.
class RestoreLastSession {
  final LocalLibraryPort library;
  final LocalFileSourcePort localFileSource;
  final DownloadPort downloads;

  RestoreLastSession(this.library, this.localFileSource, this.downloads);

  Future<Result<PlaybackSessionSnapshot?, Failure>> call() async {
    final result = await library.getLastPlaybackState();
    final PlaybackSessionSnapshot? snapshot;
    switch (result) {
      case Success(value: final v):
        snapshot = v;
      case ResultFailure(failure: final f):
        return Result.failure(f);
    }
    if (snapshot == null) return const Result.success(null);

    if (!await _sourceStillAvailable(snapshot.currentTrack)) {
      return const Result.success(null);
    }
    return Result.success(snapshot);
  }

  Future<bool> _sourceStillAvailable(Track track) async {
    switch (track.sourceType) {
      case TrackSourceType.local:
        final result = await localFileSource.sourceExists(track.id);
        return switch (result) {
          Success(value: final exists) => exists,
          ResultFailure() => false,
        };
      case TrackSourceType.downloaded:
        final result = await downloads.isDownloaded(track.id);
        return switch (result) {
          Success(value: final isDownloaded) => isDownloaded,
          ResultFailure() => false,
        };
      case TrackSourceType.streamed:
        return true;
    }
  }
}

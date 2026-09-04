import '../domain/download_port.dart';
import '../domain/media_source_port.dart';
import '../domain/playback_engine_port.dart';
import '../domain/track.dart';
import '../error/failure.dart';
import '../error/result.dart';
import 'listening_session.dart';

/// Plays [track] from its local copy if downloaded, otherwise streams it —
/// the "download-first, stream-fallback" flow (docs/architecture.md
/// §3.2) — then starts tracking its listening time.
///
/// When [queue] is given, it becomes the engine's active queue — e.g. the
/// track list the caller played this track from — so skipNext/
/// skipPrevious (and shuffle/repeat) have somewhere to operate; otherwise
/// the queue is just [track] on its own. [queueIndex] is [track]'s
/// position within that queue, passed straight through to
/// `PlaybackEnginePort.play` (see playback_engine_port.dart for why this
/// is explicit rather than searched for).
///
/// The queue isn't committed to the engine until the source has resolved
/// — a failure before then (e.g. the track isn't downloaded and streaming
/// fails) never touches the engine at all. Once the queue *is* committed,
/// the engine needs it set before [PlaybackEnginePort.play] can position
/// itself correctly, so a failure from `play` itself is repaired by
/// restoring the engine's full prior navigation state (queue, current
/// index, and shuffle history together — see
/// `PlaybackEnginePort.captureNavigationState`) — a failed play must
/// never leave the engine navigating state the UI never showed.
///
/// This does not finalize any track that was already playing — only
/// `PauseTrack`, `SkipNext`, and `SkipPrevious` do that (see
/// listening_session.dart). Calling `PlayTrack` again for a different
/// track while one is already playing, without going through skip,
/// silently drops that track's partial listening time; not solved here.
class PlayTrack {
  final PlaybackEnginePort playback;
  final MediaSourcePort mediaSource;
  final DownloadPort downloads;
  final ListeningSession session;

  PlayTrack(this.playback, this.mediaSource, this.downloads, this.session);

  Future<Result<void, Failure>> call(
    Track track, {
    List<Track>? queue,
    int queueIndex = 0,
  }) async {
    final isDownloadedResult = await downloads.isDownloaded(track.id);
    final bool isDownloaded;
    switch (isDownloadedResult) {
      case Success(value: final v):
        isDownloaded = v;
      case ResultFailure(failure: final f):
        return Result.failure(f);
    }

    final sourceResult = isDownloaded
        ? await downloads.getLocalPath(track.id)
        : await mediaSource.getStreamUrl(track.id);
    final String source;
    switch (sourceResult) {
      case Success(value: final v):
        source = v;
      case ResultFailure(failure: final f):
        return Result.failure(f);
    }

    final priorState = playback.captureNavigationState();
    final setQueueResult = await playback.setQueue(queue ?? [track]);
    switch (setQueueResult) {
      case Success():
        break;
      case ResultFailure(failure: final f):
        return Result.failure(f);
    }

    final playResult = await playback.play(
      track,
      source,
      queueIndex: queueIndex,
    );
    switch (playResult) {
      case Success():
        break;
      case ResultFailure(failure: final f):
        await playback.restoreNavigationState(priorState);
        return Result.failure(f);
    }

    session.start(track.id);
    return const Result.success(null);
  }
}

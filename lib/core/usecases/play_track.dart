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

  Future<Result<void, Failure>> call(Track track) async {
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

    final playResult = await playback.play(track, source);
    switch (playResult) {
      case Success():
        break;
      case ResultFailure(failure: final f):
        return Result.failure(f);
    }

    session.start(track.id);
    return const Result.success(null);
  }
}

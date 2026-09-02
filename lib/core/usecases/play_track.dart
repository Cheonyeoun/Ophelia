import '../domain/download_port.dart';
import '../domain/listening_event.dart';
import '../domain/local_library_port.dart';
import '../domain/media_source_port.dart';
import '../domain/playback_engine_port.dart';
import '../domain/track.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Plays [track] from its local copy if downloaded, otherwise streams it —
/// the "download-first, stream-fallback" flow (docs/architecture.md
/// §3.2) — then records a listening event.
class PlayTrack {
  final PlaybackEnginePort playback;
  final MediaSourcePort mediaSource;
  final DownloadPort downloads;
  final LocalLibraryPort library;

  PlayTrack(this.playback, this.mediaSource, this.downloads, this.library);

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

    return library.recordListeningEvent(
      ListeningEvent(trackId: track.id, playedAt: DateTime.now(), msPlayed: 0),
    );
  }
}

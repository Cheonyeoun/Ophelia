import '../domain/media_source_port.dart';
import '../domain/playback_engine_port.dart';
import '../domain/playlist.dart';
import '../domain/track.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Resolves a [Playlist]'s ordered track ids to full [Track] entities and
/// loads them into the playback queue, returning the resolved tracks so
/// callers (e.g. the presentation layer, to know what's now queued) don't
/// have to re-resolve them separately.
class BuildQueue {
  final MediaSourcePort mediaSource;
  final PlaybackEnginePort playback;

  BuildQueue(this.mediaSource, this.playback);

  Future<Result<List<Track>, Failure>> call(Playlist playlist) async {
    final tracks = <Track>[];
    for (final trackId in playlist.trackIds) {
      final result = await mediaSource.getTrackMetadata(trackId);
      switch (result) {
        case Success(value: final track):
          tracks.add(track);
        case ResultFailure(failure: final f):
          return Result.failure(f);
      }
    }
    final setQueueResult = await playback.setQueue(tracks);
    switch (setQueueResult) {
      case Success():
        return Result.success(tracks);
      case ResultFailure(failure: final f):
        return Result.failure(f);
    }
  }
}

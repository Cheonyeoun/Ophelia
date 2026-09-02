import '../domain/media_source_port.dart';
import '../domain/playback_engine_port.dart';
import '../domain/playlist.dart';
import '../domain/track.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Resolves a [Playlist]'s ordered track ids to full [Track] entities and
/// loads them into the playback queue.
class BuildQueue {
  final MediaSourcePort mediaSource;
  final PlaybackEnginePort playback;

  BuildQueue(this.mediaSource, this.playback);

  Future<Result<void, Failure>> call(Playlist playlist) async {
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
    return playback.setQueue(tracks);
  }
}

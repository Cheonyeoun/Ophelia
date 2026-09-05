import '../domain/media_source_port.dart';
import '../domain/playlist.dart';
import '../domain/track.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Resolves [playlist]'s ordered track ids to full [Track] entities, for
/// the playlist detail screen to display. Unlike `BuildQueue`, this never
/// touches the playback engine — it's a read, not a "play this playlist"
/// action; the screen plays an individual track itself (via
/// `PlaybackController.play`) once the user taps one.
class GetPlaylistTracks {
  final MediaSourcePort mediaSource;

  GetPlaylistTracks(this.mediaSource);

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
    return Result.success(tracks);
  }
}

import '../domain/media_source_port.dart';
import '../domain/track.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Every track credited to [artistName], for the artist detail screen.
class GetArtistTracks {
  final MediaSourcePort mediaSource;

  GetArtistTracks(this.mediaSource);

  Future<Result<List<Track>, Failure>> call(String artistName) =>
      mediaSource.getTracksByArtist(artistName);
}

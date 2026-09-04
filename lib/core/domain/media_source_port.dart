import '../error/failure.dart';
import '../error/result.dart';
import 'track.dart';

/// Port for the remote media catalog: search, stream URLs, metadata, and
/// cover art. Implemented by an adapter under lib/data/media_source/ (see
/// docs/architecture.md §3.1, §3.3) — the domain only depends on this
/// interface.
abstract interface class MediaSourcePort {
  Future<Result<List<Track>, Failure>> search(String query);

  /// Every track credited to [artistName] — an exact match against
  /// [Track.artist], not the fuzzy substring matching [search] does.
  Future<Result<List<Track>, Failure>> getTracksByArtist(String artistName);

  Future<Result<String, Failure>> getStreamUrl(String trackId);

  Future<Result<Track, Failure>> getTrackMetadata(String trackId);

  Future<Result<String, Failure>> getCoverArt(String trackId);
}

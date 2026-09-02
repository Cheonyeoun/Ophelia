import '../../core/domain/media_source_port.dart';
import '../../core/domain/track.dart';
import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import 'sample_data.dart';

/// **Temporary, UI-development-only fake — not a production adapter.**
///
/// In-memory stand-in for [MediaSourcePort], seeded with [sampleTracks],
/// so screens have believable catalog data before a real adapter exists
/// under lib/data/media_source/.
class FakeMediaSourcePort implements MediaSourcePort {
  final List<Track> tracks;

  FakeMediaSourcePort({this.tracks = sampleTracks});

  @override
  Future<Result<List<Track>, Failure>> search(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return Result.success(List.unmodifiable(tracks));
    }
    final matches = tracks.where((track) {
      return track.title.toLowerCase().contains(normalized) ||
          track.artist.toLowerCase().contains(normalized) ||
          track.album.toLowerCase().contains(normalized);
    }).toList();
    return Result.success(matches);
  }

  @override
  Future<Result<String, Failure>> getStreamUrl(String trackId) async {
    final exists = tracks.any((track) => track.id == trackId);
    if (!exists) {
      return Result.failure(NotFoundFailure('no track with id $trackId'));
    }
    return Result.success('https://stream.ophelia.fake/$trackId');
  }

  @override
  Future<Result<Track, Failure>> getTrackMetadata(String trackId) async {
    for (final track in tracks) {
      if (track.id == trackId) return Result.success(track);
    }
    return Result.failure(NotFoundFailure('no track with id $trackId'));
  }

  @override
  Future<Result<String, Failure>> getCoverArt(String trackId) async {
    for (final track in tracks) {
      if (track.id != trackId) continue;
      final path = track.coverArtPath;
      if (path == null) {
        return Result.failure(NotFoundFailure('no cover art for $trackId'));
      }
      return Result.success(path);
    }
    return Result.failure(NotFoundFailure('no track with id $trackId'));
  }
}

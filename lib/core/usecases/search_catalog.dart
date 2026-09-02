import '../domain/media_source_port.dart';
import '../domain/track.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Searches the remote catalog for tracks matching [query].
class SearchCatalog {
  final MediaSourcePort mediaSource;

  SearchCatalog(this.mediaSource);

  Future<Result<List<Track>, Failure>> call(String query) =>
      mediaSource.search(query);
}

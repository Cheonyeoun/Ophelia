import '../domain/local_file_source_port.dart';
import '../domain/track.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Scans a linked (or just-picked) folder for playable tracks — a thin
/// wrapper around [LocalFileSourcePort.scanFolder] so the presentation
/// layer depends on a use case here rather than the port directly (see
/// docs/architecture.md §3.4), the same way `SeekBy`/`SeekTo` wrap a
/// single port call each.
class ScanLocalFolder {
  final LocalFileSourcePort localFileSource;

  ScanLocalFolder(this.localFileSource);

  Future<Result<List<Track>, Failure>> call(String pathOrUri) =>
      localFileSource.scanFolder(pathOrUri);
}

import '../domain/local_file_source_port.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Removes a previously-linked folder — a thin wrapper around
/// [LocalFileSourcePort.removeLinkedFolder] so the presentation layer
/// depends on a use case here rather than the port directly (see
/// docs/architecture.md §3.4).
class UnlinkFolder {
  final LocalFileSourcePort localFileSource;

  UnlinkFolder(this.localFileSource);

  Future<Result<void, Failure>> call(String pathOrUri) =>
      localFileSource.removeLinkedFolder(pathOrUri);
}

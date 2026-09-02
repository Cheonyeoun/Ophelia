import '../domain/download_port.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Deletes the local copy of a downloaded track.
class RemoveDownload {
  final DownloadPort downloads;

  RemoveDownload(this.downloads);

  Future<Result<void, Failure>> call(String trackId) =>
      downloads.deleteDownload(trackId);
}

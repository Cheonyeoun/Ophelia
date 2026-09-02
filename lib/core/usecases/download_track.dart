import '../domain/download_port.dart';
import '../domain/download_record.dart';
import '../domain/track.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Downloads [track] for offline playback.
class DownloadTrack {
  final DownloadPort downloads;

  DownloadTrack(this.downloads);

  Future<Result<DownloadRecord, Failure>> call(Track track) =>
      downloads.download(track);
}

import '../error/failure.dart';
import '../error/result.dart';
import 'download_record.dart';
import 'track.dart';

/// Port for downloading tracks for offline playback and tracking what has
/// been downloaded (see Docs/Architecture.md §3.1). Implemented by an
/// adapter under lib/data/downloads/ (see §3.3) — the domain only depends
/// on this interface.
abstract interface class DownloadPort {
  Future<Result<DownloadRecord, Failure>> download(Track track);

  Future<Result<void, Failure>> deleteDownload(String trackId);

  Future<Result<bool, Failure>> isDownloaded(String trackId);
}

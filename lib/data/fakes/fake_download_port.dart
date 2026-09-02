import '../../core/domain/download_port.dart';
import '../../core/domain/download_record.dart';
import '../../core/domain/track.dart';
import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import 'sample_data.dart';

/// **Temporary, UI-development-only fake — not a production adapter.**
///
/// In-memory stand-in for [DownloadPort], seeded with
/// [sampleDownloadRecords], so screens have believable downloaded-track
/// data before a real adapter exists under lib/data/downloads/.
class FakeDownloadPort implements DownloadPort {
  final Map<String, DownloadRecord> _recordsByTrackId;

  FakeDownloadPort({List<DownloadRecord>? seed})
      : _recordsByTrackId = {
          for (final record in seed ?? sampleDownloadRecords)
            record.trackId: record,
        };

  @override
  Future<Result<DownloadRecord, Failure>> download(Track track) async {
    final record = DownloadRecord(
      trackId: track.id,
      localPath: '/downloads/${track.id}.mp3',
      sizeBytes: track.durationMs * 700,
      downloadedAt: DateTime.now(),
    );
    _recordsByTrackId[track.id] = record;
    return Result.success(record);
  }

  @override
  Future<Result<void, Failure>> deleteDownload(String trackId) async {
    final removed = _recordsByTrackId.remove(trackId);
    if (removed == null) {
      return Result.failure(NotFoundFailure('track $trackId not downloaded'));
    }
    return const Result.success(null);
  }

  @override
  Future<Result<bool, Failure>> isDownloaded(String trackId) async {
    return Result.success(_recordsByTrackId.containsKey(trackId));
  }

  @override
  Future<Result<String, Failure>> getLocalPath(String trackId) async {
    final record = _recordsByTrackId[trackId];
    if (record == null) {
      return Result.failure(NotFoundFailure('track $trackId not downloaded'));
    }
    return Result.success(record.localPath);
  }
}

import 'package:test/test.dart';
import 'package:ophelia/core/domain/download_port.dart';
import 'package:ophelia/core/domain/download_record.dart';
import 'package:ophelia/core/domain/track.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/core/error/result.dart';

/// Minimal in-memory implementation used only to confirm the interface
/// shape is usable — this is not a real adapter (see
/// lib/data/downloads/, not yet written).
class _FakeDownloadPort implements DownloadPort {
  final Map<String, String> _localPathsByTrackId;

  _FakeDownloadPort(this._localPathsByTrackId);

  @override
  Future<Result<DownloadRecord, Failure>> download(Track track) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Failure>> deleteDownload(String trackId) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<bool, Failure>> isDownloaded(String trackId) async {
    return Result.success(_localPathsByTrackId.containsKey(trackId));
  }

  @override
  Future<Result<String, Failure>> getLocalPath(String trackId) async {
    final path = _localPathsByTrackId[trackId];
    if (path == null) {
      return const Result.failure(NotFoundFailure('track not downloaded'));
    }
    return Result.success(path);
  }
}

void main() {
  test('getLocalPath resolves the stored path for a downloaded track',
      () async {
    final port = _FakeDownloadPort({'t1': '/downloads/t1.mp3'});

    final result = await port.getLocalPath('t1');

    final path = switch (result) {
      Success(value: final v) => v,
      ResultFailure() => fail('expected a Success case'),
    };
    expect(path, '/downloads/t1.mp3');
  });

  test(
    'getLocalPath returns a NotFoundFailure for a track that was never '
    'downloaded',
    () async {
      final port = _FakeDownloadPort({});

      final result = await port.getLocalPath('missing');

      final failure = switch (result) {
        Success() => fail('expected a ResultFailure case'),
        ResultFailure(failure: final f) => f,
      };
      expect(failure, isA<NotFoundFailure>());
    },
  );
}

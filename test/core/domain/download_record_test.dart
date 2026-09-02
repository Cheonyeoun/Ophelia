import 'package:test/test.dart';
import 'package:ophelia/core/domain/download_record.dart';

void main() {
  final downloadedAt = DateTime.utc(2026, 1, 1, 12);
  final record = DownloadRecord(
    trackId: 't1',
    localPath: '/downloads/t1.mp3',
    sizeBytes: 5242880,
    downloadedAt: downloadedAt,
  );

  test('construction exposes the given field values', () {
    expect(record.trackId, 't1');
    expect(record.localPath, '/downloads/t1.mp3');
    expect(record.sizeBytes, 5242880);
    expect(record.downloadedAt, downloadedAt);
  });

  test('two instances with the same values are equal', () {
    final other = DownloadRecord(
      trackId: 't1',
      localPath: '/downloads/t1.mp3',
      sizeBytes: 5242880,
      downloadedAt: downloadedAt,
    );

    expect(record, equals(other));
    expect(record.hashCode, equals(other.hashCode));
  });

  test('a differing field makes instances unequal', () {
    final other = DownloadRecord(
      trackId: 't1',
      localPath: '/downloads/t1.mp3',
      sizeBytes: 1000,
      downloadedAt: downloadedAt,
    );

    expect(record, isNot(equals(other)));
  });

  test('copyWith changes only the given field', () {
    final updated = record.copyWith(sizeBytes: 9999);

    expect(updated.sizeBytes, 9999);
    expect(updated.trackId, record.trackId);
    expect(updated.localPath, record.localPath);
    expect(updated.downloadedAt, record.downloadedAt);
  });
}

/// A track downloaded for offline playback. Immutable value type — no
/// Flutter, no package imports (see Docs/Architecture.md §3.1).
class DownloadRecord {
  final String trackId;
  final String localPath;
  final int sizeBytes;
  final DateTime downloadedAt;

  const DownloadRecord({
    required this.trackId,
    required this.localPath,
    required this.sizeBytes,
    required this.downloadedAt,
  });

  DownloadRecord copyWith({
    String? trackId,
    String? localPath,
    int? sizeBytes,
    DateTime? downloadedAt,
  }) {
    return DownloadRecord(
      trackId: trackId ?? this.trackId,
      localPath: localPath ?? this.localPath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadRecord &&
          runtimeType == other.runtimeType &&
          trackId == other.trackId &&
          localPath == other.localPath &&
          sizeBytes == other.sizeBytes &&
          downloadedAt == other.downloadedAt;

  @override
  int get hashCode =>
      Object.hash(trackId, localPath, sizeBytes, downloadedAt);
}

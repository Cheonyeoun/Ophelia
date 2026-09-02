/// Where the audio bytes for a [Track] come from.
enum TrackSourceType { streamed, local, downloaded }

/// A single playable song. Immutable value type — no Flutter, no package
/// imports (see Docs/Architecture.md §3.1).
class Track {
  final String id;
  final String title;
  final String artist;
  final String album;
  final int durationMs;
  final String? coverArtPath;
  final TrackSourceType sourceType;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.durationMs,
    this.coverArtPath,
    required this.sourceType,
  });

  Track copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    int? durationMs,
    String? coverArtPath,
    TrackSourceType? sourceType,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      coverArtPath: coverArtPath ?? this.coverArtPath,
      sourceType: sourceType ?? this.sourceType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Track &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          artist == other.artist &&
          album == other.album &&
          durationMs == other.durationMs &&
          coverArtPath == other.coverArtPath &&
          sourceType == other.sourceType;

  @override
  int get hashCode => Object.hash(
        id,
        title,
        artist,
        album,
        durationMs,
        coverArtPath,
        sourceType,
      );
}

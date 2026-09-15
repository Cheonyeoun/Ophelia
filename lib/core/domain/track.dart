/// Where the audio bytes for a [Track] come from.
enum TrackSourceType { streamed, local, downloaded }

/// [Track.artist] for a local-folder track (see `LocalFileSourceAdapter`'s
/// doc comment on why it has no real tag reader) -- shared, rather than a
/// literal duplicated at both the adapter that writes it and any screen
/// that wants to render a local track's metadata-less row differently
/// (see e.g. `LocalFilesScreen`), so the two can't quietly drift apart.
const unknownArtistPlaceholder = 'Unknown artist';

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

  /// Set [clearCoverArtPath] to clear [coverArtPath] to null — passing
  /// [coverArtPath] alone can't distinguish "leave unchanged" from "set to
  /// null".
  Track copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    int? durationMs,
    String? coverArtPath,
    bool clearCoverArtPath = false,
    TrackSourceType? sourceType,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      coverArtPath: clearCoverArtPath
          ? null
          : (coverArtPath ?? this.coverArtPath),
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

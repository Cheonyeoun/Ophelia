/// An album grouping of tracks. Immutable value type — no Flutter, no
/// package imports (see Docs/Architecture.md §3.1).
class Album {
  final String id;
  final String title;
  final String artist;
  final String? coverArtPath;

  const Album({
    required this.id,
    required this.title,
    required this.artist,
    this.coverArtPath,
  });

  /// Set [clearCoverArtPath] to clear [coverArtPath] to null — passing
  /// [coverArtPath] alone can't distinguish "leave unchanged" from "set to
  /// null".
  Album copyWith({
    String? id,
    String? title,
    String? artist,
    String? coverArtPath,
    bool clearCoverArtPath = false,
  }) {
    return Album(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      coverArtPath:
          clearCoverArtPath ? null : (coverArtPath ?? this.coverArtPath),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Album &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          artist == other.artist &&
          coverArtPath == other.coverArtPath;

  @override
  int get hashCode => Object.hash(id, title, artist, coverArtPath);
}

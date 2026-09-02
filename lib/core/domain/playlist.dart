/// A user-created, ordered collection of track ids. Immutable value type —
/// no Flutter, no package imports (see Docs/Architecture.md §3.1).
class Playlist {
  final String id;
  final String name;
  final List<String> trackIds;

  /// Defensively copies [trackIds] into an unmodifiable list so mutating
  /// the caller's list after construction can't change this instance.
  Playlist({
    required this.id,
    required this.name,
    required List<String> trackIds,
  }) : trackIds = List.unmodifiable(trackIds);

  Playlist copyWith({
    String? id,
    String? name,
    List<String>? trackIds,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      trackIds: trackIds ?? this.trackIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Playlist &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          _listEquals(trackIds, other.trackIds);

  @override
  int get hashCode => Object.hash(id, name, Object.hashAll(trackIds));
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

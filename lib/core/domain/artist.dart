/// A recording artist. Immutable value type — no Flutter, no package
/// imports (see Docs/Architecture.md §3.1).
class Artist {
  final String id;
  final String name;

  const Artist({required this.id, required this.name});

  Artist copyWith({String? id, String? name}) {
    return Artist(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Artist &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, name);
}

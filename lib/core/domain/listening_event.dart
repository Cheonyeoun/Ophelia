/// One record of a track being played — raw data behind aggregates like
/// "top 5 this week". Immutable value type — no Flutter, no package
/// imports (see Docs/Architecture.md §3.1).
class ListeningEvent {
  final String trackId;
  final DateTime playedAt;
  final int msPlayed;

  const ListeningEvent({
    required this.trackId,
    required this.playedAt,
    required this.msPlayed,
  });

  ListeningEvent copyWith({
    String? trackId,
    DateTime? playedAt,
    int? msPlayed,
  }) {
    return ListeningEvent(
      trackId: trackId ?? this.trackId,
      playedAt: playedAt ?? this.playedAt,
      msPlayed: msPlayed ?? this.msPlayed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListeningEvent &&
          runtimeType == other.runtimeType &&
          trackId == other.trackId &&
          playedAt == other.playedAt &&
          msPlayed == other.msPlayed;

  @override
  int get hashCode => Object.hash(trackId, playedAt, msPlayed);
}

import 'track.dart';

/// Everything needed to restore playback to where the user left off —
/// persisted by [LocalLibraryPort.saveLastPlaybackState] and read back by
/// [LocalLibraryPort.getLastPlaybackState] (see docs/architecture.md §5).
/// Deliberately self-contained (each [queue] entry is a full [Track], not
/// just an id) so restoring a session never depends on any other port
/// still being able to resolve those ids — the current track is always
/// `queue[queueIndex]`, not stored separately, so the two can never drift
/// apart from each other.
class PlaybackSessionSnapshot {
  final List<Track> queue;
  final int queueIndex;
  final Duration position;

  const PlaybackSessionSnapshot({
    required this.queue,
    required this.queueIndex,
    required this.position,
  });

  Track get currentTrack => queue[queueIndex];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaybackSessionSnapshot &&
          runtimeType == other.runtimeType &&
          queueIndex == other.queueIndex &&
          position == other.position &&
          _listEquals(queue, other.queue);

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(queue), queueIndex, position);
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

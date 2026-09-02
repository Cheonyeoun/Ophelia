import 'track.dart';

/// How the queue repeats once it reaches the end.
enum RepeatMode { off, one, all }

/// The current state of playback, shared by the Immersive and Everyday play
/// screens (see Docs/Architecture.md §7). Immutable value type — no
/// Flutter, no package imports (see §3.1); may reference other domain
/// entities.
class PlaybackState {
  final Track? currentTrack;
  final Duration position;
  final List<Track> queue;
  final bool isImmersive;
  final RepeatMode repeatMode;
  final bool shuffle;

  const PlaybackState({
    this.currentTrack,
    required this.position,
    required this.queue,
    required this.isImmersive,
    required this.repeatMode,
    required this.shuffle,
  });

  PlaybackState copyWith({
    Track? currentTrack,
    Duration? position,
    List<Track>? queue,
    bool? isImmersive,
    RepeatMode? repeatMode,
    bool? shuffle,
  }) {
    return PlaybackState(
      currentTrack: currentTrack ?? this.currentTrack,
      position: position ?? this.position,
      queue: queue ?? this.queue,
      isImmersive: isImmersive ?? this.isImmersive,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffle: shuffle ?? this.shuffle,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaybackState &&
          runtimeType == other.runtimeType &&
          currentTrack == other.currentTrack &&
          position == other.position &&
          _listEquals(queue, other.queue) &&
          isImmersive == other.isImmersive &&
          repeatMode == other.repeatMode &&
          shuffle == other.shuffle;

  @override
  int get hashCode => Object.hash(
        currentTrack,
        position,
        Object.hashAll(queue),
        isImmersive,
        repeatMode,
        shuffle,
      );
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

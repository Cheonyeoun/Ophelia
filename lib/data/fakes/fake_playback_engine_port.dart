import '../../core/domain/playback_engine_port.dart';
import '../../core/domain/track.dart';
import '../../core/error/failure.dart';
import '../../core/error/result.dart';

/// **Temporary, UI-development-only fake — not a production adapter.**
///
/// In-memory stand-in for [PlaybackEnginePort] that tracks the "playing"
/// track, position, and queue in memory instead of driving `just_audio` —
/// enough for screens (and tests) to exercise transport controls before a
/// real adapter exists under lib/playback/engine/.
class FakePlaybackEnginePort implements PlaybackEnginePort {
  Track? currentTrack;
  String? currentSourcePath;
  Duration position = Duration.zero;
  List<Track> queue = const [];
  bool isPlaying = false;

  /// Position of [currentTrack] within [queue] — the source of truth for
  /// skipNext/skipPrevious, set directly by [setQueue] and moved by ±1 on
  /// skip. Kept separate from matching on [currentTrack]'s id or value so
  /// duplicate tracks in the queue don't confuse navigation.
  int currentIndex = -1;

  @override
  Future<Result<void, Failure>> play(Track track, String sourcePath) async {
    currentTrack = track;
    currentSourcePath = sourcePath;
    position = Duration.zero;
    isPlaying = true;
    return const Result.success(null);
  }

  @override
  Future<Result<void, Failure>> pause() async {
    isPlaying = false;
    return const Result.success(null);
  }

  @override
  Future<Result<void, Failure>> seek(Duration position) async {
    this.position = position;
    return const Result.success(null);
  }

  @override
  Future<Result<void, Failure>> skipNext() async {
    if (currentIndex == -1 || currentIndex >= queue.length - 1) {
      return Result.failure(const NotFoundFailure('no next track'));
    }
    currentIndex++;
    _moveToCurrentIndex();
    return const Result.success(null);
  }

  @override
  Future<Result<void, Failure>> skipPrevious() async {
    if (currentIndex <= 0) {
      return Result.failure(const NotFoundFailure('no previous track'));
    }
    currentIndex--;
    _moveToCurrentIndex();
    return const Result.success(null);
  }

  @override
  Future<Result<void, Failure>> setQueue(List<Track> tracks) async {
    queue = List.unmodifiable(tracks);
    currentIndex = queue.isEmpty ? -1 : 0;
    return const Result.success(null);
  }

  void _moveToCurrentIndex() {
    final track = queue[currentIndex];
    currentTrack = track;
    // A placeholder path derived from the new track's id, just so this
    // fake's exposed state is never internally inconsistent (a
    // currentTrack whose currentSourcePath still points at the track it
    // replaced). A real adapter will need to resolve the actual
    // stream-vs-downloaded source on skip, the same way PlayTrack does
    // (see core/usecases/play_track.dart) — an open design question for
    // when that adapter is built, not solved here.
    currentSourcePath = '/fake-source/${track.id}';
    position = Duration.zero;
  }
}

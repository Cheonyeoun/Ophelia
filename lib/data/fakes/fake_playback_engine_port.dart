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
    final current = currentTrack;
    if (current == null || queue.isEmpty) {
      return Result.failure(const NotFoundFailure('no track to skip from'));
    }
    final index = queue.indexWhere((track) => track.id == current.id);
    if (index == -1 || index == queue.length - 1) {
      return Result.failure(const NotFoundFailure('no next track'));
    }
    currentTrack = queue[index + 1];
    position = Duration.zero;
    return const Result.success(null);
  }

  @override
  Future<Result<void, Failure>> skipPrevious() async {
    final current = currentTrack;
    if (current == null || queue.isEmpty) {
      return Result.failure(const NotFoundFailure('no track to skip from'));
    }
    final index = queue.indexWhere((track) => track.id == current.id);
    if (index <= 0) {
      return Result.failure(const NotFoundFailure('no previous track'));
    }
    currentTrack = queue[index - 1];
    position = Duration.zero;
    return const Result.success(null);
  }

  @override
  Future<Result<void, Failure>> setQueue(List<Track> tracks) async {
    queue = List.unmodifiable(tracks);
    return const Result.success(null);
  }
}

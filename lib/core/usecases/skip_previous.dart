import '../domain/playback_engine_port.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Skips to the previous track in the queue.
class SkipPrevious {
  final PlaybackEnginePort playback;

  SkipPrevious(this.playback);

  Future<Result<void, Failure>> call() => playback.skipPrevious();
}

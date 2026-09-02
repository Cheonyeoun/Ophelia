import '../domain/playback_engine_port.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Skips to the next track in the queue.
class SkipNext {
  final PlaybackEnginePort playback;

  SkipNext(this.playback);

  Future<Result<void, Failure>> call() => playback.skipNext();
}

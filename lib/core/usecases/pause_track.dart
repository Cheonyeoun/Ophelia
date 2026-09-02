import '../domain/playback_engine_port.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Pauses whatever is currently playing.
class PauseTrack {
  final PlaybackEnginePort playback;

  PauseTrack(this.playback);

  Future<Result<void, Failure>> call() => playback.pause();
}

import '../domain/playback_engine_port.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Seeks directly to an absolute [target] position (a negative [target]
/// is treated as zero). Unlike `SeekBy` (core/usecases/seek_by.dart), no
/// relative-offset computation is needed here since
/// [PlaybackEnginePort.seek] already takes an absolute position.
class SeekTo {
  final PlaybackEnginePort playback;

  SeekTo(this.playback);

  Future<Result<void, Failure>> call(Duration target) {
    return playback.seek(target < Duration.zero ? Duration.zero : target);
  }
}

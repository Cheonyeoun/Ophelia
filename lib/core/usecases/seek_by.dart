import '../domain/playback_engine_port.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Seeks by [offset] relative to [currentPosition] (a negative offset
/// seeks backward). Takes [currentPosition] as a parameter because
/// [PlaybackEnginePort] only exposes seeking to an absolute position, not
/// a "current position" query.
class SeekBy {
  final PlaybackEnginePort playback;

  SeekBy(this.playback);

  Future<Result<void, Failure>> call({
    required Duration currentPosition,
    required Duration offset,
  }) {
    final target = currentPosition + offset;
    return playback.seek(target < Duration.zero ? Duration.zero : target);
  }
}

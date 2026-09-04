import '../domain/playback_engine_port.dart';
import '../domain/playback_state.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Cycles repeat mode off -> all -> one -> off, telling the engine so it
/// can respect it when computing skipNext/skipPrevious's next index.
class ToggleRepeatMode {
  final PlaybackEnginePort playback;

  ToggleRepeatMode(this.playback);

  static const _cycle = [RepeatMode.off, RepeatMode.all, RepeatMode.one];

  /// The repeat mode [current] cycles to next. Pure and synchronous so a
  /// caller (e.g. `PlaybackController`) can compute the target value
  /// itself before firing off the async engine call, rather than deriving
  /// it from state that may be stale by the time an earlier in-flight
  /// toggle's `await` resolves — see app/playback_controller.dart's
  /// `toggleRepeatMode`.
  static RepeatMode next(RepeatMode current) =>
      _cycle[(_cycle.indexOf(current) + 1) % _cycle.length];

  Future<Result<PlaybackState, Failure>> call(PlaybackState state) async {
    final target = next(state.repeatMode);
    final result = await playback.setRepeatMode(target);
    switch (result) {
      case Success():
        return Result.success(state.copyWith(repeatMode: target));
      case ResultFailure(failure: final f):
        return Result.failure(f);
    }
  }
}

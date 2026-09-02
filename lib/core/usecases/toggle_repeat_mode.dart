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

  Future<Result<PlaybackState, Failure>> call(PlaybackState state) async {
    final next =
        _cycle[(_cycle.indexOf(state.repeatMode) + 1) % _cycle.length];
    final result = await playback.setRepeatMode(next);
    switch (result) {
      case Success():
        return Result.success(state.copyWith(repeatMode: next));
      case ResultFailure(failure: final f):
        return Result.failure(f);
    }
  }
}

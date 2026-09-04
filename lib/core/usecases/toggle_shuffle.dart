import '../domain/playback_engine_port.dart';
import '../domain/playback_state.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Toggles shuffle on/off, telling the engine so it can respect it when
/// computing skipNext/skipPrevious's next index (see
/// data/fakes/fake_playback_engine_port.dart for how the fake does this).
class ToggleShuffle {
  final PlaybackEnginePort playback;

  ToggleShuffle(this.playback);

  Future<Result<PlaybackState, Failure>> call(PlaybackState state) async {
    final enabled = !state.shuffle;
    final result = await playback.setShuffle(enabled);
    switch (result) {
      case Success():
        return Result.success(state.copyWith(shuffle: enabled));
      case ResultFailure(failure: final f):
        return Result.failure(f);
    }
  }
}

import 'package:test/test.dart';
import 'package:ophelia/core/domain/playback_state.dart';
import 'package:ophelia/core/usecases/toggle_repeat_mode.dart';
import 'package:ophelia/data/fakes/fake_playback_engine_port.dart';

import '../../support/result_test_helpers.dart';

void main() {
  PlaybackState stateWith(RepeatMode mode) => PlaybackState(
        position: Duration.zero,
        queue: const [],
        isImmersive: false,
        repeatMode: mode,
        shuffle: false,
      );

  test('cycles off -> all, and tells the engine', () async {
    final playback = FakePlaybackEnginePort();
    final toggleRepeatMode = ToggleRepeatMode(playback);

    final updated = unwrapValue(
      await toggleRepeatMode(stateWith(RepeatMode.off)),
    );

    expect(updated.repeatMode, RepeatMode.all);
    expect(playback.repeatMode, RepeatMode.all);
  });

  test('cycles all -> one', () async {
    final playback = FakePlaybackEnginePort();
    final toggleRepeatMode = ToggleRepeatMode(playback);

    final updated = unwrapValue(
      await toggleRepeatMode(stateWith(RepeatMode.all)),
    );

    expect(updated.repeatMode, RepeatMode.one);
  });

  test('cycles one -> off', () async {
    final playback = FakePlaybackEnginePort();
    final toggleRepeatMode = ToggleRepeatMode(playback);

    final updated = unwrapValue(
      await toggleRepeatMode(stateWith(RepeatMode.one)),
    );

    expect(updated.repeatMode, RepeatMode.off);
  });

  test('leaves other fields untouched', () async {
    final playback = FakePlaybackEnginePort();
    final toggleRepeatMode = ToggleRepeatMode(playback);
    final state = PlaybackState(
      position: const Duration(seconds: 9),
      queue: const [],
      isImmersive: true,
      repeatMode: RepeatMode.off,
      shuffle: true,
    );

    final updated = unwrapValue(await toggleRepeatMode(state));

    expect(updated.position, state.position);
    expect(updated.isImmersive, state.isImmersive);
    expect(updated.shuffle, state.shuffle);
  });
}

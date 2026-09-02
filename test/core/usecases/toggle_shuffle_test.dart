import 'package:test/test.dart';
import 'package:ophelia/core/domain/playback_state.dart';
import 'package:ophelia/core/usecases/toggle_shuffle.dart';
import 'package:ophelia/data/fakes/fake_playback_engine_port.dart';

import '../../support/result_test_helpers.dart';

void main() {
  PlaybackState stateWith(bool shuffle) => PlaybackState(
        position: Duration.zero,
        queue: const [],
        isImmersive: false,
        repeatMode: RepeatMode.off,
        shuffle: shuffle,
      );

  test('enables shuffle when it was off, and tells the engine', () async {
    final playback = FakePlaybackEnginePort();
    final toggleShuffle = ToggleShuffle(playback);

    final updated = unwrapValue(await toggleShuffle(stateWith(false)));

    expect(updated.shuffle, isTrue);
    expect(playback.shuffle, isTrue);
  });

  test('disables shuffle when it was on, and tells the engine', () async {
    final playback = FakePlaybackEnginePort();
    final toggleShuffle = ToggleShuffle(playback);

    final updated = unwrapValue(await toggleShuffle(stateWith(true)));

    expect(updated.shuffle, isFalse);
    expect(playback.shuffle, isFalse);
  });

  test('leaves other fields untouched', () async {
    final playback = FakePlaybackEnginePort();
    final toggleShuffle = ToggleShuffle(playback);
    final state = PlaybackState(
      position: const Duration(seconds: 5),
      queue: const [],
      isImmersive: true,
      repeatMode: RepeatMode.all,
      shuffle: false,
    );

    final updated = unwrapValue(await toggleShuffle(state));

    expect(updated.position, state.position);
    expect(updated.isImmersive, state.isImmersive);
    expect(updated.repeatMode, state.repeatMode);
  });
}

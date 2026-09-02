import 'package:test/test.dart';
import 'package:ophelia/core/domain/playback_state.dart';
import 'package:ophelia/core/usecases/toggle_immersive.dart';

void main() {
  const toggleImmersive = ToggleImmersive();

  test('flips isImmersive from false to true', () {
    final state = PlaybackState(
      position: Duration.zero,
      queue: const [],
      isImmersive: false,
      repeatMode: RepeatMode.off,
      shuffle: false,
    );

    final updated = toggleImmersive(state);

    expect(updated.isImmersive, isTrue);
  });

  test('flips isImmersive from true to false and leaves other fields intact', () {
    final state = PlaybackState(
      position: const Duration(seconds: 5),
      queue: const [],
      isImmersive: true,
      repeatMode: RepeatMode.all,
      shuffle: true,
    );

    final updated = toggleImmersive(state);

    expect(updated.isImmersive, isFalse);
    expect(updated.position, state.position);
    expect(updated.repeatMode, state.repeatMode);
    expect(updated.shuffle, state.shuffle);
  });
}

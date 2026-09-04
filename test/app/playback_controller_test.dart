import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ophelia/app/playback_controller.dart';
import 'package:ophelia/core/domain/playback_state.dart';
import 'package:ophelia/data/fakes/sample_data.dart';

/// Covers the fix for rapid double-taps on shuffle/repeat: each tap must
/// compute its target from the *other* tap's result, not from the same
/// stale pre-toggle value both taps happened to read (see
/// app/playback_controller.dart's toggleShuffle/toggleRepeatMode).
void main() {
  test(
    'two rapid shuffle taps each toggle from the other\'s result, landing '
    'back on the original value',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(playbackControllerProvider.notifier);
      await controller.play(sampleTracks.first);
      expect(
        container.read(playbackControllerProvider).playback.shuffle,
        isFalse,
      );

      final first = controller.toggleShuffle();
      final second = controller.toggleShuffle();
      await Future.wait([first, second]);

      // Two toggles from false should land back on false. If both taps
      // had read the same stale pre-toggle value, they'd both flip to
      // true and the later one to resolve would leave it stuck there.
      expect(
        container.read(playbackControllerProvider).playback.shuffle,
        isFalse,
      );
    },
  );

  test(
    'two rapid repeat-mode taps each advance the cycle once, not twice '
    'from the same value',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(playbackControllerProvider.notifier);
      await controller.play(sampleTracks.first);
      expect(
        container.read(playbackControllerProvider).playback.repeatMode,
        RepeatMode.off,
      );

      final first = controller.toggleRepeatMode();
      final second = controller.toggleRepeatMode();
      await Future.wait([first, second]);

      // off -> all -> one: two taps should land on `one`. If both taps
      // had read the same stale `off` value, they'd both compute `all`.
      expect(
        container.read(playbackControllerProvider).playback.repeatMode,
        RepeatMode.one,
      );
    },
  );
}

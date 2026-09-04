import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ophelia/app/layout_metrics.dart';
import 'package:ophelia/app/theme.dart';
import 'package:ophelia/data/fakes/sample_data.dart';
import 'package:ophelia/features/playback_ui/playback_controller.dart';

/// Direct coverage of the mechanism behind the mini-player-overlap fix —
/// separate from test/app/mobile_layout_test.dart, which only proves
/// screens don't throw at various sizes, not that this specific number
/// is actually correct.
void main() {
  test('is zero when no track is loaded, since nothing is shown to avoid', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(bottomContentInsetProvider), 0);
  });

  test(
    'reserves the mini-player height plus the gap once a track is loaded',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(playbackControllerProvider.notifier)
          .play(sampleTracks.first);

      expect(
        container.read(bottomContentInsetProvider),
        kMiniPlayerHeight + kMiniPlayerGap,
      );
    },
  );

  test(
    'tracks a newly reported mini-player height rather than staying at '
    'the seed default',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(playbackControllerProvider.notifier)
          .play(sampleTracks.first);
      container.read(miniPlayerHeightProvider.notifier).report(80);

      expect(container.read(bottomContentInsetProvider), 80 + kMiniPlayerGap);
    },
  );
}

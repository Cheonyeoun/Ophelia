import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/playback_ui/playback_controller.dart';
import 'theme.dart';

/// The mini-player's actual rendered height, kept up to date by
/// `MeasureSize` in `AppShell` (lib/app/router.dart) rather than assumed.
/// Screens read [bottomContentInsetProvider] instead of this directly —
/// that's the number that already accounts for whether the mini-player
/// is even showing right now.
class MiniPlayerHeight extends Notifier<double> {
  @override
  double build() => kMiniPlayerHeight;

  void report(double height) {
    if (state != height) state = height;
  }
}

final miniPlayerHeightProvider = NotifierProvider<MiniPlayerHeight, double>(
  MiniPlayerHeight.new,
);

/// The extra bottom padding a scrollable screen should reserve so its
/// last item is never hidden behind the floating mini-player — zero
/// when no track is loaded, since the mini-player isn't shown at all
/// then. Every screen under lib/features/ with scrollable content reads
/// this instead of hardcoding a magic number.
final bottomContentInsetProvider = Provider<double>((ref) {
  final hasTrack = ref.watch(
    playbackControllerProvider.select((s) => s.playback.currentTrack != null),
  );
  if (!hasTrack) return 0;
  return ref.watch(miniPlayerHeightProvider) + kMiniPlayerGap;
});

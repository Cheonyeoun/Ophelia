import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ophelia/app/router.dart';
import 'package:ophelia/app/theme.dart';
import 'package:ophelia/data/fakes/sample_data.dart';
import 'package:ophelia/features/playback_ui/playback_controller.dart';
import 'package:ophelia/features/settings/settings_screen.dart';
import 'package:ophelia/main.dart';

/// Directly verifies the reported bug is fixed: a scrollable screen's own
/// bottom padding grows once the mini-player is showing, instead of
/// staying fixed while the mini-player floats over its last item.
/// test/app/mobile_layout_test.dart only proves nothing throws at various
/// sizes; this proves the actual padding value responds to the
/// mini-player the way lib/app/layout_metrics.dart intends.
void main() {
  testWidgets(
    "Settings' list reserves extra bottom padding once a track is "
    "loaded, so the mini-player can't cover its last row",
    (tester) async {
      await tester.pumpWidget(const ProviderScope(child: OpheliaApp()));
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(OpheliaApp)),
      );
      final router = container.read(routerProvider);

      router.go('/settings');
      await tester.pumpAndSettle();

      final settingsListFinder = find.descendant(
        of: find.byType(SettingsScreen),
        matching: find.byType(ListView),
      );
      final paddingBefore =
          tester.widget<ListView>(settingsListFinder).padding as EdgeInsets;
      expect(paddingBefore.bottom, 24); // no mini-player yet — base padding

      await container
          .read(playbackControllerProvider.notifier)
          .play(sampleTracks.first);
      await tester.pumpAndSettle();

      final paddingAfter =
          tester.widget<ListView>(settingsListFinder).padding as EdgeInsets;

      expect(paddingAfter.bottom, greaterThan(paddingBefore.bottom));
      expect(
        paddingAfter.bottom,
        greaterThanOrEqualTo(24 + kMiniPlayerHeight),
      );
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ophelia/app/providers.dart';
import 'package:ophelia/app/widgets/floating_player_bubble.dart';
import 'package:ophelia/app/widgets/persistent_player_overlay.dart';
import 'package:ophelia/data/fakes/fake_local_file_source_port.dart';
import 'package:ophelia/data/fakes/fake_playback_engine_port.dart';
import 'package:ophelia/data/fakes/sample_data.dart';
import 'package:ophelia/features/playback_ui/mini_player_visibility_controller.dart';
import 'package:ophelia/features/playback_ui/playback_controller.dart';

/// Covers the floating bubble in
/// lib/app/widgets/persistent_player_overlay.dart -- in particular a real
/// bug caught testing on a physical device: dragging the bubble barely
/// moved it, however far the finger travelled. The cause was
/// `onPanUpdate`/`onPanEnd` reading a `clamped` local captured once when
/// `_buildBubble` last ran, instead of the live `_liveBubbleOffset` field
/// -- since `setState` schedules a rebuild for the *next* frame rather
/// than running one synchronously, a burst of pointer-move events
/// arriving before that rebuild flushes (normal for a fast flick) all
/// closed over the same stale starting position and overwrote each
/// other's result instead of accumulating.
///
/// `tester.drag()` alone doesn't reproduce that exact multi-event timing
/// closely enough to pin the regression on its own (a manual
/// multi-`TestGesture.moveBy()`-without-pumping attempt at that turned
/// out not to reflect how the test binding actually resolves the pan
/// arena either, so it isn't used here) -- these are full-drag
/// correctness/coverage tests, verified live on-device for the specific
/// stale-position failure mode.
void main() {
  Future<ProviderContainer> pumpOverlay(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playbackEngineProvider.overrideWithValue(FakePlaybackEnginePort()),
          localFileSourceProvider.overrideWithValue(FakeLocalFileSourcePort()),
        ],
        child: Consumer(
          builder: (context, ref, child) {
            container = ProviderScope.containerOf(context);
            return const MaterialApp(
              home: Scaffold(
                body: PersistentPlayerOverlay(isRootTabRoute: false),
              ),
            );
          },
        ),
      ),
    );

    await container
        .read(playbackControllerProvider.notifier)
        .play(sampleTracks.first);
    container.read(miniPlayerVisibilityProvider.notifier).hide();
    await tester.pumpAndSettle();

    return container;
  }

  testWidgets(
    'dragging the bubble well past the screen\'s midpoint moves it there '
    'and snaps it to the left edge, not back to its starting corner',
    (tester) async {
      await pumpOverlay(tester);

      // Starts at the bottom-right corner by default (see _buildBubble).
      final start = tester.getCenter(find.byType(FloatingPlayerBubble));
      expect(start.dx, greaterThan(200));

      await tester.drag(
        find.byType(FloatingPlayerBubble),
        const Offset(-300, 0),
      );
      await tester.pumpAndSettle();

      final end = tester.getCenter(find.byType(FloatingPlayerBubble));
      expect(end.dx, lessThan(100));
    },
  );

  testWidgets(
    'a drag that ends back on the same (right) half snaps back to the '
    'right edge rather than wherever the drag happened to end',
    (tester) async {
      await pumpOverlay(tester);
      final start = tester.getCenter(find.byType(FloatingPlayerBubble));

      // A modest drag that stays within the right half of a 400-wide
      // screen.
      await tester.drag(
        find.byType(FloatingPlayerBubble),
        const Offset(-100, 0),
      );
      await tester.pumpAndSettle();

      final end = tester.getCenter(find.byType(FloatingPlayerBubble));
      expect(end.dx, closeTo(start.dx, 1));
    },
  );

  testWidgets('tapping the bubble restores the full mini-player bar', (
    tester,
  ) async {
    final container = await pumpOverlay(tester);

    await tester.tap(find.byType(FloatingPlayerBubble));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingPlayerBubble), findsNothing);
    expect(
      container.read(miniPlayerVisibilityProvider).hidden,
      isFalse,
    );
  });
}

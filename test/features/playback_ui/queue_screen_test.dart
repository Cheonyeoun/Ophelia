import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ophelia/app/router.dart';
import 'package:ophelia/data/fakes/sample_data.dart';
import 'package:ophelia/features/playback_ui/playback_controller.dart';
import 'package:ophelia/main.dart';

/// Covers the previously-missing queue navigation gap: Everyday Play's
/// queue icon now pushes a queue screen instead of being decorative.
void main() {
  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: OpheliaApp()));
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(OpheliaApp)));
  }

  testWidgets(
    "tapping Everyday Play's queue icon pushes the queue screen showing "
    'the current queue with the playing track highlighted, and back '
    'returns to Everyday Play',
    (tester) async {
      final container = await pumpApp(tester);
      final controller = container.read(playbackControllerProvider.notifier);
      await controller.play(
        sampleTracks[0],
        queue: sampleTracks.sublist(0, 3),
        queueIndex: 0,
      );

      final router = container.read(routerProvider);
      router.push('/everyday-play');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.queue_music));
      await tester.pumpAndSettle();

      // All three queued tracks show, in order.
      expect(find.text('Marble & Ash'), findsOneWidget);
      expect(find.text('Salt Air'), findsOneWidget);
      expect(find.text('Low Tide'), findsOneWidget);
      // Only the currently-playing track is highlighted.
      expect(find.byIcon(Icons.graphic_eq), findsOneWidget);

      // Tapping a different queued track jumps to it.
      await tester.tap(find.text('Low Tide'));
      await tester.pumpAndSettle();
      expect(
        container.read(playbackControllerProvider).playback.currentTrack
            ?.title,
        'Low Tide',
      );

      router.pop();
      await tester.pumpAndSettle();

      expect(find.text('playing from queue'), findsOneWidget);
    },
  );

  testWidgets('shows a message instead of an empty list when nothing is '
      'queued', (tester) async {
    final container = await pumpApp(tester);
    final router = container.read(routerProvider);

    router.push('/queue');
    await tester.pumpAndSettle();

    expect(find.text('Queue is empty'), findsOneWidget);
  });
}

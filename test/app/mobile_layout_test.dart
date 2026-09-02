import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ophelia/app/playback_controller.dart';
import 'package:ophelia/app/router.dart';
import 'package:ophelia/data/fakes/sample_data.dart';
import 'package:ophelia/main.dart';

/// The rest of this test suite runs at flutter_test's default (desktop-
/// sized, 800x600) surface, which is wide enough to hide a layout
/// overflow that only shows up at actual phone widths. These tests pump
/// every screen at a real phone size (375x812, matching the mockups'
/// frame dimensions in docs/design/) and assert nothing overflows.
void main() {
  Future<ProviderContainer> pumpAppAtPhoneSize(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: OpheliaApp()));
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(OpheliaApp)));
  }

  testWidgets('root tabs do not overflow at phone width', (tester) async {
    final container = await pumpAppAtPhoneSize(tester);
    final router = container.read(routerProvider);

    expect(tester.takeException(), isNull); // /home, the initial route

    router.go('/library');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: '/library');

    router.go('/settings');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: '/settings');
  });

  testWidgets('pushed screens do not overflow at phone width', (tester) async {
    final container = await pumpAppAtPhoneSize(tester);
    final router = container.read(routerProvider);

    for (final path in ['/search', '/downloads', '/profile']) {
      router.push(path);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: path);
      router.pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('player screens do not overflow at phone width', (tester) async {
    final container = await pumpAppAtPhoneSize(tester);
    final router = container.read(routerProvider);

    // Both player screens render transport controls only once a track is
    // loaded, so load one first via the controller directly.
    await container
        .read(playbackControllerProvider.notifier)
        .play(sampleTracks.first, queue: sampleTracks);
    await tester.pumpAndSettle();

    router.push('/everyday-play');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: '/everyday-play');

    router.push('/immersive-play');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: '/immersive-play');
  });

  testWidgets('the mini-player itself does not overflow at phone width', (
    tester,
  ) async {
    final container = await pumpAppAtPhoneSize(tester);

    await container
        .read(playbackControllerProvider.notifier)
        .play(sampleTracks.first, queue: sampleTracks);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

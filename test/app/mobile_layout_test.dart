import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ophelia/app/providers.dart';
import 'package:ophelia/app/router.dart';
import 'package:ophelia/data/fakes/fake_local_library_port.dart';
import 'package:ophelia/data/fakes/sample_data.dart';
import 'package:ophelia/features/playback_ui/playback_controller.dart';
import 'package:ophelia/main.dart';

/// The rest of this test suite runs at flutter_test's default (desktop-
/// sized, 800x600) surface, which is wide enough to hide a layout
/// overflow that only shows up at actual phone widths — that's exactly
/// how the mini-player-overlaps-content bug got through undetected. These
/// tests pump every screen at three representative phone sizes and
/// assert nothing overflows at any of them, with and without the
/// mini-player showing.
void main() {
  const sizes = {
    'small phone (360x640)': Size(360, 640),
    'standard phone (390x844)': Size(390, 844),
    'large phone (430x932)': Size(430, 932),
  };

  Future<ProviderContainer> pumpAppAtSize(
    WidgetTester tester,
    Size size,
  ) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localLibraryProvider.overrideWithValue(FakeLocalLibraryPort()),
        ],
        child: const OpheliaApp(),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(OpheliaApp)));
  }

  for (final MapEntry(key: sizeLabel, value: size) in sizes.entries) {
    group(sizeLabel, () {
      testWidgets('root tabs do not overflow', (tester) async {
        final container = await pumpAppAtSize(tester, size);
        final router = container.read(routerProvider);

        expect(tester.takeException(), isNull, reason: '/home');

        router.go('/library');
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '/library');

        router.go('/settings');
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '/settings');
      });

      testWidgets('pushed screens do not overflow', (tester) async {
        final container = await pumpAppAtSize(tester, size);
        final router = container.read(routerProvider);

        for (final path in ['/search', '/downloads', '/profile']) {
          router.push(path);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: path);
          router.pop();
          await tester.pumpAndSettle();
        }
      });

      testWidgets(
        'root tabs and pushed screens do not overflow once a track is '
        'loaded (the mini-player is now showing on all of them)',
        (tester) async {
          final container = await pumpAppAtSize(tester, size);
          final router = container.read(routerProvider);

          await container
              .read(playbackControllerProvider.notifier)
              .play(sampleTracks.first, queue: sampleTracks);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '/home');

          for (final path in ['/library', '/settings']) {
            router.go(path);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: path);
          }

          for (final path in ['/search', '/downloads', '/profile']) {
            router.push(path);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: path);
            router.pop();
            await tester.pumpAndSettle();
          }
        },
      );

      testWidgets('player screens do not overflow', (tester) async {
        final container = await pumpAppAtSize(tester, size);
        final router = container.read(routerProvider);

        // Both player screens render transport controls only once a
        // track is loaded, so load one first via the controller directly.
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
    });
  }
}

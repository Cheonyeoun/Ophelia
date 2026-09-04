import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ophelia/app/router.dart';
import 'package:ophelia/app/widgets/bottom_nav_bar.dart';
import 'package:ophelia/app/widgets/mini_player_bar.dart';
import 'package:ophelia/data/fakes/sample_data.dart';
import 'package:ophelia/features/playback_ui/playback_controller.dart';
import 'package:ophelia/main.dart';

/// Widget tests for the navigation shell contract in docs/architecture.md
/// §6 — not full per-screen visual coverage, since that contract's rules
/// are the part most likely to be silently broken by a later change.
void main() {
  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: OpheliaApp()));
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(OpheliaApp)));
  }

  group('bottom nav bar', () {
    testWidgets('shows on each of the three root tabs', (tester) async {
      final container = await pumpApp(tester);
      final router = container.read(routerProvider);

      expect(find.byType(BottomNavBar), findsOneWidget); // starts on /home

      router.go('/library');
      await tester.pumpAndSettle();
      expect(find.byType(BottomNavBar), findsOneWidget);

      router.go('/settings');
      await tester.pumpAndSettle();
      expect(find.byType(BottomNavBar), findsOneWidget);
    });

    testWidgets('is absent on pushed, full-screen routes', (tester) async {
      final container = await pumpApp(tester);
      final router = container.read(routerProvider);

      for (final path in ['/search', '/downloads', '/profile']) {
        router.push(path);
        await tester.pumpAndSettle();

        expect(find.byType(BottomNavBar), findsNothing, reason: 'on $path');

        router.pop();
        await tester.pumpAndSettle();
      }
    });

    testWidgets('is absent on Everyday Play and Immersive Play', (tester) async {
      final container = await pumpApp(tester);
      final router = container.read(routerProvider);

      router.push('/everyday-play');
      await tester.pumpAndSettle();
      expect(find.byType(BottomNavBar), findsNothing);

      router.push('/immersive-play');
      await tester.pumpAndSettle();
      expect(find.byType(BottomNavBar), findsNothing);
    });
  });

  group('mini-player', () {
    testWidgets('is hidden when no track is loaded', (tester) async {
      await pumpApp(tester);

      expect(find.byType(MiniPlayerBar), findsNothing);
    });

    testWidgets('appears once a track is loaded, on a root tab', (tester) async {
      final container = await pumpApp(tester);

      await container
          .read(playbackControllerProvider.notifier)
          .play(sampleTracks.first);
      await tester.pumpAndSettle();

      expect(find.byType(MiniPlayerBar), findsOneWidget);
    });

    testWidgets('stays visible on pushed routes once a track is loaded', (tester) async {
      final container = await pumpApp(tester);
      final router = container.read(routerProvider);

      await container
          .read(playbackControllerProvider.notifier)
          .play(sampleTracks.first);
      await tester.pumpAndSettle();

      for (final path in ['/search', '/downloads', '/profile']) {
        router.push(path);
        await tester.pumpAndSettle();

        expect(find.byType(MiniPlayerBar), findsOneWidget, reason: 'on $path');

        router.pop();
        await tester.pumpAndSettle();
      }
    });

    testWidgets('is absent on Everyday Play and Immersive Play even with a '
        'track loaded', (tester) async {
      final container = await pumpApp(tester);
      final router = container.read(routerProvider);

      await container
          .read(playbackControllerProvider.notifier)
          .play(sampleTracks.first);
      await tester.pumpAndSettle();

      router.push('/everyday-play');
      await tester.pumpAndSettle();
      expect(find.byType(MiniPlayerBar), findsNothing);

      router.push('/immersive-play');
      await tester.pumpAndSettle();
      expect(find.byType(MiniPlayerBar), findsNothing);
    });
  });
}

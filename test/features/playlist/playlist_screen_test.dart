import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ophelia/app/router.dart';
import 'package:ophelia/features/playback_ui/playback_controller.dart';
import 'package:ophelia/main.dart';

/// Covers the previously-missing playlist navigation gap: tapping a
/// playlist card in Library (and Home) now pushes a playlist detail
/// screen instead of immediately playing the whole playlist.
void main() {
  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: OpheliaApp()));
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(OpheliaApp)));
  }

  testWidgets(
    'tapping a playlist card in Library pushes the playlist screen with '
    'its name and ordered tracks, and back returns to Library',
    (tester) async {
      final container = await pumpApp(tester);
      final router = container.read(routerProvider);
      router.go('/library');
      await tester.pumpAndSettle();

      expect(find.text('Night drift'), findsOneWidget);
      await tester.tap(find.text('Night drift'));
      await tester.pumpAndSettle();

      // samplePlaylists' 'Night drift' is [t3, t1, t5] -> Low Tide,
      // Marble & Ash, Quiet Rooms, in that order -- and nothing else.
      expect(find.text('Low Tide'), findsOneWidget);
      expect(find.text('Marble & Ash'), findsOneWidget);
      expect(find.text('Quiet Rooms'), findsOneWidget);
      expect(find.text('Salt Air'), findsNothing);

      // Tapping a playlist card must not have played the playlist
      // immediately (that used to be the old behavior) -- only tapping a
      // track inside the detail screen should.
      expect(
        container.read(playbackControllerProvider).playback.currentTrack,
        isNull,
      );

      router.pop();
      await tester.pumpAndSettle();

      expect(find.text('Low Tide'), findsNothing);
      expect(find.text('Night drift'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping a track in the playlist plays it, queued from the whole '
    'playlist starting at that track',
    (tester) async {
      final container = await pumpApp(tester);
      final router = container.read(routerProvider);
      router.push('/playlist/p1');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Marble & Ash'));
      await tester.pumpAndSettle();

      final playback = container.read(playbackControllerProvider).playback;
      expect(playback.currentTrack?.title, 'Marble & Ash');
      expect(
        playback.queue.map((track) => track.title),
        ['Low Tide', 'Marble & Ash', 'Quiet Rooms'],
      );
    },
  );
}

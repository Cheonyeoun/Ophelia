import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ophelia/app/providers.dart';
import 'package:ophelia/app/router.dart';
import 'package:ophelia/core/domain/track.dart';
import 'package:ophelia/data/fakes/fake_local_file_source_port.dart';
import 'package:ophelia/data/fakes/fake_local_library_port.dart';
import 'package:ophelia/main.dart';

/// Covers the Library screen's new "Local Files" entry point: tapping it
/// pushes the Local Files screen instead of going nowhere, the same
/// previously-missing-navigation shape as the Artist/Playlist screens.
void main() {
  Future<ProviderContainer> pumpApp(
    WidgetTester tester, {
    FakeLocalFileSourcePort? localFileSource,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localLibraryProvider.overrideWithValue(FakeLocalLibraryPort()),
          localFileSourceProvider.overrideWithValue(
            localFileSource ?? FakeLocalFileSourcePort(),
          ),
        ],
        child: const OpheliaApp(),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(OpheliaApp)));
  }

  testWidgets(
    'tapping the Local Files icon in Library pushes the Local Files '
    'screen, showing linked folders and their tracks, and back returns '
    'to Library',
    (tester) async {
      const track = Track(
        id: 'local:/music/song.mp3',
        title: 'Song',
        artist: 'Someone',
        album: 'Some Folder',
        durationMs: 1000,
        sourceType: TrackSourceType.local,
      );
      final container = await pumpApp(
        tester,
        localFileSource: FakeLocalFileSourcePort(
          linkedFolders: const ['/music'],
          tracksByFolder: const {'/music': [track]},
        ),
      );
      final router = container.read(routerProvider);
      router.go('/library');
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Local Files'));
      await tester.pumpAndSettle();

      expect(find.text('Local Files'), findsOneWidget);
      expect(find.text('/music'), findsOneWidget);
      expect(find.text('Song'), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();

      expect(find.text('/music'), findsNothing);
      expect(find.text('Library'), findsOneWidget);
    },
  );

  testWidgets(
    'shows an empty state when no folders are linked yet',
    (tester) async {
      final container = await pumpApp(tester);
      final router = container.read(routerProvider);
      router.go('/library');
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Local Files'));
      await tester.pumpAndSettle();

      expect(find.text('No folders linked yet'), findsOneWidget);
    },
  );
}

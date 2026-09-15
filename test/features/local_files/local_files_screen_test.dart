import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ophelia/app/providers.dart';
import 'package:ophelia/app/widgets/track_row.dart';
import 'package:ophelia/core/domain/track.dart';
import 'package:ophelia/data/fakes/fake_local_file_source_port.dart';
import 'package:ophelia/features/local_files/local_files_screen.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester,
    FakeLocalFileSourcePort localFileSource,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [localFileSourceProvider.overrideWithValue(localFileSource)],
        child: const MaterialApp(home: Scaffold(body: LocalFilesScreen())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'tapping "Add folder" links whatever the picker returns and shows '
    'its tracks',
    (tester) async {
      const track = Track(
        id: 'local:/music/song.mp3',
        title: 'Song',
        artist: 'Someone',
        album: 'Some Folder',
        durationMs: 1000,
        sourceType: TrackSourceType.local,
      );
      final localFileSource = FakeLocalFileSourcePort(
        nextPickedFolder: '/music',
        tracksByFolder: const {
          '/music': [track],
        },
      );
      await pumpScreen(tester, localFileSource);

      expect(find.text('No folders linked yet'), findsOneWidget);

      await tester.tap(find.byTooltip('Add folder'));
      await tester.pumpAndSettle();

      expect(find.text('No folders linked yet'), findsNothing);
      // The folder header shows its basename ('music'), not the full raw
      // path -- see _folderLabelFor's own doc comment.
      expect(find.text('music'), findsOneWidget);
      expect(find.text('Song'), findsOneWidget);
    },
  );

  testWidgets('cancelling the picker (a null pick) leaves the folder list '
      'unchanged', (tester) async {
    final localFileSource = FakeLocalFileSourcePort();
    await pumpScreen(tester, localFileSource);

    await tester.tap(find.byTooltip('Add folder'));
    await tester.pumpAndSettle();

    expect(find.text('No folders linked yet'), findsOneWidget);
  });

  testWidgets('tapping a linked folder\'s remove button unlinks it', (
    tester,
  ) async {
    final localFileSource = FakeLocalFileSourcePort(
      linkedFolders: const ['/music'],
      tracksByFolder: const {'/music': []},
    );
    await pumpScreen(tester, localFileSource);

    expect(find.text('music'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove folder'));
    await tester.pumpAndSettle();

    expect(find.text('music'), findsNothing);
    expect(find.text('No folders linked yet'), findsOneWidget);
  });

  testWidgets(
    'shows a message instead of an empty list when a linked folder has '
    'no audio files',
    (tester) async {
      final localFileSource = FakeLocalFileSourcePort(
        linkedFolders: const ['/music'],
        tracksByFolder: const {'/music': []},
      );
      await pumpScreen(tester, localFileSource);

      expect(find.text('No audio files found'), findsOneWidget);
    },
  );

  testWidgets(
    'shows a nested folder as its basename with the parent path and track '
    'count as secondary detail, rather than the full raw path crammed '
    'into one line',
    (tester) async {
      const path = '/storage/emulated/0/Recordings/Record';
      const track = Track(
        id: 'local:$path/memo.m4a',
        title: 'memo',
        artist: 'Unknown artist',
        album: 'Record',
        durationMs: 0,
        sourceType: TrackSourceType.local,
      );
      final localFileSource = FakeLocalFileSourcePort(
        linkedFolders: const [path],
        tracksByFolder: const {
          path: [track],
        },
      );
      await pumpScreen(tester, localFileSource);

      expect(find.text('Record'), findsOneWidget);
      expect(
        find.textContaining('/storage/emulated/0/Recordings'),
        findsOneWidget,
      );
      expect(find.textContaining('1 track'), findsOneWidget);
    },
  );

  testWidgets(
    'shows the failure message, not "No audio files found", when scanning '
    'a linked folder actually fails (e.g. permission denied) -- an empty '
    'result must only ever mean "genuinely no files", never "something '
    'went wrong"',
    (tester) async {
      // tracksByFolder deliberately omits '/music', so FakeLocalFileSourcePort
      // .scanFolder returns a Failure for it rather than an empty list --
      // see that fake's own scanFolder implementation.
      final localFileSource = FakeLocalFileSourcePort(
        linkedFolders: const ['/music'],
      );
      await pumpScreen(tester, localFileSource);

      expect(find.text('No audio files found'), findsNothing);
      expect(find.textContaining('no such folder'), findsOneWidget);
    },
  );

  group('virtualization', () {
    testWidgets(
      'a folder with many tracks only builds a small window of rows, not '
      'every single one at once',
      (tester) async {
        final manyTracks = [
          for (var i = 0; i < 400; i++)
            Track(
              id: 'local:/music/track$i.mp3',
              title: 'Track $i',
              artist: 'Someone',
              album: 'music',
              durationMs: 1000,
              sourceType: TrackSourceType.local,
            ),
        ];
        final localFileSource = FakeLocalFileSourcePort(
          linkedFolders: const ['/music'],
          tracksByFolder: {'/music': manyTracks},
        );

        await pumpScreen(tester, localFileSource);

        // A phone-sized viewport can't possibly show all 400 rows at
        // once -- if it built every one of them eagerly (a plain Column
        // rather than a lazy SliverList.builder), this would find close
        // to 400 instead.
        expect(find.byType(TrackRow).evaluate().length, lessThan(100));
        expect(find.text('Track 0'), findsOneWidget);
        expect(find.text('Track 399'), findsNothing);
      },
    );
  });

  group('search', () {
    late FakeLocalFileSourcePort localFileSource;

    setUp(() {
      localFileSource = FakeLocalFileSourcePort(
        linkedFolders: const ['/music'],
        tracksByFolder: const {
          '/music': [
            Track(
              id: 'local:/music/marble.mp3',
              title: 'Marble & Ash',
              artist: 'Wren Callahan',
              album: 'music',
              durationMs: 1000,
              sourceType: TrackSourceType.local,
            ),
            Track(
              id: 'local:/music/salt.mp3',
              title: 'Salt Air',
              artist: 'Wren Callahan',
              album: 'music',
              durationMs: 1000,
              sourceType: TrackSourceType.local,
            ),
          ],
        },
      );
    });

    testWidgets(
      'typing narrows the visible tracks to a filename match, without '
      'touching the ones that already loaded',
      (tester) async {
        await pumpScreen(tester, localFileSource);

        expect(find.text('Marble & Ash'), findsOneWidget);
        expect(find.text('Salt Air'), findsOneWidget);

        await tester.enterText(find.byType(TextField), 'salt');
        await tester.pumpAndSettle();

        expect(find.text('Salt Air'), findsOneWidget);
        expect(find.text('Marble & Ash'), findsNothing);

        await tester.enterText(find.byType(TextField), '');
        await tester.pumpAndSettle();

        expect(find.text('Marble & Ash'), findsOneWidget);
        expect(find.text('Salt Air'), findsOneWidget);
      },
    );

    testWidgets(
      'a query that matches nothing shows an honest message instead of an '
      'empty list',
      (tester) async {
        await pumpScreen(tester, localFileSource);

        await tester.enterText(find.byType(TextField), 'nonexistent');
        await tester.pumpAndSettle();

        expect(find.text('Marble & Ash'), findsNothing);
        expect(find.text('Salt Air'), findsNothing);
        expect(find.text('No tracks match "nonexistent"'), findsOneWidget);
      },
    );

    testWidgets('filtering never re-scans the folder -- it only narrows the '
        'already-cached result client-side', (tester) async {
      await pumpScreen(tester, localFileSource);

      expect(localFileSource.scanFolderCallCounts['/music'], 1);

      for (final partial in ['s', 'sa', 'sal', 'salt']) {
        await tester.enterText(find.byType(TextField), partial);
        await tester.pump();
      }
      await tester.pumpAndSettle();

      expect(localFileSource.scanFolderCallCounts['/music'], 1);
    });
  });

  group('caching', () {
    testWidgets(
      'the folder is scanned exactly once, not again on unrelated widget '
      'rebuilds',
      (tester) async {
        final localFileSource = FakeLocalFileSourcePort(
          linkedFolders: const ['/music'],
          tracksByFolder: const {
            '/music': [
              Track(
                id: 'local:/music/song.mp3',
                title: 'Song',
                artist: 'Someone',
                album: 'music',
                durationMs: 1000,
                sourceType: TrackSourceType.local,
              ),
            ],
          },
        );

        await pumpScreen(tester, localFileSource);
        expect(localFileSource.scanFolderCallCounts['/music'], 1);

        // Several unrelated rebuilds -- typing in the search field,
        // which setState()s the whole screen -- must not trigger another
        // scan; only an explicit refresh does (see the next test).
        await tester.enterText(find.byType(TextField), 'so');
        await tester.pump();
        await tester.enterText(find.byType(TextField), '');
        await tester.pump();
        await tester.pumpAndSettle();

        expect(localFileSource.scanFolderCallCounts['/music'], 1);
      },
    );

    testWidgets('pulling to refresh re-scans every linked folder', (
      tester,
    ) async {
      final localFileSource = FakeLocalFileSourcePort(
        linkedFolders: const ['/music'],
        tracksByFolder: const {
          '/music': [
            Track(
              id: 'local:/music/song.mp3',
              title: 'Song',
              artist: 'Someone',
              album: 'music',
              durationMs: 1000,
              sourceType: TrackSourceType.local,
            ),
          ],
        },
      );

      await pumpScreen(tester, localFileSource);
      expect(localFileSource.scanFolderCallCounts['/music'], 1);

      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(localFileSource.scanFolderCallCounts['/music'], 2);
    });
  });
}

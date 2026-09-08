import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ophelia/app/providers.dart';
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
        overrides: [
          localFileSourceProvider.overrideWithValue(localFileSource),
        ],
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
        tracksByFolder: const {'/music': [track]},
      );
      await pumpScreen(tester, localFileSource);

      expect(find.text('No folders linked yet'), findsOneWidget);

      await tester.tap(find.byTooltip('Add folder'));
      await tester.pumpAndSettle();

      expect(find.text('No folders linked yet'), findsNothing);
      expect(find.text('/music'), findsOneWidget);
      expect(find.text('Song'), findsOneWidget);
    },
  );

  testWidgets(
    'cancelling the picker (a null pick) leaves the folder list '
    'unchanged',
    (tester) async {
      final localFileSource = FakeLocalFileSourcePort();
      await pumpScreen(tester, localFileSource);

      await tester.tap(find.byTooltip('Add folder'));
      await tester.pumpAndSettle();

      expect(find.text('No folders linked yet'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping a linked folder\'s remove button unlinks it',
    (tester) async {
      final localFileSource = FakeLocalFileSourcePort(
        linkedFolders: const ['/music'],
        tracksByFolder: const {'/music': []},
      );
      await pumpScreen(tester, localFileSource);

      expect(find.text('/music'), findsOneWidget);

      await tester.tap(find.byTooltip('Remove folder'));
      await tester.pumpAndSettle();

      expect(find.text('/music'), findsNothing);
      expect(find.text('No folders linked yet'), findsOneWidget);
    },
  );

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
}

import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ophelia/app/providers.dart';
import 'package:ophelia/core/domain/listening_event.dart';
import 'package:ophelia/core/domain/track.dart';
import 'package:ophelia/core/domain/user_profile.dart';
import 'package:ophelia/data/fakes/fake_image_picker_port.dart';
import 'package:ophelia/data/fakes/fake_local_file_source_port.dart';
import 'package:ophelia/data/local_db/database.dart' hide ListeningEvent;
import 'package:ophelia/data/local_db/drift_library_adapter.dart';
import 'package:ophelia/features/profile/profile_screen.dart';

import '../../support/result_test_helpers.dart';

void main() {
  // See the identical note in drift_library_adapter_test.dart -- every
  // test below opens its own isolated in-memory OpheliaDatabase.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late OpheliaDatabase database;
  late DriftLibraryAdapter localLibrary;

  setUp(() {
    database = OpheliaDatabase(NativeDatabase.memory());
    localLibrary = DriftLibraryAdapter(database);
  });

  tearDown(() => database.close());

  Future<void> pumpProfile(
    WidgetTester tester, {
    FakeLocalFileSourcePort? localFileSource,
    FakeImagePickerPort? imagePicker,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localLibraryProvider.overrideWithValue(localLibrary),
          localFileSourceProvider.overrideWithValue(
            localFileSource ?? FakeLocalFileSourcePort(),
          ),
          imagePickerPortProvider.overrideWithValue(
            imagePicker ?? FakeImagePickerPort(),
          ),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> seedEvents(String trackId, int count) async {
    for (var i = 0; i < count; i++) {
      await localLibrary.recordListeningEvent(
        ListeningEvent(
          trackId: trackId,
          playedAt: DateTime.now(),
          msPlayed: 30000,
        ),
      );
    }
  }

  group('editable display name', () {
    testWidgets(
      'tapping the display name, editing it, and confirming persists the '
      'new name via UpdateProfile',
      (tester) async {
        await localLibrary.saveProfile(
          const UserProfile(displayName: 'Maren Iyer'),
        );

        await pumpProfile(tester);

        expect(find.text('Maren Iyer'), findsOneWidget);

        await tester.tap(find.text('Maren Iyer'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Wren Callahan');
        await tester.tap(find.byIcon(Icons.check));
        await tester.pumpAndSettle();

        expect(find.text('Wren Callahan'), findsOneWidget);
        expect(find.text('Maren Iyer'), findsNothing);

        final saved = unwrapValue(await localLibrary.getProfile());
        expect(saved.displayName, 'Wren Callahan');
      },
    );

    testWidgets(
      'submitting an empty name discards the edit rather than saving a '
      'blank display name',
      (tester) async {
        await localLibrary.saveProfile(
          const UserProfile(displayName: 'Maren Iyer'),
        );

        await pumpProfile(tester);

        await tester.tap(find.text('Maren Iyer'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '   ');
        await tester.tap(find.byIcon(Icons.check));
        await tester.pumpAndSettle();

        expect(find.text('Maren Iyer'), findsOneWidget);
      },
    );
  });

  group('top songs', () {
    testWidgets(
      'a fresh profile with no listening history shows an honest empty '
      'state, not an empty glass card or a "Top 5 songs" label over '
      'nothing',
      (tester) async {
        await localLibrary.saveProfile(
          const UserProfile(displayName: 'Maren Iyer'),
        );

        await pumpProfile(tester);

        expect(find.text('Nothing played yet'), findsOneWidget);
        expect(find.text('Most heard this week'), findsNothing);
        expect(find.text('Top 5 songs'), findsNothing);
      },
    );

    testWidgets(
      'Most heard/Top 5 reflect real seeded listening events, including a '
      'track played from a linked local folder -- not just the fake '
      'catalog',
      (tester) async {
        await localLibrary.saveProfile(
          const UserProfile(displayName: 'Maren Iyer'),
        );

        const localTrack = Track(
          id: 'local:/music/Field Recording.m4a',
          title: 'Field Recording',
          artist: 'Unknown artist',
          album: 'music',
          durationMs: 0,
          sourceType: TrackSourceType.local,
        );
        final localFileSource = FakeLocalFileSourcePort(
          tracksByFolder: {
            '/music': [localTrack],
          },
        );

        // t1 ("Marble & Ash") is the fake catalog's own sample track --
        // most plays, so it should rank as "Most heard this week." The
        // local track has fewer plays but still real ones, and must show
        // up in Top 5 despite never being in the catalog
        // `allTracksProvider` searches -- the exact gap `trackForId`
        // exists to close.
        await seedEvents('t1', 3);
        await seedEvents(localTrack.id, 2);
        await seedEvents('t2', 1);

        await pumpProfile(tester, localFileSource: localFileSource);

        expect(find.text('Most heard this week'), findsOneWidget);
        expect(find.text('Marble & Ash'), findsWidgets);
        expect(find.text('Field Recording'), findsOneWidget);
        expect(find.text('Nothing played yet'), findsNothing);
      },
    );
  });

  group('image picking', () {
    testWidgets(
      'tapping the avatar saves the picked (and persisted) image path as '
      'the profile picture via UpdateProfile',
      (tester) async {
        await localLibrary.saveProfile(
          const UserProfile(displayName: 'Maren Iyer'),
        );

        // A real file, not a made-up path -- Image.file/FileImage need
        // something they can actually read once the screen rebuilds with
        // the new profileImagePath.
        final tempDir = Directory.systemTemp.createTempSync('ophelia_test');
        final imageFile = File('${tempDir.path}/avatar.png')
          ..writeAsBytesSync(_onePixelPng);
        addTearDown(() => tempDir.deleteSync(recursive: true));

        await pumpProfile(
          tester,
          imagePicker: FakeImagePickerPort(nextPickedPath: imageFile.path),
        );

        await tester.tap(find.byIcon(Icons.camera_alt_outlined));
        await tester.pumpAndSettle();

        final saved = unwrapValue(await localLibrary.getProfile());
        expect(saved.profileImagePath, imageFile.path);
      },
    );
  });
}

/// The smallest possible valid PNG (a single transparent pixel) -- just
/// enough for `Image.file` to decode successfully rather than render an
/// error placeholder.
final _onePixelPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x64, 0x60, 0x60, 0x60,
  0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D, 0x0A,
  0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45,
  0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

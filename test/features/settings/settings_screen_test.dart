import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ophelia/app/providers.dart';
import 'package:ophelia/data/fakes/fake_local_library_port.dart';
import 'package:ophelia/data/local_db/database.dart';
import 'package:ophelia/data/local_db/drift_library_adapter.dart';
import 'package:ophelia/features/settings/settings_screen.dart';

void main() {
  // See the identical note in drift_library_adapter_test.dart -- this
  // file's fresh-database test below opens its own isolated in-memory
  // OpheliaDatabase alongside every other test file that does the same.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets(
    'tapping a settings toggle flips and holds its visual state',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localLibraryProvider.overrideWithValue(FakeLocalLibraryPort()),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SettingsScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final row = find.ancestor(
        of: find.text('Gapless playback'),
        matching: find.byType(Row),
      );
      final switchFinder = find.descendant(
        of: row,
        matching: find.byType(Switch),
      );

      expect(tester.widget<Switch>(switchFinder).value, isTrue);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(switchFinder).value, isFalse);

      // Pump again with no further interaction to prove the flipped
      // state is actually held, not just a one-off animation frame.
      await tester.pump();
      expect(tester.widget<Switch>(switchFinder).value, isFalse);
    },
  );

  testWidgets(
    'tapping a toggle row\'s label (not just the switch) also flips its '
    'state',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localLibraryProvider.overrideWithValue(FakeLocalLibraryPort()),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SettingsScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final switchFinder = find.descendant(
        of: find.ancestor(
          of: find.text('Wi-Fi only downloads'),
          matching: find.byType(Row),
        ),
        matching: find.byType(Switch),
      );

      expect(tester.widget<Switch>(switchFinder).value, isTrue);

      await tester.tap(find.text('Wi-Fi only downloads'));
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(switchFinder).value, isFalse);
    },
  );

  testWidgets(
    'tapping a settings value row cycles its displayed value and holds it',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localLibraryProvider.overrideWithValue(FakeLocalLibraryPort()),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SettingsScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('High'), findsOneWidget);

      await tester.tap(find.text('Streaming quality'));
      await tester.pumpAndSettle();

      expect(find.text('High'), findsNothing);
      expect(find.text('Low'), findsOneWidget);
    },
  );

  testWidgets(
    'a fresh (empty) database has no profile row yet, but the profile '
    'section exposes a "Set up profile" action rather than just '
    'disappearing with no way to ever create one',
    (tester) async {
      // FakeLocalLibraryPort can't represent "no profile yet" -- its
      // `profile` field always has a value -- so this needs the real
      // adapter against a genuinely empty database.
      final database = OpheliaDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localLibraryProvider.overrideWithValue(
              DriftLibraryAdapter(database),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: SettingsScreen())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Set up profile'), findsOneWidget);

      await tester.tap(find.text('Set up profile'));
      await tester.pumpAndSettle();

      expect(find.text('Set up profile'), findsNothing);
      expect(find.text('New Listener'), findsOneWidget);
    },
  );
}

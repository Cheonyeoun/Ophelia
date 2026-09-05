import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ophelia/app/providers.dart';
import 'package:ophelia/data/fakes/fake_local_library_port.dart';
import 'package:ophelia/features/settings/settings_screen.dart';

void main() {
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
}

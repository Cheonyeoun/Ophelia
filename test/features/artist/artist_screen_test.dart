import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ophelia/app/router.dart';
import 'package:ophelia/main.dart';

/// Covers the previously-missing artist navigation gap: tapping an
/// artist (in Library's Artists tab) now pushes an artist detail screen
/// instead of going nowhere.
void main() {
  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: OpheliaApp()));
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(OpheliaApp)));
  }

  testWidgets(
    'tapping an artist in Library pushes the artist screen with their '
    'name and tracks, and back returns to Library',
    (tester) async {
      final container = await pumpApp(tester);
      final router = container.read(routerProvider);
      router.go('/library');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Artists'));
      await tester.pumpAndSettle();

      expect(find.text('Wren Callahan'), findsOneWidget);
      await tester.tap(find.text('Wren Callahan'));
      await tester.pumpAndSettle();

      // The artist screen's title and both of that artist's tracks. The
      // title check tolerates the Library row underneath still being in
      // the widget tree -- the tracks are the reliable proof we're
      // actually on the artist screen with the right data.
      expect(find.text('Wren Callahan'), findsWidgets);
      expect(find.text('Marble & Ash'), findsOneWidget);
      // 'Salt Air' is both t2's title and t1/t2's album, so it
      // legitimately appears more than once here -- findsWidgets just
      // confirms it shows at all.
      expect(find.text('Salt Air'), findsWidgets);
      // A track by a different artist must not show up here.
      expect(find.text('Low Tide'), findsNothing);

      router.pop();
      await tester.pumpAndSettle();

      // Back on Library's Artists tab; the artist screen's content is
      // gone.
      expect(find.text('Marble & Ash'), findsNothing);
      expect(find.text('Wren Callahan'), findsOneWidget);
    },
  );
}

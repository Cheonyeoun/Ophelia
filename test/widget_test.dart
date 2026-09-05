import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ophelia/app/providers.dart';
import 'package:ophelia/data/fakes/fake_local_library_port.dart';
import 'package:ophelia/main.dart';

void main() {
  testWidgets('the app boots to the Home tab', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localLibraryProvider.overrideWithValue(FakeLocalLibraryPort()),
        ],
        child: const OpheliaApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Good evening'), findsOneWidget);
  });
}

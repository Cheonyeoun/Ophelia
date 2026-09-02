import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ophelia/main.dart';

void main() {
  testWidgets('the app boots to the Home tab', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: OpheliaApp()));
    await tester.pumpAndSettle();

    expect(find.text('Good evening'), findsOneWidget);
  });
}

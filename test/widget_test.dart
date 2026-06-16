// Smoke test: the app boots to the login screen when there is no session.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dorukhonai_man/app/app.dart';

void main() {
  testWidgets('App boots to the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Login form fields are present.
    expect(find.text('Воридшавӣ'), findsOneWidget);
    expect(find.text('Логин'), findsOneWidget);
    expect(find.text('Парол'), findsOneWidget);
  });
}

// Smoke test: the app boots to the login screen when there is no session.

import 'package:dorukhonai_man/app/app.dart';
import 'package:dorukhonai_man/core/storage/app_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App boots to the login screen', (WidgetTester tester) async {
    // App preferences back the configurable server URL; provide an in-memory
    // store so the (lazy) Dio chain can resolve a base URL.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Login form fields are present.
    expect(find.text('Воридшавӣ'), findsOneWidget);
    expect(find.text('Логин'), findsOneWidget);
    expect(find.text('Парол'), findsOneWidget);
  });
}

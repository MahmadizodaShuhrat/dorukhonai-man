// Localization / runtime language-switch tests (TZ §6): switching the locale
// to Russian re-renders localized labels, and the choice persists via
// AppPreferences.

import 'package:dorukhonai_man/app/locale_provider.dart';
import 'package:dorukhonai_man/core/storage/app_preferences.dart';
import 'package:dorukhonai_man/l10n/app_localization_config.dart';
import 'package:dorukhonai_man/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = AppPreferences(await SharedPreferences.getInstance());
  });

  ProviderContainer container() => ProviderContainer(
    overrides: [appPreferencesProvider.overrideWithValue(prefs)],
  );

  test('defaults to Tajik when no language is stored', () {
    final c = container();
    addTearDown(c.dispose);
    expect(c.read(localeControllerProvider).languageCode, 'tg');
  });

  test('loads the persisted language on start', () async {
    await prefs.setLanguageCode('ru');
    final c = container();
    addTearDown(c.dispose);
    expect(c.read(localeControllerProvider).languageCode, 'ru');
  });

  test('switching to Russian persists the choice', () async {
    final c = container();
    addTearDown(c.dispose);
    await c.read(localeControllerProvider.notifier).setCode('ru');
    expect(c.read(localeControllerProvider).languageCode, 'ru');
    // Persisted so the next launch loads Russian.
    expect(prefs.languageCode, 'ru');
  });

  testWidgets('switching locale to ru changes a known label', (tester) async {
    final c = container();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: Consumer(
          builder: (context, ref, _) {
            final locale = ref.watch(localeControllerProvider);
            return MaterialApp(
              locale: locale,
              supportedLocales: appSupportedLocales,
              localizationsDelegates: appLocalizationsDelegates,
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: Text(AppLocalizations.of(context).navStock),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tajik: navStock == "Анбор".
    expect(find.text('Анбор'), findsOneWidget);
    expect(find.text('Склад'), findsNothing);

    await c.read(localeControllerProvider.notifier).setCode('ru');
    await tester.pumpAndSettle();

    // Russian: navStock == "Склад".
    expect(find.text('Склад'), findsOneWidget);
    expect(find.text('Анбор'), findsNothing);
  });
}

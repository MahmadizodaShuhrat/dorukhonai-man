import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_localizations.dart';
import 'tg_material_fallback.dart';

/// Single source of truth for the app's localization wiring, shared by the
/// root `MaterialApp.router` and by every widget-test harness so the two never
/// drift apart.
///
/// Order matters: [AppLocalizations.delegate] supplies our real UI strings,
/// the `Global*Localizations.delegate`s cover Russian for the built-in widgets,
/// and [tgFallbackDelegates] map Tajik (`tg`) onto the Russian framework
/// strings (see `tg_material_fallback.dart`).
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates =
    <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  ...tgFallbackDelegates,
];

/// Locales the app ships: Tajik (default) and Russian.
const List<Locale> appSupportedLocales = <Locale>[Locale('tg'), Locale('ru')];

/// Resolves the active locale to one we support. Maps any unknown locale to the
/// default Tajik so the app never falls through to an unsupported framework
/// locale (which would assert on missing MaterialLocalizations).
Locale appLocaleResolution(Locale? deviceLocale, Iterable<Locale> supported) {
  if (deviceLocale != null) {
    for (final locale in supported) {
      if (locale.languageCode == deviceLocale.languageCode) return locale;
    }
  }
  return const Locale('tg');
}

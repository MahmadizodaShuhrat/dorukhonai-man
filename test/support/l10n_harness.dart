/// Test harness for localization: wraps a pumped widget in a `MaterialApp`
/// that ships the same delegates/locales as the real app, pinned to Tajik
/// (`tg`) so `AppLocalizations.of(context)` works and existing `find.text`
/// assertions (which use the unchanged Tajik strings) keep matching.
library;

import 'package:dorukhonai_man/l10n/app_localization_config.dart';
import 'package:flutter/material.dart';

/// Wraps [home] in a localized [MaterialApp] pinned to the given [locale]
/// (default Tajik). Use in place of `MaterialApp(home: ...)` in widget tests.
MaterialApp localizedApp(Widget home, {Locale locale = const Locale('tg')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: appSupportedLocales,
    localizationsDelegates: appLocalizationsDelegates,
    home: home,
  );
}

/// Router variant for tests that pump `MaterialApp.router`.
MaterialApp localizedRouterApp(
  RouterConfig<Object> routerConfig, {
  Locale locale = const Locale('tg'),
}) {
  return MaterialApp.router(
    locale: locale,
    supportedLocales: appSupportedLocales,
    localizationsDelegates: appLocalizationsDelegates,
    routerConfig: routerConfig,
  );
}

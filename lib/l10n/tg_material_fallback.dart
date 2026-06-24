import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Tajik (`tg`) localization fallback for the built-in Flutter widget libraries.
///
/// `flutter_localizations`' `GlobalMaterialLocalizations` /
/// `GlobalCupertinoLocalizations` do NOT ship a `tg` locale, so a plain
/// `Locale('tg')` makes `MaterialApp` assert *"No MaterialLocalizations found"*
/// the first time a built-in widget (date picker, tooltips, text-selection
/// menu, …) asks for them.
///
/// Our own [AppLocalizations] supplies every real Tajik UI string; for the
/// handful of strings that come straight out of the framework we simply borrow
/// the Russian (`ru`) ones — Russian is fully supported by the Global delegates
/// and is the closest widely-understood language here.
///
/// These delegates are registered AFTER the Global ones in
/// `localizationsDelegates`. For `ru` the Global delegates win (they are asked
/// first via `shouldReload`/load ordering on locale match); for `tg` they
/// decline and these step in, loading the `ru` flavour of each bundle.
const Locale _ruLocale = Locale('ru');

/// Provides [MaterialLocalizations] for the Tajik locale by delegating to the
/// Russian Material localizations.
class TgMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const TgMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'tg';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(_ruLocale);

  @override
  bool shouldReload(TgMaterialLocalizationsDelegate old) => false;
}

/// Provides [CupertinoLocalizations] for the Tajik locale by delegating to the
/// Russian Cupertino localizations.
class TgCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const TgCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'tg';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(_ruLocale);

  @override
  bool shouldReload(TgCupertinoLocalizationsDelegate old) => false;
}

/// Provides [WidgetsLocalizations] for the Tajik locale by delegating to the
/// Russian Widgets localizations (text direction etc.).
class TgWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const TgWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'tg';

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(_ruLocale);

  @override
  bool shouldReload(TgWidgetsLocalizationsDelegate old) => false;
}

/// The full set of delegates needed to make built-in widgets work for the
/// Tajik (`tg`) locale. Registered after [AppLocalizations.localizationsDelegates]
/// and the `Global*Localizations.delegate`s in the root app and in tests.
const List<LocalizationsDelegate<dynamic>> tgFallbackDelegates =
    <LocalizationsDelegate<dynamic>>[
  TgMaterialLocalizationsDelegate(),
  TgCupertinoLocalizationsDelegate(),
  TgWidgetsLocalizationsDelegate(),
];

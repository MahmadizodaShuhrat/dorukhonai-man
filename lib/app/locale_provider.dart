import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage/app_preferences.dart';
import '../core/utils/formatters.dart';

/// Supported UI language codes. Tajik (`tg`) is the default.
const String kDefaultLanguageCode = 'tg';

/// Maps a stored code to a [Locale]; unknown/`null` → Tajik (default).
Locale localeFromCode(String? code) =>
    code == 'ru' ? const Locale('ru') : const Locale('tg');

/// Stable code for persisting a [Locale] (`'tg'` | `'ru'`).
String languageCode(Locale locale) =>
    locale.languageCode == 'ru' ? 'ru' : 'tg';

/// Holds the active UI [Locale] (Тоҷикӣ / Русский), persisted via
/// [AppPreferences]. The root [MaterialApp] watches this; the top-bar language
/// toggle and the Settings → Забон/Язык section change it. Mirrors the existing
/// `ThemeModeController` style.
class LocaleController extends StateNotifier<Locale> {
  LocaleController(this._prefs) : super(localeFromCode(_prefs.languageCode)) {
    Formatters.setLocale(state.languageCode);
  }

  final AppPreferences _prefs;

  Future<void> set(Locale locale) async {
    if (locale.languageCode == state.languageCode) return;
    state = locale;
    Formatters.setLocale(locale.languageCode);
    await _prefs.setLanguageCode(languageCode(locale));
  }

  /// Convenience used by the toggles/segmented controls.
  Future<void> setCode(String code) => set(localeFromCode(code));
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>(
      (ref) => LocaleController(ref.watch(appPreferencesProvider)),
    );

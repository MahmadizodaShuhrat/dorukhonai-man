import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage/app_preferences.dart';

/// Maps a stored name to a [ThemeMode] (defaults to system).
ThemeMode themeModeFromName(String? name) => switch (name) {
  'light' => ThemeMode.light,
  'dark' => ThemeMode.dark,
  _ => ThemeMode.system,
};

/// Stable name for persisting a [ThemeMode].
String themeModeName(ThemeMode mode) => switch (mode) {
  ThemeMode.light => 'light',
  ThemeMode.dark => 'dark',
  ThemeMode.system => 'system',
};

/// Holds the app theme mode (Системавӣ / Равшан / Торик), persisted via
/// [AppPreferences]. The root [MaterialApp] watches this; Settings changes it.
class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(this._prefs)
    : super(themeModeFromName(_prefs.themeModeName));

  final AppPreferences _prefs;

  Future<void> set(ThemeMode mode) async {
    if (mode == state) return;
    state = mode;
    await _prefs.setThemeModeName(themeModeName(mode));
  }
}

final themeModeControllerProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>(
      (ref) => ThemeModeController(ref.watch(appPreferencesProvider)),
    );

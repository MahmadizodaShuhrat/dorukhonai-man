import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over [SharedPreferences] for NON-SECRET app settings:
/// the configurable server base URL and (later) window bounds, theme, language.
///
/// Secrets (JWT) stay in `flutter_secure_storage` — see [TokenStorage].
class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const String _kServerBaseUrl = 'server_base_url';

  /// Persisted server base URL (full `scheme://host:port/api/v1`), or `null`
  /// when the user has not overridden the default.
  String? get serverBaseUrl => _prefs.getString(_kServerBaseUrl);

  Future<void> setServerBaseUrl(String value) =>
      _prefs.setString(_kServerBaseUrl, value);

  Future<void> clearServerBaseUrl() => _prefs.remove(_kServerBaseUrl);
}

/// Async provider for the [SharedPreferences] singleton. Overridden in tests
/// with `SharedPreferences.setMockInitialValues({})`.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

/// Synchronous handle to [AppPreferences].
///
/// This MUST be overridden once `SharedPreferences` has been loaded (done in
/// `main()` before `runApp`). It throws if read before initialisation so a
/// misconfiguration is loud rather than silent.
final appPreferencesProvider = Provider<AppPreferences>((ref) {
  throw StateError(
    'appPreferencesProvider was not overridden. Initialise it in main() '
    'after loading SharedPreferences.',
  );
});

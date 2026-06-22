import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/app_preferences.dart';

/// Configurable backend server location (TZ_03 §E.8).
///
/// Replaces the old hard-coded `http://host:5000`. A [ServerConfig] is a full
/// base URL — scheme + host + optional port + the `/api/v1` version segment —
/// so the desktop app can point at `localhost`, a LAN machine, or a remote
/// host (e.g. a Render deployment over https) without code changes.
///
/// Resolution order (highest wins):
///   1. `--dart-define=SERVER_BASE_URL=...` (CI / packaged builds);
///   2. value persisted in [AppPreferences] (Settings → Сервер);
///   3. the compile-time [defaultBaseUrl].
class ServerConfig {
  const ServerConfig(this.baseUrl);

  /// Fully-qualified API base URL including the `/api/v1` suffix.
  final String baseUrl;

  /// API version segment (TZ §10).
  static const String apiVersionPath = '/api/v1';

  /// Development default: the .NET backend on the local machine, port 5000.
  static const String defaultBaseUrl = 'http://localhost:5000$apiVersionPath';

  /// Optional build-time override (`flutter ... --dart-define=SERVER_BASE_URL=`).
  static const String _dartDefineBaseUrl = String.fromEnvironment(
    'SERVER_BASE_URL',
  );

  /// `true` when a build-time `--dart-define` pins the URL.
  static bool get hasDartDefineOverride => _dartDefineBaseUrl.isNotEmpty;

  /// Resolves the effective base URL: dart-define > persisted > default.
  static ServerConfig resolve(String? persisted) {
    if (_dartDefineBaseUrl.isNotEmpty) {
      return ServerConfig(normalize(_dartDefineBaseUrl));
    }
    if (persisted != null && persisted.trim().isNotEmpty) {
      return ServerConfig(normalize(persisted));
    }
    return const ServerConfig(defaultBaseUrl);
  }

  /// Validates and normalises a user-entered URL: trims, strips a trailing
  /// slash, and requires an `http`/`https` scheme with a host. Returns `null`
  /// when the input is not a usable absolute http(s) URL.
  static String? tryNormalize(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    if (uri.host.isEmpty) return null;
    return normalize(trimmed);
  }

  /// Best-effort normalisation (no validation): drops trailing slashes.
  static String normalize(String input) {
    var v = input.trim();
    while (v.endsWith('/')) {
      v = v.substring(0, v.length - 1);
    }
    return v;
  }
}

/// Holds the current [ServerConfig] and persists user changes.
///
/// Widgets/repositories watch [serverConfigProvider]; changing the value
/// rebuilds the Dio client (which depends on it), so a Settings "Server"
/// change takes effect on the next request without an app restart.
class ServerConfigController extends StateNotifier<ServerConfig> {
  ServerConfigController(this._prefs)
    : super(ServerConfig.resolve(_prefs.serverBaseUrl));

  final AppPreferences _prefs;

  /// `true` when a `--dart-define` pins the URL (Settings UI should be
  /// read-only in that case).
  bool get isLocked => ServerConfig.hasDartDefineOverride;

  /// Persists and applies a new base URL. Returns the normalised value, or
  /// `null` when [input] is not a valid http(s) URL (state unchanged).
  Future<String?> update(String input) async {
    final normalized = ServerConfig.tryNormalize(input);
    if (normalized == null) return null;
    await _prefs.setServerBaseUrl(normalized);
    state = ServerConfig(normalized);
    return normalized;
  }

  /// Resets to the compile-time default (or dart-define when present).
  Future<void> reset() async {
    await _prefs.clearServerBaseUrl();
    state = ServerConfig.resolve(null);
  }
}

/// Current server configuration. Repositories/Dio depend on this.
final serverConfigProvider =
    StateNotifierProvider<ServerConfigController, ServerConfig>((ref) {
      final prefs = ref.watch(appPreferencesProvider);
      return ServerConfigController(prefs);
    });

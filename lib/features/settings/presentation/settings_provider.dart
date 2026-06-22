import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api/api_result.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/storage/app_preferences.dart';
import '../data/settings_repository.dart';

/// Local (non-secret) app preferences owned by the Settings feature: the
/// expiry-alert window (Огоҳӣ) and the default markup (Нарх). Persisted via
/// the shared [SharedPreferences] instance so they survive restarts.
///
/// These keys are scoped to the settings feature (`settings.*`) so they do not
/// collide with the server-URL key managed by `AppPreferences`.
@immutable
class AppSettings {
  const AppSettings({this.alertDays = 30, this.markupPercent = 0});

  /// Expiry-alert horizon in days (TZ_03 §C.7 — 30/90 selector).
  final int alertDays;

  /// Default sale markup over purchase price, in percent (placeholder for the
  /// pricing module).
  final double markupPercent;

  AppSettings copyWith({int? alertDays, double? markupPercent}) => AppSettings(
    alertDays: alertDays ?? this.alertDays,
    markupPercent: markupPercent ?? this.markupPercent,
  );
}

/// Reads/writes [AppSettings]. Local [SharedPreferences] gives instant defaults
/// and offline persistence; the [SettingsRepository] is the source of truth on
/// the server (TZ_05 FW6) so the expiry job + receipt markup read the same
/// values. Server reads/writes are best-effort — a backend that is offline or
/// has no `/settings` endpoint never breaks the local UX.
class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._prefs, this._ref)
    : super(
        AppSettings(
          alertDays: _prefs?.getInt(_kAlertDays) ?? 30,
          markupPercent: _prefs?.getDouble(_kMarkup) ?? 0,
        ),
      ) {
    _loadFromServer();
  }

  final SharedPreferences? _prefs;
  final Ref _ref;

  static const String _kAlertDays = 'settings.alert_days';
  static const String _kMarkup = 'settings.markup_percent';

  /// Resolves the server repository lazily and defensively: building the Dio
  /// chain can throw in unit tests that do not override its dependencies, so
  /// callers treat a `null` as "server unavailable" and fall back to local.
  SettingsRepository? get _repository {
    try {
      return _ref.read(settingsRepositoryProvider);
    } catch (_) {
      return null;
    }
  }

  /// Pulls the authoritative server settings on init, falling back silently to
  /// the local values when unavailable.
  Future<void> _loadFromServer() async {
    final repo = _repository;
    if (repo == null) return;
    final result = await repo.get();
    if (!mounted) return;
    if (result case Success(:final data)) {
      final days = data.expiryAlertDays;
      final markup = data.markupPercent;
      state = state.copyWith(alertDays: days, markupPercent: markup);
      if (days != null) await _prefs?.setInt(_kAlertDays, days);
      if (markup != null) await _prefs?.setDouble(_kMarkup, markup);
    }
  }

  Future<void> setAlertDays(int days) async {
    state = state.copyWith(alertDays: days);
    await _prefs?.setInt(_kAlertDays, days);
    await _repository?.update(expiryAlertDays: days);
  }

  Future<void> setMarkupPercent(double percent) async {
    state = state.copyWith(markupPercent: percent);
    await _prefs?.setDouble(_kMarkup, percent);
    await _repository?.update(markupPercent: percent);
  }
}

/// Settings provider. Reads the already-loaded [SharedPreferences] from the
/// app-wide [sharedPreferencesProvider]; tolerates the not-yet-loaded state by
/// falling back to defaults. The server repository is resolved lazily so unit
/// tests without a Dio override still build the controller (FW6).
final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AppSettings>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider).valueOrNull;
      return SettingsController(prefs, ref);
    });

/// Result of a server connection test.
enum ConnectionTestState { idle, testing, ok, failed }

/// Pings the configured server (`GET /auth/me`) to verify reachability. A
/// `401` still proves the server is up (we are just not authorised on a bare
/// check), so anything other than a network/timeout error counts as reachable.
class ConnectionTestController extends StateNotifier<ConnectionTestState> {
  ConnectionTestController(this._ref) : super(ConnectionTestState.idle);

  final Ref _ref;

  Future<void> test() async {
    state = ConnectionTestState.testing;
    final dio = _ref.read(dioProvider);
    try {
      await dio.get<dynamic>('/auth/me');
      state = ConnectionTestState.ok;
    } on Object catch (e) {
      // A reachable server that simply rejects auth still confirms the URL.
      final reachable = _looksReachable(e);
      state = reachable ? ConnectionTestState.ok : ConnectionTestState.failed;
    }
  }

  void reset() => state = ConnectionTestState.idle;

  bool _looksReachable(Object error) {
    final text = error.toString().toLowerCase();
    if (text.contains('401') || text.contains('403')) return true;
    final networkish = text.contains('timeout') ||
        text.contains('socket') ||
        text.contains('connection') ||
        text.contains('failed host') ||
        text.contains('network');
    return !networkish;
  }
}

final connectionTestProvider =
    StateNotifierProvider<ConnectionTestController, ConnectionTestState>(
      (ref) => ConnectionTestController(ref),
    );

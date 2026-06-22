import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/cache_dao.dart';
import '../data/sync_engine.dart';
import 'connectivity_provider.dart';

/// CacheDao provider (one per app).
final cacheDaoProvider = Provider<CacheDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CacheDao(db);
});

/// Reactive count of sales awaiting sync (queued + conflict) — drives the
/// top-bar pending badge (TZ_04 §6).
final pendingSyncCountProvider = StreamProvider<int>((ref) {
  return ref.watch(cacheDaoProvider).watchPendingCount();
});

/// Reactive list of conflict sales for the reconciliation surface.
final conflictSalesProvider = StreamProvider<List<OutboxSale>>((ref) {
  return ref.watch(cacheDaoProvider).watchConflicts();
});

/// Coordinates the offline subsystem: starts connectivity polling, wires the
/// reconnect → drain hook, and runs an initial sync. Created once (e.g. read in
/// the shell) so it lives for the session.
class SyncCoordinator {
  SyncCoordinator(this._ref, {this.enablePolling = true}) {
    // Reconnect edge (offline → online) triggers an immediate drain.
    setReconnectHook(() => _ref.read(syncEngineProvider).syncNow());
  }

  final Ref _ref;

  /// When `false` (tests), [start] skips the periodic connectivity poll so no
  /// long-lived [Timer] leaks into the widget-test framework.
  final bool enablePolling;

  bool _started = false;

  /// Begins connectivity polling and runs a first sync. Idempotent.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    if (enablePolling) {
      _ref.read(connectivityControllerProvider.notifier).start();
    }
    await _ref.read(syncEngineProvider).syncNow();
  }

  /// Manual "Sync now" from the UI (top-bar / settings).
  Future<SyncOutcome> syncNow() => _ref.read(syncEngineProvider).syncNow();
}

/// Session-scoped sync coordinator.
final syncCoordinatorProvider = Provider<SyncCoordinator>((ref) {
  return SyncCoordinator(ref);
});

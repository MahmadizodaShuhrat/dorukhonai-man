import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sync_repository.dart';

/// Online/offline connectivity state, with the last-successful-contact time.
class ConnectivityState {
  const ConnectivityState({
    this.isOnline = true,
    this.lastOnlineAt,
    this.checking = false,
  });

  /// `true` when the server last answered a probe.
  final bool isOnline;

  /// Timestamp of the most recent successful contact (for the tooltip).
  final DateTime? lastOnlineAt;

  /// A probe is currently in flight.
  final bool checking;

  ConnectivityState copyWith({
    bool? isOnline,
    DateTime? Function()? lastOnlineAt,
    bool? checking,
  }) {
    return ConnectivityState(
      isOnline: isOnline ?? this.isOnline,
      lastOnlineAt: lastOnlineAt != null ? lastOnlineAt() : this.lastOnlineAt,
      checking: checking ?? this.checking,
    );
  }
}

/// Polls the server with a lightweight probe and exposes online/offline state.
/// A transition offline → online fires [onReconnected] so the sync engine can
/// drain immediately (TZ_04 §4 "connectivity-restored → immediate drain").
class ConnectivityController extends StateNotifier<ConnectivityState> {
  ConnectivityController(this._repository, {this.onReconnected})
    : super(const ConnectivityState());

  final SyncRepository _repository;

  /// Invoked when connectivity is regained (offline → online edge).
  final FutureOr<void> Function()? onReconnected;

  Timer? _timer;

  /// Default poll interval. Kept modest so the indicator stays fresh without
  /// hammering the server.
  static const Duration pollInterval = Duration(seconds: 20);

  /// Starts periodic probing (call once after login / app start).
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(pollInterval, (_) => check());
    unawaited(check());
  }

  /// Runs a single reachability probe and updates state. Returns the new
  /// online flag.
  Future<bool> check() async {
    if (state.checking) return state.isOnline;
    state = state.copyWith(checking: true);
    final online = await _repository.ping();
    final wasOnline = state.isOnline;
    state = state.copyWith(
      isOnline: online,
      checking: false,
      lastOnlineAt: online ? () => DateTime.now() : null,
    );
    if (online && !wasOnline) {
      await onReconnected?.call();
    }
    return online;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Connectivity provider. The reconnect hook is wired in the sync-engine
/// provider to avoid a controller ↔ engine cycle.
final connectivityControllerProvider =
    StateNotifierProvider<ConnectivityController, ConnectivityState>((ref) {
      final repo = ref.watch(syncRepositoryProvider);
      return ConnectivityController(
        repo,
        onReconnected: () => _reconnectHook?.call(),
      );
    });

/// Top-level reconnect hook, registered by the sync engine. Kept outside the
/// provider graph to break the controller ↔ engine dependency cycle.
FutureOr<void> Function()? _reconnectHook;

void setReconnectHook(FutureOr<void> Function()? hook) {
  _reconnectHook = hook;
}

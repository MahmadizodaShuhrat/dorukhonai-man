import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/branch_models.dart';
import '../data/branch_repository.dart';

/// Resolves the REAL working branch for the session (TZ_05 FW1), replacing the
/// old hardcoded `'default'` id. Resolution order:
///   1. the signed-in user's `branchId` (login / `GET /auth/me` now carries it);
///   2. otherwise the central branch from `GET /branches`;
///   3. otherwise the first active branch.
///
/// Lives in one place so POS (open-shift / sales), the dashboard shift KPI, the
/// top bar, and the MODUL 6 operation screens all read the same branch GUID.
/// Returns `null` while unresolved (no session + backend offline) — callers then
/// simply omit `branchId` from queries rather than sending an invalid GUID.

/// The full branch list (`GET /branches`). `null` items list on failure throws
/// so the UI can render an error; callers that only need the resolved id use
/// [currentBranchProvider] instead.
final branchListProvider = FutureProvider<List<Branch>>((ref) async {
  final repo = ref.watch(branchRepositoryProvider);
  final result = await repo.list();
  return switch (result) {
    Success(:final data) => data,
    Error(:final failure) => throw failure,
  };
});

/// The resolved current [Branch] (or `null` when it cannot be determined yet).
final currentBranchProvider = FutureProvider<Branch?>((ref) async {
  final user = ref.watch(authControllerProvider.select((s) => s.user));
  final repo = ref.watch(branchRepositoryProvider);
  final result = await repo.list();
  final branches = switch (result) {
    Success(:final data) => data,
    Error() => const <Branch>[],
  };

  // Prefer the session user's primary branch when the list resolves it.
  final userBranchId = user?.branchId;
  if (userBranchId != null && userBranchId.isNotEmpty) {
    for (final b in branches) {
      if (b.id == userBranchId) return b;
    }
    // The user has a branch id but the list is unavailable (offline): expose a
    // minimal synthetic branch so the id still flows through to queries.
    if (branches.isEmpty) {
      return Branch(id: userBranchId, name: 'Филиал', isCentral: true);
    }
  }

  if (branches.isEmpty) return null;
  for (final b in branches) {
    if (b.isCentral && b.isActive) return b;
  }
  for (final b in branches) {
    if (b.isActive) return b;
  }
  return branches.first;
});

/// The resolved current branch GUID, or `null` when unresolved. Synchronous
/// convenience over [currentBranchProvider] for query parameters.
final currentBranchIdProvider = Provider<String?>((ref) {
  return ref.watch(currentBranchProvider).maybeWhen(
        data: (b) => b?.id,
        orElse: () => null,
      );
});

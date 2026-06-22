import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/cache_dao.dart';
import 'sync_models.dart';
import 'sync_repository.dart';

/// Resource key for the catalog sync cursor.
const String kCatalogResource = 'catalog';

/// Orchestrates offline sync (TZ_04 §4): PULL the catalog/stock into Drift,
/// then PUSH the outbox of offline sales, applying per-sale ok/duplicate/
/// conflict results. Stateless beyond the DB + repository; the connectivity
/// controller calls [syncNow] on reconnect, and the UI can call it manually.
class SyncEngine {
  SyncEngine(this._repository, this._dao);

  final SyncRepository _repository;
  final CacheDao _dao;

  /// Runs a full cycle: PULL then PUSH. Best-effort — a failed PULL still lets
  /// PUSH run (and vice versa). Returns a summary for the UI/logs.
  Future<SyncOutcome> syncNow() async {
    final pull = await pullCatalog();
    final push = await pushOutbox();
    return SyncOutcome(pull: pull, push: push);
  }

  // ---- PULL ---------------------------------------------------------------

  /// PULLs the catalog/stock delta into Drift and advances the cursor.
  Future<bool> pullCatalog() async {
    final cursor = await _dao.cursor(kCatalogResource);
    final result = await _repository.pullCatalog(since: cursor?.sinceToken);
    switch (result) {
      case Success(:final data):
        await _applyCatalog(data);
        await _dao.saveCursor(kCatalogResource, data.serverTime);
        return true;
      case Error():
        return false;
    }
  }

  Future<void> _applyCatalog(CatalogSyncResponse data) async {
    await _dao.upsertProducts(
      data.products.map(
        (p) => CachedProductsCompanion.insert(
          id: p.id,
          name: Value(p.name),
          barcode: Value(p.barcode),
          drugGroupId: Value(p.drugGroupId),
          manufacturerId: Value(p.manufacturerId),
          unitId: Value(p.unitId),
          rxRequired: Value(p.rxRequired),
          isActive: Value(p.isActive),
          minStockLevel: Value(p.minStockLevel),
        ),
      ),
    );
    await _dao.upsertDrugGroups(
      data.drugGroups.map(
        (g) => CachedDrugGroupsCompanion.insert(
          id: g.id,
          name: Value(g.name),
          parentId: Value(g.parentId),
        ),
      ),
    );
    await _dao.upsertManufacturers(
      data.manufacturers.map(
        (m) => CachedManufacturersCompanion.insert(
          id: m.id,
          name: Value(m.name),
          country: Value(m.country),
        ),
      ),
    );
    await _dao.upsertUnits(
      data.units.map(
        (u) => CachedUnitsCompanion.insert(id: u.id, name: Value(u.name)),
      ),
    );
    await _dao.upsertSuppliers(
      data.suppliers.map(
        (s) => CachedSuppliersCompanion.insert(
          id: s.id,
          name: Value(s.name),
          inn: Value(s.inn),
          phone: Value(s.phone),
          address: Value(s.address),
        ),
      ),
    );
    await _dao.upsertBatches(
      data.batches.map(
        (b) => CachedBatchesCompanion.insert(
          id: b.id,
          productId: b.productId,
          seriesNumber: Value(b.seriesNumber),
          expiryDate: b.expiryDate,
          salePrice: Value(b.salePrice),
          purchasePrice: Value(b.purchasePrice),
        ),
      ),
    );
    await _dao.upsertStock(
      data.stock.map(
        (s) => CachedStockCompanion.insert(
          branchId: s.branchId,
          batchId: s.batchId,
          productId: s.productId,
          quantity: Value(s.quantity),
        ),
      ),
    );
  }

  // ---- PUSH ---------------------------------------------------------------

  /// PUSHes queued outbox sales in FIFO order. Accepted (`ok`/`duplicate`)
  /// sales are removed; `conflict` sales are flagged for reconciliation. On a
  /// network/server failure the rows are kept (attempt recorded) for retry.
  Future<PushSummary> pushOutbox() async {
    final queued = await _dao.queuedSales();
    if (queued.isEmpty) {
      return const PushSummary(pushed: 0, conflicts: 0, failed: 0);
    }

    final payloads = queued
        .map((row) => jsonDecode(row.payloadJson) as Map<String, dynamic>)
        .toList(growable: false);

    final result = await _repository.pushSales(payloads);
    switch (result) {
      case Success(:final data):
        return _applyPushResults(queued, data);
      case Error():
        for (final row in queued) {
          await _dao.recordAttempt(row.clientId);
        }
        return PushSummary(pushed: 0, conflicts: 0, failed: queued.length);
    }
  }

  Future<PushSummary> _applyPushResults(
    List<OutboxSale> queued,
    List<SalePushResult> results,
  ) async {
    final byClientId = {for (final r in results) r.clientId: r};
    var pushed = 0;
    var conflicts = 0;
    var failed = 0;

    for (final row in queued) {
      final r = byClientId[row.clientId];
      if (r == null) {
        // No result for this sale: keep it for the next drain.
        await _dao.recordAttempt(row.clientId);
        failed++;
        continue;
      }
      if (r.isAccepted) {
        await _dao.removeSale(row.clientId);
        pushed++;
      } else if (r.isConflict) {
        await _dao.markConflict(row.clientId, r.message);
        conflicts++;
      } else {
        await _dao.recordAttempt(row.clientId);
        failed++;
      }
    }
    return PushSummary(pushed: pushed, conflicts: conflicts, failed: failed);
  }
}

/// Result of one PUSH drain.
class PushSummary {
  const PushSummary({
    required this.pushed,
    required this.conflicts,
    required this.failed,
  });

  final int pushed;
  final int conflicts;
  final int failed;
}

/// Result of a full [SyncEngine.syncNow] cycle.
class SyncOutcome {
  const SyncOutcome({required this.pull, required this.push});

  /// `true` when the PULL succeeded.
  final bool pull;
  final PushSummary push;
}

/// Provider exposing the [SyncEngine].
final syncEngineProvider = Provider<SyncEngine>((ref) {
  final repo = ref.watch(syncRepositoryProvider);
  final db = ref.watch(appDatabaseProvider);
  return SyncEngine(repo, CacheDao(db));
});

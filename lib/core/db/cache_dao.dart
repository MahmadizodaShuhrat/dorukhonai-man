import 'package:drift/drift.dart';

import 'app_database.dart';

part 'cache_dao.g.dart';

/// A FEFO-eligible candidate batch with its remaining effective quantity,
/// produced by the offline allocator query. Ordered `expiryDate ASC,
/// batchId ASC` — exactly the server's FEFO key (TZ_04 §3).
class FefoCandidate {
  const FefoCandidate({
    required this.batchId,
    required this.productId,
    required this.branchId,
    required this.seriesNumber,
    required this.expiryDate,
    required this.salePrice,
    required this.quantity,
  });

  final String batchId;
  final String productId;
  final String branchId;
  final String seriesNumber;
  final DateTime expiryDate;
  final double salePrice;

  /// On-hand cached quantity for this batch at the branch.
  final double quantity;
}

/// Data-access object for the offline cache, outbox, and sync cursor. All
/// Drift access goes through here so widgets/services never touch SQL.
@DriftAccessor(
  tables: [
    CachedProducts,
    CachedDrugGroups,
    CachedManufacturers,
    CachedUnits,
    CachedSuppliers,
    CachedBatches,
    CachedStock,
    OutboxSales,
    SyncCursors,
  ],
)
class CacheDao extends DatabaseAccessor<AppDatabase> with _$CacheDaoMixin {
  CacheDao(super.db);

  // ---- Catalog upsert (PULL) ---------------------------------------------

  Future<void> upsertProducts(Iterable<CachedProductsCompanion> rows) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(cachedProducts, rows.toList());
    });
  }

  Future<void> upsertDrugGroups(
    Iterable<CachedDrugGroupsCompanion> rows,
  ) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(cachedDrugGroups, rows.toList());
    });
  }

  Future<void> upsertManufacturers(
    Iterable<CachedManufacturersCompanion> rows,
  ) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(cachedManufacturers, rows.toList());
    });
  }

  Future<void> upsertUnits(Iterable<CachedUnitsCompanion> rows) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(cachedUnits, rows.toList());
    });
  }

  Future<void> upsertSuppliers(
    Iterable<CachedSuppliersCompanion> rows,
  ) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(cachedSuppliers, rows.toList());
    });
  }

  Future<void> upsertBatches(Iterable<CachedBatchesCompanion> rows) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(cachedBatches, rows.toList());
    });
  }

  Future<void> upsertStock(Iterable<CachedStockCompanion> rows) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(cachedStock, rows.toList());
    });
  }

  // ---- Catalog reads (offline-first) -------------------------------------

  /// Active products, optional case-insensitive name/barcode search.
  Future<List<CachedProduct>> searchProducts({String? search, int limit = 50}) {
    final q = (select(cachedProducts)..where((t) => t.isActive.equals(true)));
    final term = search?.trim();
    if (term != null && term.isNotEmpty) {
      final like = '%${term.toLowerCase()}%';
      q.where(
        (t) => t.name.lower().like(like) | t.barcode.lower().like(like),
      );
    }
    q
      ..orderBy([(t) => OrderingTerm(expression: t.name)])
      ..limit(limit);
    return q.get();
  }

  Future<CachedProduct?> productByBarcode(String barcode) {
    return (select(cachedProducts)
          ..where((t) => t.barcode.equals(barcode))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<CachedProduct?> productById(String id) {
    return (select(cachedProducts)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<CachedBatche?> batchById(String id) {
    return (select(cachedBatches)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Cached stock rows for a branch (joined per batch). Used by the offline
  /// stock list — quantity here is the last-synced figure minus queued sales.
  Future<List<CachedStockData>> stockForBranch(String branchId) {
    return (select(cachedStock)
          ..where((t) => t.branchId.equals(branchId) & t.quantity.isBiggerThanValue(0)))
        .get();
  }

  // ---- Offline FEFO -------------------------------------------------------

  /// FEFO candidate batches for [productId] at [branchId], non-expired as of
  /// [today], ordered `expiryDate ASC, batchId ASC` (server's exact key).
  /// [quantity] is the cached on-hand; the caller subtracts queued allocations.
  Future<List<FefoCandidate>> fefoCandidates({
    required String productId,
    required String branchId,
    required DateTime today,
  }) async {
    final query = select(cachedStock).join([
      innerJoin(
        cachedBatches,
        cachedBatches.id.equalsExp(cachedStock.batchId),
      ),
    ])
      ..where(
        cachedStock.branchId.equals(branchId) &
            cachedStock.productId.equals(productId) &
            cachedStock.quantity.isBiggerThanValue(0) &
            cachedBatches.expiryDate.isBiggerOrEqualValue(_dateOnly(today)),
      )
      ..orderBy([
        OrderingTerm(expression: cachedBatches.expiryDate),
        OrderingTerm(expression: cachedBatches.id),
      ]);

    final rows = await query.get();
    return rows.map((row) {
      final stock = row.readTable(cachedStock);
      final batch = row.readTable(cachedBatches);
      return FefoCandidate(
        batchId: batch.id,
        productId: stock.productId,
        branchId: stock.branchId,
        seriesNumber: batch.seriesNumber,
        expiryDate: batch.expiryDate,
        salePrice: batch.salePrice,
        quantity: stock.quantity,
      );
    }).toList(growable: false);
  }

  /// Optimistically decrements cached stock for [batchId] at [branchId] by
  /// [delta] (clamped at 0) so chained offline sales see reduced on-hand.
  Future<void> decrementStock({
    required String branchId,
    required String batchId,
    required double delta,
  }) async {
    final row = await (select(cachedStock)
          ..where((t) => t.branchId.equals(branchId) & t.batchId.equals(batchId)))
        .getSingleOrNull();
    if (row == null) return;
    final next = (row.quantity - delta).clamp(0, double.infinity).toDouble();
    await (update(cachedStock)
          ..where((t) => t.branchId.equals(branchId) & t.batchId.equals(batchId)))
        .write(CachedStockCompanion(quantity: Value(next)));
  }

  // ---- Outbox -------------------------------------------------------------

  Future<int> enqueueSale(OutboxSalesCompanion row) =>
      into(outboxSales).insert(row);

  /// Queued sales in FIFO order (for the sync drain).
  Future<List<OutboxSale>> queuedSales() {
    return (select(outboxSales)
          ..where((t) => t.status.equals(outboxStatusQueued))
          ..orderBy([(t) => OrderingTerm(expression: t.seq)]))
        .get();
  }

  /// All outbox rows that are not yet settled (queued + conflict), newest
  /// first — drives the pending badge and reconciliation list.
  Future<List<OutboxSale>> pendingAndConflictSales() {
    return (select(outboxSales)
          ..where((t) => t.status.equals(outboxStatusPushed).not())
          ..orderBy([
            (t) => OrderingTerm(expression: t.seq, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Reactive count of rows awaiting sync (queued or conflict).
  Stream<int> watchPendingCount() {
    final countExp = outboxSales.seq.count();
    final query = selectOnly(outboxSales)
      ..addColumns([countExp])
      ..where(outboxSales.status.equals(outboxStatusPushed).not());
    return query.map((row) => row.read(countExp) ?? 0).watchSingle();
  }

  /// Reactive list of conflict sales for the reconciliation surface.
  Stream<List<OutboxSale>> watchConflicts() {
    return (select(outboxSales)
          ..where((t) => t.status.equals(outboxStatusConflict))
          ..orderBy([
            (t) => OrderingTerm(expression: t.seq, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// Marks a queued sale accepted (`ok`/`duplicate`) — removed from the outbox.
  Future<void> removeSale(String clientId) async {
    await (delete(outboxSales)..where((t) => t.clientId.equals(clientId))).go();
  }

  /// Marks a sale as `conflict` so it surfaces for manual resolution.
  Future<void> markConflict(String clientId, String? message) async {
    await (update(outboxSales)..where((t) => t.clientId.equals(clientId)))
        .write(
      OutboxSalesCompanion(
        status: const Value(outboxStatusConflict),
        conflictMessage: Value(message),
      ),
    );
  }

  /// Records a failed push attempt (network/server) without dropping the row.
  Future<void> recordAttempt(String clientId) async {
    final row = await (select(outboxSales)
          ..where((t) => t.clientId.equals(clientId)))
        .getSingleOrNull();
    if (row == null) return;
    await (update(outboxSales)..where((t) => t.clientId.equals(clientId)))
        .write(
      OutboxSalesCompanion(
        attemptCount: Value(row.attemptCount + 1),
        lastAttemptAt: Value(DateTime.now()),
      ),
    );
  }

  /// Drops a conflict the user chose to discard.
  Future<void> dropConflict(String clientId) => removeSale(clientId);

  // ---- Sync cursor --------------------------------------------------------

  Future<SyncCursor?> cursor(String resource) {
    return (select(syncCursors)..where((t) => t.resource.equals(resource)))
        .getSingleOrNull();
  }

  Future<void> saveCursor(String resource, String? sinceToken) {
    return into(syncCursors).insertOnConflictUpdate(
      SyncCursorsCompanion(
        resource: Value(resource),
        sinceToken: Value(sinceToken),
        lastSyncAt: Value(DateTime.now()),
      ),
    );
  }
}

DateTime _dateOnly(DateTime v) => DateTime(v.year, v.month, v.day);

// Offline subsystem tests (TZ_04): local FEFO allocator, offline sale service
// (local FEFO + cache decrement + outbox enqueue), and the sync engine PUSH
// reconciliation (ok/duplicate/conflict).

import 'dart:convert';

import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/core/db/app_database.dart';
import 'package:dorukhonai_man/core/db/cache_dao.dart';
import 'package:dorukhonai_man/features/pos/data/pos_models.dart';
import 'package:dorukhonai_man/features/sync/data/offline_fefo.dart';
import 'package:dorukhonai_man/features/sync/data/offline_sale_service.dart';
import 'package:dorukhonai_man/features/products/data/product_models.dart';
import 'package:dorukhonai_man/features/sync/data/sync_engine.dart';
import 'package:dorukhonai_man/features/sync/data/sync_models.dart';
import 'package:dorukhonai_man/features/sync/data/sync_repository.dart';
import 'package:dorukhonai_man/features/sync/presentation/connectivity_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

/// A controllable sync repo for engine tests.
class _FakeSyncRepository implements SyncRepository {
  _FakeSyncRepository({this.results = const [], this.catalog});

  List<SalePushResult> results;

  /// Optional canned PULL payload. When null, PULL reports a network failure.
  CatalogSyncResponse? catalog;

  List<Map<String, dynamic>>? lastPushed;
  String? lastSince;
  bool online = true;

  @override
  Future<bool> ping() async => online;

  @override
  Future<ApiResult<CatalogSyncResponse>> pullCatalog({String? since}) async {
    lastSince = since;
    if (!online) return const Error(NetworkFailure());
    final c = catalog;
    if (c == null) return const Error(NetworkFailure());
    return Success(c);
  }

  @override
  Future<ApiResult<List<SalePushResult>>> pushSales(
    List<Map<String, dynamic>> sales,
  ) async {
    lastPushed = sales;
    if (!online) return const Error(NetworkFailure());
    return Success(results);
  }
}

void main() {
  group('OfflineFefo', () {
    const fefo = OfflineFefo();
    final today = DateTime(2026, 6, 22);

    FefoCandidate batch(String id, int day, double qty, double price) =>
        FefoCandidate(
          batchId: id,
          productId: 'p1',
          branchId: 'b1',
          seriesNumber: id,
          expiryDate: DateTime(2026, 7, day),
          salePrice: price,
          quantity: qty,
        );

    test('allocates from earliest-expiry batch first', () {
      final result = fefo.allocate(
        candidates: [batch('A', 5, 10, 12), batch('B', 10, 10, 12)],
        requested: 4,
      );
      expect(result, isA<FefoFilled>());
      final filled = result as FefoFilled;
      expect(filled.allocations.single.batchId, 'A');
      expect(filled.allocations.single.quantity, 4);
    });

    test('spills across batches in FEFO order', () {
      final result = fefo.allocate(
        candidates: [batch('A', 5, 3, 12), batch('B', 10, 10, 12)],
        requested: 5,
      );
      final filled = result as FefoFilled;
      expect(filled.allocations.map((a) => a.batchId).toList(), ['A', 'B']);
      expect(filled.allocations[0].quantity, 3);
      expect(filled.allocations[1].quantity, 2);
    });

    test('reports shortfall when cache cannot fill', () {
      final result = fefo.allocate(
        candidates: [batch('A', 5, 3, 12)],
        requested: 5,
      );
      expect(result, isA<FefoShortfall>());
      expect((result as FefoShortfall).available, 3);
    });

    test('honours reserved quantities from earlier offline sales', () {
      final result = fefo.allocate(
        candidates: [batch('A', 5, 10, 12)],
        requested: 5,
        reserved: {'A': 8},
      );
      // 10 - 8 reserved = 2 effective < 5 requested.
      expect(result, isA<FefoShortfall>());
      expect((result as FefoShortfall).available, 2);
    });

    test('non-expired filter is the caller’s job (today unused here)', () {
      expect(today.isBefore(DateTime(2027)), isTrue);
    });
  });

  group('OfflineSaleService + SyncEngine (in-memory Drift)', () {
    late AppDatabase db;
    late CacheDao dao;

    setUp(() async {
      db = AppDatabase.memory();
      dao = CacheDao(db);
      // Seed a product + two batches + stock for branch b1.
      await dao.upsertProducts([
        CachedProductsCompanion.insert(id: 'p1', name: const Value('Аспирин')),
      ]);
      await dao.upsertBatches([
        CachedBatchesCompanion.insert(
          id: 'A',
          productId: 'p1',
          expiryDate: DateTime(2026, 8, 1),
          salePrice: const Value(10),
        ),
        CachedBatchesCompanion.insert(
          id: 'B',
          productId: 'p1',
          expiryDate: DateTime(2026, 12, 1),
          salePrice: const Value(10),
        ),
      ]);
      await dao.upsertStock([
        CachedStockCompanion.insert(
          branchId: 'b1',
          batchId: 'A',
          productId: 'p1',
          quantity: const Value(3),
        ),
        CachedStockCompanion.insert(
          branchId: 'b1',
          batchId: 'B',
          productId: 'p1',
          quantity: const Value(10),
        ),
      ]);
    });

    tearDown(() => db.close());

    test('records an offline sale: FEFO, decrement, outbox enqueue', () async {
      final service = OfflineSaleService(dao);
      final result = await service.recordSale(
        clientId: 'c1',
        branchId: 'b1',
        items: const [
          CartItem(productId: 'p1', name: 'Аспирин', quantity: 5, unitPrice: 10),
        ],
        payments: const [Payment(method: PaymentMethod.cash, amount: 50)],
        discount: 0,
        createdAt: DateTime(2026, 6, 22, 10),
      );

      expect(result, isA<OfflineSaleQueued>());
      final queued = result as OfflineSaleQueued;
      // FEFO: 3 from A then 2 from B.
      expect(queued.lines.map((l) => l.batchId).toList(), ['A', 'B']);
      expect(queued.total, 50);

      // Cache decremented optimistically. `stockForBranch` lists only qty > 0,
      // so the now-empty batch A drops out and B shows 8 (10 - 2).
      final rows = await dao.stockForBranch('b1');
      final byBatch = {for (final r in rows) r.batchId: r.quantity};
      expect(byBatch.containsKey('A'), isFalse); // 3 - 3 = 0, filtered out
      expect(byBatch['B'], 8); // 10 - 2

      // Outbox holds one queued sale with the exact payload shape.
      final out = await dao.queuedSales();
      expect(out, hasLength(1));
      final payload = jsonDecode(out.single.payloadJson) as Map<String, dynamic>;
      expect(payload['clientId'], 'c1');
      expect((payload['lines'] as List).single['productId'], 'p1');
    });

    test('engine PUSH removes accepted, flags conflict', () async {
      final service = OfflineSaleService(dao);
      await service.recordSale(
        clientId: 'ok1',
        branchId: 'b1',
        items: const [
          CartItem(productId: 'p1', name: 'Аспирин', quantity: 1, unitPrice: 10),
        ],
        payments: const [Payment(method: PaymentMethod.cash, amount: 10)],
        discount: 0,
        createdAt: DateTime(2026, 6, 22, 10),
      );
      await service.recordSale(
        clientId: 'cf1',
        branchId: 'b1',
        items: const [
          CartItem(productId: 'p1', name: 'Аспирин', quantity: 1, unitPrice: 10),
        ],
        payments: const [Payment(method: PaymentMethod.cash, amount: 10)],
        discount: 0,
        createdAt: DateTime(2026, 6, 22, 11),
      );

      final repo = _FakeSyncRepository(
        results: const [
          SalePushResult(clientId: 'ok1', status: 'ok', saleId: 's-1'),
          SalePushResult(
            clientId: 'cf1',
            status: 'conflict',
            message: 'нарасид',
          ),
        ],
      );
      final engine = SyncEngine(repo, dao);
      final summary = await engine.pushOutbox();

      expect(summary.pushed, 1);
      expect(summary.conflicts, 1);
      // Accepted sale removed; conflict retained for reconciliation.
      final queued = await dao.queuedSales();
      expect(queued, isEmpty);
      final pendingAndConflict = await dao.pendingAndConflictSales();
      expect(pendingAndConflict, hasLength(1));
      expect(pendingAndConflict.single.clientId, 'cf1');
      expect(await dao.watchPendingCount().first, 1);
    });

    test('engine PUSH keeps rows on network failure', () async {
      final service = OfflineSaleService(dao);
      await service.recordSale(
        clientId: 'n1',
        branchId: 'b1',
        items: const [
          CartItem(productId: 'p1', name: 'Аспирин', quantity: 1, unitPrice: 10),
        ],
        payments: const [Payment(method: PaymentMethod.cash, amount: 10)],
        discount: 0,
        createdAt: DateTime(2026, 6, 22, 10),
      );
      final repo = _FakeSyncRepository()..online = false;
      final engine = SyncEngine(repo, dao);
      final summary = await engine.pushOutbox();
      expect(summary.failed, 1);
      expect(await dao.queuedSales(), hasLength(1));
    });
  });

  group('SyncEngine PULL (in-memory Drift)', () {
    late AppDatabase db;
    late CacheDao dao;

    setUp(() {
      db = AppDatabase.memory();
      dao = CacheDao(db);
    });

    tearDown(() => db.close());

    CatalogSyncResponse catalog(String serverTime) => CatalogSyncResponse(
      serverTime: serverTime,
      products: [
        Product.fromJson(const {
          'id': 'p1',
          'name': 'Аспирин',
          'barcode': '111',
          'isActive': true,
        }),
      ],
      drugGroups: const [],
      manufacturers: const [],
      units: const [],
      suppliers: const [],
      batches: [
        SyncBatchRow.fromJson({
          'id': 'A',
          'productId': 'p1',
          'seriesNumber': 'S-A',
          'expiryDate': DateTime(2026, 8, 1).toIso8601String(),
          'salePrice': 12,
          'purchasePrice': 8,
        }),
      ],
      stock: const [
        SyncStockRow(
          branchId: 'b1',
          batchId: 'A',
          productId: 'p1',
          quantity: 7,
        ),
      ],
    );

    test('writes catalog/stock into Drift and advances the cursor', () async {
      final repo = _FakeSyncRepository(catalog: catalog('2026-06-22T10:00:00Z'));
      final engine = SyncEngine(repo, dao);

      // First PULL: empty cursor → full snapshot requested.
      final ok = await engine.pullCatalog();
      expect(ok, isTrue);
      expect(repo.lastSince, anyOf(isNull, isEmpty));

      // Catalog rows landed in the cache.
      final products = await dao.searchProducts();
      expect(products.single.id, 'p1');
      expect(await dao.productByBarcode('111'), isNotNull);
      expect((await dao.batchById('A'))!.seriesNumber, 'S-A');
      final stock = await dao.stockForBranch('b1');
      expect(stock.single.quantity, 7);

      // Cursor advanced to the response's serverTime (used as next `since`).
      final cursor = await dao.cursor(kCatalogResource);
      expect(cursor!.sinceToken, '2026-06-22T10:00:00Z');
      expect(cursor.lastSyncAt, isNotNull);

      // Second PULL sends the stored cursor as `since` (delta request).
      repo.catalog = catalog('2026-06-22T11:00:00Z');
      await engine.pullCatalog();
      expect(repo.lastSince, '2026-06-22T10:00:00Z');
      expect((await dao.cursor(kCatalogResource))!.sinceToken,
          '2026-06-22T11:00:00Z');
    });

    test('failed PULL leaves the cursor untouched', () async {
      final repo = _FakeSyncRepository(); // no catalog → NetworkFailure
      final engine = SyncEngine(repo, dao);
      expect(await engine.pullCatalog(), isFalse);
      expect(await dao.cursor(kCatalogResource), isNull);
    });
  });

  group('ConnectivityController + pending count', () {
    test('flips offline→online and fires the reconnect drain hook', () async {
      final repo = _FakeSyncRepository()..online = false;
      var reconnects = 0;
      final controller = ConnectivityController(
        repo,
        onReconnected: () => reconnects++,
      );
      addTearDown(controller.dispose);

      // Starts optimistic (online) before the first probe resolves.
      expect(controller.state.isOnline, isTrue);

      // First probe: server unreachable → offline, no reconnect edge.
      expect(await controller.check(), isFalse);
      expect(controller.state.isOnline, isFalse);
      expect(controller.state.lastOnlineAt, isNull);
      expect(reconnects, 0);

      // Server comes back → online edge fires the drain hook exactly once.
      repo.online = true;
      expect(await controller.check(), isTrue);
      expect(controller.state.isOnline, isTrue);
      expect(controller.state.lastOnlineAt, isNotNull);
      expect(reconnects, 1);

      // Staying online does not re-fire the edge.
      expect(await controller.check(), isTrue);
      expect(reconnects, 1);
    });

    test('watchPendingCount reflects queued + conflict, excludes pushed',
        () async {
      final db = AppDatabase.memory();
      final dao = CacheDao(db);
      addTearDown(db.close);

      expect(await dao.watchPendingCount().first, 0);

      await dao.upsertProducts([
        CachedProductsCompanion.insert(id: 'p1', name: const Value('Аспирин')),
      ]);
      await dao.upsertBatches([
        CachedBatchesCompanion.insert(
          id: 'A',
          productId: 'p1',
          expiryDate: DateTime(2026, 12, 1),
          salePrice: const Value(10),
        ),
      ]);
      await dao.upsertStock([
        CachedStockCompanion.insert(
          branchId: 'b1',
          batchId: 'A',
          productId: 'p1',
          quantity: const Value(10),
        ),
      ]);

      final service = OfflineSaleService(dao);
      await service.recordSale(
        clientId: 'q1',
        branchId: 'b1',
        items: const [
          CartItem(productId: 'p1', name: 'Аспирин', quantity: 1, unitPrice: 10),
        ],
        payments: const [Payment(method: PaymentMethod.cash, amount: 10)],
        discount: 0,
        createdAt: DateTime(2026, 6, 22, 10),
      );
      await service.recordSale(
        clientId: 'q2',
        branchId: 'b1',
        items: const [
          CartItem(productId: 'p1', name: 'Аспирин', quantity: 1, unitPrice: 10),
        ],
        payments: const [Payment(method: PaymentMethod.cash, amount: 10)],
        discount: 0,
        createdAt: DateTime(2026, 6, 22, 11),
      );

      // Two queued sales pending.
      expect(await dao.watchPendingCount().first, 2);

      // One accepted (removed), one conflict (retained) → still 1 pending.
      await dao.removeSale('q1');
      await dao.markConflict('q2', 'нарасид');
      expect(await dao.watchPendingCount().first, 1);
      expect(await dao.watchConflicts().first, hasLength(1));
    });
  });
}

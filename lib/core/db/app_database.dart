import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Cached server catalog + stock (read-mostly, refreshed by PULL).
// All ids are Guid TEXT — client and server share one id-space (TZ_04 §2).
// ---------------------------------------------------------------------------

/// Cached drug products (mirror of `Product`).
class CachedProducts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get barcode => text().nullable()();
  TextColumn get drugGroupId => text().nullable()();
  TextColumn get manufacturerId => text().nullable()();
  TextColumn get unitId => text().nullable()();
  BoolColumn get rxRequired => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  RealColumn get minStockLevel => real().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Cached drug groups (mirror of `DrugGroup`).
class CachedDrugGroups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get parentId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Cached manufacturers (mirror of `Manufacturer`).
class CachedManufacturers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get country => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Cached units of measure (mirror of `Unit`).
class CachedUnits extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Cached suppliers (mirror of `Supplier`).
class CachedSuppliers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get inn => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Cached batches — enables offline FEFO (per-batch, not aggregate).
/// Contract: `{ id, productId, seriesNumber, expiryDate, salePrice,
/// purchasePrice }`.
class CachedBatches extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get seriesNumber => text().withDefault(const Constant(''))();
  DateTimeColumn get expiryDate => dateTime()();
  RealColumn get salePrice => real().withDefault(const Constant(0))();
  RealColumn get purchasePrice => real().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Cached per-batch stock at a branch. Unique on `(branchId, batchId)`.
/// Contract: `{ branchId, batchId, productId, quantity }`.
class CachedStock extends Table {
  TextColumn get branchId => text()();
  TextColumn get batchId => text()();
  TextColumn get productId => text()();
  RealColumn get quantity => real().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {branchId, batchId};
}

// ---------------------------------------------------------------------------
// Local-only operational tables (source of truth for offline work).
// ---------------------------------------------------------------------------

/// Durable outbox of sales made while offline (TZ_04 §2). One row per sale;
/// the full `POST /sync/sales` line payload is stored as JSON so the engine can
/// replay it verbatim once connectivity returns. Idempotency key = [clientId].
class OutboxSales extends Table {
  /// Auto-increment guarantees FIFO drain order.
  IntColumn get seq => integer().autoIncrement()();

  /// Client-generated Guid; the server idempotency key.
  TextColumn get clientId => text().unique()();
  TextColumn get branchId => text()();

  /// Full sale payload (lines, payments, discount, createdAt) as JSON.
  TextColumn get payloadJson => text()();

  /// `queued` | `pushed` | `conflict`. `pushed`/`duplicate` rows are deleted;
  /// `conflict` rows are kept for the reconciliation surface.
  TextColumn get status =>
      text().withDefault(const Constant(outboxStatusQueued))();

  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();

  /// Server-assigned sale id once accepted (for display / future returns).
  TextColumn get serverSaleId => text().nullable()();

  /// Human-readable reason when [status] is `conflict`.
  TextColumn get conflictMessage => text().nullable()();
}

/// Outbox status tokens.
const String outboxStatusQueued = 'queued';
const String outboxStatusPushed = 'pushed';
const String outboxStatusConflict = 'conflict';

/// Sync cursor per resource (`catalog`). Stores the last `serverTime` used as
/// the next `since` value, plus the local timestamp of the last successful PULL.
class SyncCursors extends Table {
  TextColumn get resource => text()();
  TextColumn get sinceToken => text().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {resource};
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(
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
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  /// In-memory database for tests.
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'dorukhona_offline.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

/// App-wide [AppDatabase] singleton. Overridden with `AppDatabase.memory()` in
/// tests.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

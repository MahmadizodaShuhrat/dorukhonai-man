import '../../../core/api/api_result.dart';
import '../../../core/api/paged.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/cache_dao.dart';
import '../../products/data/product_models.dart';
import '../../products/data/products_repository.dart';
import '../../stock/data/stock_models.dart';
import '../../stock/data/stock_repository.dart';

/// Offline-first [ProductsRepository] decorator: serves catalog reads from the
/// online repo, transparently falling back to the Drift cache on a network
/// failure (TZ_04 §1 — browse catalog works offline). Writes pass straight
/// through (mutations are online-only per TZ_04 §1).
class OfflineFirstProductsRepository implements ProductsRepository {
  OfflineFirstProductsRepository(this._online, this._dao);

  final ProductsRepository _online;
  final CacheDao _dao;

  @override
  Future<ApiResult<Paged<Product>>> list({
    String? search,
    int page = 1,
    int size = 20,
  }) async {
    final result = await _online.list(search: search, page: page, size: size);
    if (result is Error<Paged<Product>> && result.failure is NetworkFailure) {
      final rows = await _dao.searchProducts(search: search, limit: size);
      final products = rows.map(_toProduct).toList(growable: false);
      return Success(
        Paged<Product>(
          items: products,
          total: products.length,
          page: 1,
          size: size,
        ),
      );
    }
    return result;
  }

  @override
  Future<ApiResult<Product>> getById(String id) async {
    final result = await _online.getById(id);
    if (result is Error<Product> && result.failure is NetworkFailure) {
      final row = await _dao.productById(id);
      if (row != null) return Success(_toProduct(row));
    }
    return result;
  }

  @override
  Future<ApiResult<Product>> getByBarcode(String barcode) async {
    final result = await _online.getByBarcode(barcode);
    if (result is Error<Product> && result.failure is NetworkFailure) {
      final row = await _dao.productByBarcode(barcode);
      if (row != null) return Success(_toProduct(row));
    }
    return result;
  }

  @override
  Future<ApiResult<Product>> create(Product product) =>
      _online.create(product);

  @override
  Future<ApiResult<Product>> update(Product product) =>
      _online.update(product);

  @override
  Future<ApiResult<void>> delete(String id) => _online.delete(id);

  Product _toProduct(CachedProduct row) => Product(
    id: row.id,
    name: row.name,
    barcode: row.barcode,
    drugGroupId: row.drugGroupId,
    manufacturerId: row.manufacturerId,
    unitId: row.unitId,
    rxRequired: row.rxRequired,
    isActive: row.isActive,
    minStockLevel: row.minStockLevel,
  );
}

/// Offline-first [StockRepository] decorator: the balance ("Бақия") view falls
/// back to cached per-batch stock joined with cached batches/products when the
/// network is down (TZ_04 §1). Expiring/low/movements stay online-only (they
/// are derived server-side); offline they surface their original failure.
class OfflineFirstStockRepository implements StockRepository {
  OfflineFirstStockRepository(this._online, this._dao, {required this.branchId});

  final StockRepository _online;
  final CacheDao _dao;

  /// Branch whose cached stock to serve offline (single-branch simplification).
  final String branchId;

  @override
  Future<ApiResult<Paged<StockItem>>> list({
    String? branchId,
    String? search,
    int page = 1,
    int size = 20,
  }) async {
    final result = await _online.list(
      branchId: branchId,
      search: search,
      page: page,
      size: size,
    );
    if (result is Error<Paged<StockItem>> &&
        result.failure is NetworkFailure) {
      final items = await _cachedStock(branchId ?? this.branchId, search);
      return Success(
        Paged<StockItem>(
          items: items,
          total: items.length,
          page: 1,
          size: items.length,
        ),
      );
    }
    return result;
  }

  @override
  Future<ApiResult<Paged<StockItem>>> expiring({
    int days = 90,
    String? branchId,
    int page = 1,
    int size = 20,
  }) => _online.expiring(
    days: days,
    branchId: branchId,
    page: page,
    size: size,
  );

  @override
  Future<ApiResult<Paged<LowStockItem>>> low({
    String? branchId,
    int page = 1,
    int size = 20,
  }) => _online.low(branchId: branchId, page: page, size: size);

  @override
  Future<ApiResult<Paged<StockMovement>>> movements({
    required String productId,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int size = 20,
  }) => _online.movements(
    productId: productId,
    from: from,
    to: to,
    page: page,
    size: size,
  );

  /// Builds [StockItem]s from the cache for offline display.
  Future<List<StockItem>> _cachedStock(String branch, String? search) async {
    final stockRows = await _dao.stockForBranch(branch);
    final term = search?.trim().toLowerCase();
    final items = <StockItem>[];
    for (final s in stockRows) {
      final batch = await _dao.batchById(s.batchId);
      final product = await _dao.productById(s.productId);
      final name = product?.name ?? '';
      if (term != null && term.isNotEmpty) {
        final barcode = product?.barcode ?? '';
        if (!name.toLowerCase().contains(term) &&
            !barcode.toLowerCase().contains(term)) {
          continue;
        }
      }
      items.add(
        StockItem(
          productId: s.productId,
          productName: name,
          barcode: product?.barcode,
          batchId: s.batchId,
          seriesNumber: batch?.seriesNumber ?? '',
          expiryDate: batch?.expiryDate ?? DateTime.now(),
          quantity: s.quantity,
          salePrice: batch?.salePrice ?? 0,
          branchId: s.branchId,
        ),
      );
    }
    return items;
  }
}

// Provider wiring lives in `products_repository.dart` / `stock_repository.dart`
// (the existing `productsRepositoryProvider` / `stockRepositoryProvider` now
// return these decorators) so the rest of the app gets offline reads for free.

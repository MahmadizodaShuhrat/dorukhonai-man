import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/api/paged.dart';
import '../data/stock_models.dart';
import '../data/stock_repository.dart';

/// Generic immutable state for a paged stock tab.
class StockTabState<T> {
  const StockTabState({
    this.items = const [],
    this.page = 1,
    this.size = 20,
    this.total = 0,
    this.isLoading = false,
    this.failure,
  });

  final List<T> items;
  final int page;
  final int size;
  final int total;
  final bool isLoading;
  final Failure? failure;

  int get pageCount => total <= 0 ? 1 : ((total + size - 1) ~/ size);
  bool get hasPrevious => page > 1;
  bool get hasNext => page < pageCount;

  StockTabState<T> copyWith({
    List<T>? items,
    int? page,
    int? size,
    int? total,
    bool? isLoading,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return StockTabState<T>(
      items: items ?? this.items,
      page: page ?? this.page,
      size: size ?? this.size,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

/// Base controller that owns pagination and delegates the actual fetch to a
/// subclass via [fetch]. All data logic stays here, not in widgets (TZ §8).
abstract class StockTabController<T>
    extends StateNotifier<StockTabState<T>> {
  StockTabController() : super(StockTabState<T>()) {
    refresh();
  }

  /// Fetches one page from the repository.
  Future<ApiResult<Paged<T>>> fetch({required int page, required int size});

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    final result = await fetch(page: state.page, size: state.size);
    switch (result) {
      case Success(:final data):
        state = state.copyWith(
          items: data.items,
          total: data.total,
          page: data.page,
          size: data.size,
          isLoading: false,
        );
      case Error(:final failure):
        state = state.copyWith(
          items: const [],
          total: 0,
          isLoading: false,
          failure: failure,
        );
    }
  }

  Future<void> nextPage() async {
    if (!state.hasNext) return;
    state = state.copyWith(page: state.page + 1);
    await refresh();
  }

  Future<void> previousPage() async {
    if (!state.hasPrevious) return;
    state = state.copyWith(page: state.page - 1);
    await refresh();
  }
}

/// "Бақия" tab: on-hand stock with a search term.
class StockListController extends StockTabController<StockItem> {
  StockListController(this._repository);

  final StockRepository _repository;
  String _search = '';

  @override
  Future<ApiResult<Paged<StockItem>>> fetch({
    required int page,
    required int size,
  }) {
    return _repository.list(search: _search, page: page, size: size);
  }

  /// Applies a new search term and resets to the first page.
  Future<void> search(String term) async {
    final trimmed = term.trim();
    if (trimmed == _search) return;
    _search = trimmed;
    state = state.copyWith(page: 1);
    await refresh();
  }
}

/// "Мӯҳлати наздик" tab: stock expiring within [days].
class ExpiringStockController extends StockTabController<StockItem> {
  ExpiringStockController(this._repository);

  final StockRepository _repository;
  int _days = 90;

  int get days => _days;

  @override
  Future<ApiResult<Paged<StockItem>>> fetch({
    required int page,
    required int size,
  }) {
    return _repository.expiring(days: _days, page: page, size: size);
  }

  /// Switches the expiry window (e.g. 90 ↔ 30 days) and reloads.
  Future<void> setDays(int days) async {
    if (days == _days) return;
    _days = days;
    state = state.copyWith(page: 1);
    await refresh();
  }
}

/// "Камшуда" tab: products below their minimum stock level.
class LowStockController extends StockTabController<LowStockItem> {
  LowStockController(this._repository);

  final StockRepository _repository;

  @override
  Future<ApiResult<Paged<LowStockItem>>> fetch({
    required int page,
    required int size,
  }) {
    return _repository.low(page: page, size: size);
  }
}

/// Providers for each tab.
final stockListControllerProvider =
    StateNotifierProvider<StockListController, StockTabState<StockItem>>((ref) {
      return StockListController(ref.watch(stockRepositoryProvider));
    });

final expiringStockControllerProvider =
    StateNotifierProvider<ExpiringStockController, StockTabState<StockItem>>((
      ref,
    ) {
      return ExpiringStockController(ref.watch(stockRepositoryProvider));
    });

final lowStockControllerProvider =
    StateNotifierProvider<LowStockController, StockTabState<LowStockItem>>((
      ref,
    ) {
      return LowStockController(ref.watch(stockRepositoryProvider));
    });

/// Movement history for a single product (first page; newest first).
final stockMovementsProvider =
    FutureProvider.family<List<StockMovement>, String>((ref, productId) async {
      final repository = ref.watch(stockRepositoryProvider);
      final result = await repository.movements(
        productId: productId,
        page: 1,
        size: 50,
      );
      switch (result) {
        case Success(:final data):
          return data.items;
        case Error(:final failure):
          throw failure;
      }
    });

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../data/product_models.dart';
import '../data/products_repository.dart';

/// Immutable state for the products list screen: the current page of results,
/// the active search term, pagination cursors, loading/error flags.
class ProductsListState {
  const ProductsListState({
    this.products = const [],
    this.search = '',
    this.page = 1,
    this.size = 20,
    this.total = 0,
    this.isLoading = false,
    this.failure,
  });

  final List<Product> products;
  final String search;
  final int page;
  final int size;
  final int total;
  final bool isLoading;
  final Failure? failure;

  /// 1-based count of pages for the current [total]/[size].
  int get pageCount => total <= 0 ? 1 : ((total + size - 1) ~/ size);

  bool get hasPrevious => page > 1;
  bool get hasNext => page < pageCount;

  ProductsListState copyWith({
    List<Product>? products,
    String? search,
    int? page,
    int? size,
    int? total,
    bool? isLoading,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return ProductsListState(
      products: products ?? this.products,
      search: search ?? this.search,
      page: page ?? this.page,
      size: size ?? this.size,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

/// Controller for the products list: owns search + pagination and fetches via
/// [ProductsRepository]. All data logic lives here, not in the widget (TZ §8).
class ProductsListController extends StateNotifier<ProductsListState> {
  ProductsListController(this._repository) : super(const ProductsListState()) {
    // Initial load.
    refresh();
  }

  final ProductsRepository _repository;

  /// Loads the current page for the current search term.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    final result = await _repository.list(
      search: state.search,
      page: state.page,
      size: state.size,
    );
    switch (result) {
      case Success(:final data):
        state = state.copyWith(
          products: data.items,
          total: data.total,
          // Trust the server's echoed page/size when present.
          page: data.page,
          size: data.size,
          isLoading: false,
        );
      case Error(:final failure):
        state = state.copyWith(
          products: const [],
          total: 0,
          isLoading: false,
          failure: failure,
        );
    }
  }

  /// Applies a new search term and resets to the first page.
  Future<void> search(String term) async {
    final trimmed = term.trim();
    if (trimmed == state.search) return;
    state = state.copyWith(search: trimmed, page: 1);
    await refresh();
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

  Future<void> goToPage(int page) async {
    final target = page.clamp(1, state.pageCount);
    if (target == state.page) return;
    state = state.copyWith(page: target);
    await refresh();
  }
}

/// Products list provider (search + pagination state).
final productsListControllerProvider =
    StateNotifierProvider<ProductsListController, ProductsListState>((ref) {
      final repository = ref.watch(productsRepositoryProvider);
      return ProductsListController(repository);
    });

/// Outcome of a create/update/delete action, surfaced to the form UI.
sealed class ProductSaveResult {
  const ProductSaveResult();
}

class ProductSaveSuccess extends ProductSaveResult {
  const ProductSaveSuccess(this.product);
  final Product? product;
}

class ProductSaveFailure extends ProductSaveResult {
  const ProductSaveFailure(this.failure);
  final Failure failure;
}

/// Controller for create/edit/delete actions on a single product. Kept
/// separate from the list controller so the form owns its own busy state.
class ProductFormController extends StateNotifier<bool> {
  ProductFormController(this._repository, this._ref) : super(false);

  final ProductsRepository _repository;
  final Ref _ref;

  /// Creates a new product (id is ignored/stripped server-side).
  Future<ProductSaveResult> create(Product product) =>
      _run(() => _repository.create(product));

  /// Updates an existing product.
  Future<ProductSaveResult> update(Product product) =>
      _run(() => _repository.update(product));

  Future<ProductSaveResult> _run(
    Future<ApiResult<Product>> Function() action,
  ) async {
    state = true;
    final result = await action();
    state = false;
    switch (result) {
      case Success(:final data):
        // Keep the list in sync after a successful mutation.
        unawaited(_ref.read(productsListControllerProvider.notifier).refresh());
        return ProductSaveSuccess(data);
      case Error(:final failure):
        return ProductSaveFailure(failure);
    }
  }

  /// Soft-deletes a product, then refreshes the list.
  Future<ProductSaveResult> delete(String id) async {
    state = true;
    final result = await _repository.delete(id);
    state = false;
    switch (result) {
      case Success():
        unawaited(_ref.read(productsListControllerProvider.notifier).refresh());
        return const ProductSaveSuccess(null);
      case Error(:final failure):
        return ProductSaveFailure(failure);
    }
  }
}

/// Provider for the single-product form actions; `bool` state = busy flag.
final productFormControllerProvider =
    StateNotifierProvider<ProductFormController, bool>((ref) {
      final repository = ref.watch(productsRepositoryProvider);
      return ProductFormController(repository, ref);
    });

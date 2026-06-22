import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/api/paged.dart';
import '../../products/data/product_models.dart';
import '../data/reference_crud_repository.dart';
import '../data/reference_repository.dart';

/// Immutable state for a reference-entity list (drug-groups / manufacturers /
/// suppliers / units). Mirrors `ProductsListState`: a page of rows, the active
/// search term, pagination cursors and loading/error flags.
class ReferenceListState<T> {
  const ReferenceListState({
    this.items = const [],
    this.search = '',
    this.page = 1,
    this.size = 50,
    this.total = 0,
    this.isLoading = false,
    this.isSaving = false,
    this.failure,
  });

  final List<T> items;
  final String search;
  final int page;
  final int size;
  final int total;
  final bool isLoading;
  final bool isSaving;
  final Failure? failure;

  int get pageCount => total <= 0 ? 1 : ((total + size - 1) ~/ size);
  bool get hasPrevious => page > 1;
  bool get hasNext => page < pageCount;

  ReferenceListState<T> copyWith({
    List<T>? items,
    String? search,
    int? page,
    int? size,
    int? total,
    bool? isLoading,
    bool? isSaving,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return ReferenceListState<T>(
      items: items ?? this.items,
      search: search ?? this.search,
      page: page ?? this.page,
      size: size ?? this.size,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

/// Outcome of a create/update/delete action surfaced to the editor side-panel.
sealed class ReferenceSaveResult {
  const ReferenceSaveResult();
}

class ReferenceSaveSuccess extends ReferenceSaveResult {
  const ReferenceSaveSuccess();
}

class ReferenceSaveFailure extends ReferenceSaveResult {
  const ReferenceSaveFailure(this.failure);
  final Failure failure;
}

/// Generic list + CRUD controller for one reference entity. The per-entity
/// query/mutation calls are injected as closures so a single implementation
/// serves all four lists (no business logic in widgets — TZ §8).
class ReferenceListController<T>
    extends StateNotifier<ReferenceListState<T>> {
  ReferenceListController({
    required Future<ApiResult<Paged<T>>> Function(String search, int page, int size)
    fetch,
    required Future<ApiResult<T>> Function(T value) create,
    required Future<ApiResult<T>> Function(T value) update,
    required Future<ApiResult<void>> Function(String id) remove,
    // ignore: prefer_initializing_formals
  }) : _fetch = fetch,
       // ignore: prefer_initializing_formals
       _create = create,
       // ignore: prefer_initializing_formals
       _update = update,
       // ignore: prefer_initializing_formals
       _remove = remove,
       super(ReferenceListState<T>()) {
    refresh();
  }

  final Future<ApiResult<Paged<T>>> Function(String search, int page, int size)
  _fetch;
  final Future<ApiResult<T>> Function(T value) _create;
  final Future<ApiResult<T>> Function(T value) _update;
  final Future<ApiResult<void>> Function(String id) _remove;

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    final result = await _fetch(state.search, state.page, state.size);
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

  Future<ReferenceSaveResult> create(T value) =>
      _mutate(() => _create(value));

  Future<ReferenceSaveResult> update(T value) =>
      _mutate(() => _update(value));

  Future<ReferenceSaveResult> _mutate(
    Future<ApiResult<T>> Function() action,
  ) async {
    state = state.copyWith(isSaving: true);
    final result = await action();
    state = state.copyWith(isSaving: false);
    switch (result) {
      case Success():
        await refresh();
        return const ReferenceSaveSuccess();
      case Error(:final failure):
        return ReferenceSaveFailure(failure);
    }
  }

  Future<ReferenceSaveResult> delete(String id) async {
    state = state.copyWith(isSaving: true);
    final result = await _remove(id);
    state = state.copyWith(isSaving: false);
    switch (result) {
      case Success():
        await refresh();
        return const ReferenceSaveSuccess();
      case Error(:final failure):
        return ReferenceSaveFailure(failure);
    }
  }
}

// --- per-entity providers ----------------------------------------------------

final drugGroupsListControllerProvider = StateNotifierProvider<
    ReferenceListController<DrugGroup>, ReferenceListState<DrugGroup>>((ref) {
  final repo = ref.watch(referenceRepositoryProvider);
  final crud = ref.watch(referenceCrudRepositoryProvider);
  return ReferenceListController<DrugGroup>(
    fetch: (s, p, size) => repo.drugGroups(search: s, page: p, size: size),
    create: crud.createDrugGroup,
    update: crud.updateDrugGroup,
    remove: crud.deleteDrugGroup,
  );
});

final manufacturersListControllerProvider = StateNotifierProvider<
    ReferenceListController<Manufacturer>,
    ReferenceListState<Manufacturer>>((ref) {
  final repo = ref.watch(referenceRepositoryProvider);
  final crud = ref.watch(referenceCrudRepositoryProvider);
  return ReferenceListController<Manufacturer>(
    fetch: (s, p, size) => repo.manufacturers(search: s, page: p, size: size),
    create: crud.createManufacturer,
    update: crud.updateManufacturer,
    remove: crud.deleteManufacturer,
  );
});

final suppliersListControllerProvider = StateNotifierProvider<
    ReferenceListController<Supplier>, ReferenceListState<Supplier>>((ref) {
  final repo = ref.watch(referenceRepositoryProvider);
  final crud = ref.watch(referenceCrudRepositoryProvider);
  return ReferenceListController<Supplier>(
    fetch: (s, p, size) => repo.suppliers(search: s, page: p, size: size),
    create: crud.createSupplier,
    update: crud.updateSupplier,
    remove: crud.deleteSupplier,
  );
});

final unitsListControllerProvider = StateNotifierProvider<
    ReferenceListController<Unit>, ReferenceListState<Unit>>((ref) {
  final repo = ref.watch(referenceRepositoryProvider);
  final crud = ref.watch(referenceCrudRepositoryProvider);
  return ReferenceListController<Unit>(
    fetch: (s, p, size) => repo.units(search: s, page: p, size: size),
    create: crud.createUnit,
    update: crud.updateUnit,
    remove: crud.deleteUnit,
  );
});

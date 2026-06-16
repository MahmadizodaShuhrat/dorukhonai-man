import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../data/receipt_models.dart';
import '../data/receipts_repository.dart';

/// Immutable state for the receipts list screen: the current page of headers,
/// active filters (date range, supplier, status), pagination, loading/error.
class ReceiptsListState {
  const ReceiptsListState({
    this.receipts = const [],
    this.from,
    this.to,
    this.supplierId = '',
    this.status,
    this.page = 1,
    this.size = 20,
    this.total = 0,
    this.isLoading = false,
    this.failure,
  });

  final List<Receipt> receipts;
  final DateTime? from;
  final DateTime? to;
  final String supplierId;
  final ReceiptStatus? status;
  final int page;
  final int size;
  final int total;
  final bool isLoading;
  final Failure? failure;

  int get pageCount => total <= 0 ? 1 : ((total + size - 1) ~/ size);

  bool get hasPrevious => page > 1;
  bool get hasNext => page < pageCount;

  ReceiptsListState copyWith({
    List<Receipt>? receipts,
    DateTime? Function()? from,
    DateTime? Function()? to,
    String? supplierId,
    ReceiptStatus? Function()? status,
    int? page,
    int? size,
    int? total,
    bool? isLoading,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return ReceiptsListState(
      receipts: receipts ?? this.receipts,
      from: from != null ? from() : this.from,
      to: to != null ? to() : this.to,
      supplierId: supplierId ?? this.supplierId,
      status: status != null ? status() : this.status,
      page: page ?? this.page,
      size: size ?? this.size,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

/// Controller for the receipts list: owns filters + pagination and fetches via
/// [ReceiptsRepository]. All data logic lives here, not in the widget (TZ §8).
class ReceiptsListController extends StateNotifier<ReceiptsListState> {
  ReceiptsListController(this._repository) : super(const ReceiptsListState()) {
    refresh();
  }

  final ReceiptsRepository _repository;

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    final result = await _repository.list(
      from: state.from,
      to: state.to,
      supplierId: state.supplierId,
      status: state.status,
      page: state.page,
      size: state.size,
    );
    switch (result) {
      case Success(:final data):
        state = state.copyWith(
          receipts: data.items,
          total: data.total,
          page: data.page,
          size: data.size,
          isLoading: false,
        );
      case Error(:final failure):
        state = state.copyWith(
          receipts: const [],
          total: 0,
          isLoading: false,
          failure: failure,
        );
    }
  }

  /// Applies a status filter (or clears it with `null`) and resets to page 1.
  Future<void> filterByStatus(ReceiptStatus? status) async {
    if (status == state.status) return;
    state = state.copyWith(status: () => status, page: 1);
    await refresh();
  }

  /// Applies a date range (either bound may be `null`) and resets to page 1.
  Future<void> filterByDateRange(DateTime? from, DateTime? to) async {
    state = state.copyWith(from: () => from, to: () => to, page: 1);
    await refresh();
  }

  /// Applies a supplier-id filter and resets to page 1.
  Future<void> filterBySupplier(String supplierId) async {
    final trimmed = supplierId.trim();
    if (trimmed == state.supplierId) return;
    state = state.copyWith(supplierId: trimmed, page: 1);
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
}

/// Receipts list provider (filters + pagination state).
final receiptsListControllerProvider =
    StateNotifierProvider<ReceiptsListController, ReceiptsListState>((ref) {
      final repository = ref.watch(receiptsRepositoryProvider);
      return ReceiptsListController(repository);
    });

/// Outcome of a receipt mutation (create/update/post/cancel), surfaced to UI.
sealed class ReceiptSaveResult {
  const ReceiptSaveResult();
}

class ReceiptSaveSuccess extends ReceiptSaveResult {
  const ReceiptSaveSuccess(this.receipt);
  final Receipt receipt;
}

class ReceiptSaveFailure extends ReceiptSaveResult {
  const ReceiptSaveFailure(this.failure);
  final Failure failure;
}

/// Controller for create/update/post/cancel on a single receipt. Kept separate
/// from the list controller so the edit screen owns its own busy state.
class ReceiptEditController extends StateNotifier<bool> {
  ReceiptEditController(this._repository, this._ref) : super(false);

  final ReceiptsRepository _repository;
  final Ref _ref;

  Future<ReceiptSaveResult> create(Receipt receipt) =>
      _run(() => _repository.create(receipt));

  Future<ReceiptSaveResult> update(Receipt receipt) =>
      _run(() => _repository.update(receipt));

  Future<ReceiptSaveResult> post(String id) =>
      _run(() => _repository.post(id));

  Future<ReceiptSaveResult> cancel(String id) =>
      _run(() => _repository.cancel(id));

  Future<ReceiptSaveResult> _run(
    Future<ApiResult<Receipt>> Function() action,
  ) async {
    state = true;
    final result = await action();
    state = false;
    switch (result) {
      case Success(:final data):
        // Keep the list in sync after a successful mutation.
        unawaited(_ref.read(receiptsListControllerProvider.notifier).refresh());
        return ReceiptSaveSuccess(data);
      case Error(:final failure):
        return ReceiptSaveFailure(failure);
    }
  }
}

/// Provider for the single-receipt edit actions; `bool` state = busy flag.
final receiptEditControllerProvider =
    StateNotifierProvider<ReceiptEditController, bool>((ref) {
      final repository = ref.watch(receiptsRepositoryProvider);
      return ReceiptEditController(repository, ref);
    });

/// Loads a single receipt (with lines) by id for the edit screen. Family keyed
/// by receipt id; the edit screen watches this when opening an existing draft.
final receiptDetailProvider = FutureProvider.family<Receipt, String>((
  ref,
  id,
) async {
  final repository = ref.watch(receiptsRepositoryProvider);
  final result = await repository.getById(id);
  switch (result) {
    case Success(:final data):
      return data;
    case Error(:final failure):
      throw failure;
  }
});

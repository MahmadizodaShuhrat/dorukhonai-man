import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/api/paged.dart';
import '../data/operations_models.dart';
import '../data/operations_repository.dart';

/// A draft line shared by all three MODUL 6 editors: a picked batch with its
/// display fields (resolved from the stock list) and an entered quantity.
class OperationLine {
  const OperationLine({
    required this.batchId,
    required this.productName,
    required this.seriesNumber,
    required this.onHand,
    required this.quantity,
  });

  final String batchId;
  final String productName;
  final String seriesNumber;

  /// On-hand quantity for the batch (for the qty>onhand guard + discrepancy).
  final double onHand;

  /// Entered quantity (write-off/return) or counted quantity (inventory).
  final double quantity;

  OperationLine copyWith({double? quantity}) => OperationLine(
    batchId: batchId,
    productName: productName,
    seriesNumber: seriesNumber,
    onHand: onHand,
    quantity: quantity ?? this.quantity,
  );
}

/// Owns a draft list of [OperationLine]s for one editor screen. Pure list
/// editing (add/update/remove); submission lives in the per-document
/// controllers below. Logic stays out of the widgets (TZ §8).
class OperationDraftController extends StateNotifier<List<OperationLine>> {
  OperationDraftController() : super(const []);

  /// Adds a batch line, merging into an existing batch line by replacing its
  /// quantity rather than duplicating the batch.
  void addOrUpdate(OperationLine line) {
    final index = state.indexWhere((l) => l.batchId == line.batchId);
    if (index >= 0) {
      final next = [...state];
      next[index] = line;
      state = next;
    } else {
      state = [...state, line];
    }
  }

  void setQuantity(int index, double quantity) {
    if (index < 0 || index >= state.length) return;
    final next = [...state];
    next[index] = next[index].copyWith(quantity: quantity);
    state = next;
  }

  void removeAt(int index) {
    if (index < 0 || index >= state.length) return;
    state = [...state]..removeAt(index);
  }

  void clear() => state = const [];
}

/// Draft providers — one per editor screen (kept independent so opening one
/// screen never disturbs another's draft).
final writeOffDraftProvider =
    StateNotifierProvider<OperationDraftController, List<OperationLine>>(
      (ref) => OperationDraftController(),
    );

final inventoryDraftProvider =
    StateNotifierProvider<OperationDraftController, List<OperationLine>>(
      (ref) => OperationDraftController(),
    );

final supplierReturnDraftProvider =
    StateNotifierProvider<OperationDraftController, List<OperationLine>>(
      (ref) => OperationDraftController(),
    );

/// History list providers (`GET` per contract; first page newest-first).
final writeOffHistoryProvider =
    FutureProvider.autoDispose<Paged<WriteOff>>((ref) async {
  final repo = ref.watch(operationsRepositoryProvider);
  final result = await repo.listWriteOffs(page: 1, size: 20);
  return switch (result) {
    Success(:final data) => data,
    Error(:final failure) => throw failure,
  };
});

final inventoryHistoryProvider =
    FutureProvider.autoDispose<Paged<InventoryDoc>>((ref) async {
  final repo = ref.watch(operationsRepositoryProvider);
  final result = await repo.listInventory(page: 1, size: 20);
  return switch (result) {
    Success(:final data) => data,
    Error(:final failure) => throw failure,
  };
});

final supplierReturnHistoryProvider =
    FutureProvider.autoDispose<Paged<SupplierReturn>>((ref) async {
  final repo = ref.watch(operationsRepositoryProvider);
  final result = await repo.listSupplierReturns(page: 1, size: 20);
  return switch (result) {
    Success(:final data) => data,
    Error(:final failure) => throw failure,
  };
});

/// Busy flag for a posting action (mirrors `saleSubmitControllerProvider`).
final operationSubmittingProvider = StateProvider.autoDispose<bool>((_) => false);

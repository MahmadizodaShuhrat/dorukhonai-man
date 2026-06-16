import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../products/data/product_models.dart';
import '../data/pos_models.dart';
import '../data/pos_repository.dart';

/// State of the current cash shift for one branch.
class CashShiftState {
  const CashShiftState({
    this.branchId = '',
    this.shift,
    this.isLoading = false,
    this.failure,
  });

  /// Branch the shift is (or will be) opened for. Persisted across the sale
  /// flow so every `POST /sales` carries the same `branchId`.
  final String branchId;

  /// The current open shift, or `null` when none is open.
  final CashShift? shift;
  final bool isLoading;
  final Failure? failure;

  bool get hasOpenShift => shift != null && shift!.status.isOpen;

  CashShiftState copyWith({
    String? branchId,
    CashShift? Function()? shift,
    bool? isLoading,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return CashShiftState(
      branchId: branchId ?? this.branchId,
      shift: shift != null ? shift() : this.shift,
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

/// Owns the open/close/current lifecycle of the cash shift (TZ §3.2). All shift
/// logic lives here, not in the widget (TZ §8).
class CashShiftController extends StateNotifier<CashShiftState> {
  CashShiftController(this._repository) : super(const CashShiftState());

  final PosRepository _repository;

  /// Sets the working branch id (from the open-shift panel).
  void setBranchId(String branchId) {
    final trimmed = branchId.trim();
    if (trimmed == state.branchId) return;
    state = state.copyWith(branchId: trimmed);
  }

  /// Loads the current open shift for [state.branchId]. A 404 is normal (no
  /// open shift) and clears the shift without surfacing an error.
  Future<void> loadCurrent() async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    final result = await _repository.currentShift(branchId: state.branchId);
    switch (result) {
      case Success(:final data):
        // Adopt the loaded shift's branch so a resumed (already-open) shift
        // still carries a branchId on every subsequent `POST /sales`.
        state = state.copyWith(
          shift: () => data,
          branchId: data.branchId,
          isLoading: false,
        );
      case Error(:final failure):
        final notFound =
            failure is ServerFailure && failure.statusCode == 404;
        state = state.copyWith(
          shift: () => null,
          isLoading: false,
          failure: notFound ? null : failure,
        );
    }
  }

  /// Opens a shift with [openingCash] for the current branch. Returns the
  /// failure (if any) so the screen can surface it.
  Future<Failure?> openShift(double openingCash) async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    final result = await _repository.openShift(
      branchId: state.branchId,
      openingCash: openingCash,
    );
    switch (result) {
      case Success(:final data):
        // The server echoes the authoritative branchId; adopt it.
        state = state.copyWith(
          shift: () => data,
          branchId: data.branchId,
          isLoading: false,
        );
        return null;
      case Error(:final failure):
        state = state.copyWith(isLoading: false, failure: failure);
        return failure;
    }
  }

  /// Closes the current shift with [closingCash]. On success the local shift is
  /// cleared. Returns either the closed shift or a failure.
  Future<CloseShiftResult> closeShift(double closingCash) async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    final result = await _repository.closeShift(closingCash: closingCash);
    switch (result) {
      case Success(:final data):
        state = state.copyWith(shift: () => null, isLoading: false);
        return CloseShiftSuccess(data);
      case Error(:final failure):
        state = state.copyWith(isLoading: false, failure: failure);
        return CloseShiftFailure(failure);
    }
  }
}

/// Outcome of closing a shift, surfaced to the UI.
sealed class CloseShiftResult {
  const CloseShiftResult();
}

class CloseShiftSuccess extends CloseShiftResult {
  const CloseShiftSuccess(this.shift);
  final CashShift shift;
}

class CloseShiftFailure extends CloseShiftResult {
  const CloseShiftFailure(this.failure);
  final Failure failure;
}

/// Cash-shift provider (one per app session; single branch).
final cashShiftControllerProvider =
    StateNotifierProvider<CashShiftController, CashShiftState>((ref) {
      return CashShiftController(ref.watch(posRepositoryProvider));
    });

/// State of the in-progress cart: client-side lines + a cart-level discount.
class CartState {
  const CartState({this.items = const [], this.discount = 0});

  final List<CartItem> items;
  final double discount;

  /// Sum of indicative line totals before the cart-level discount.
  double get subtotal =>
      items.fold<double>(0, (sum, item) => sum + item.lineTotal);

  /// Indicative grand total (`subtotal - discount`, never negative). The server
  /// computes the authoritative total.
  double get total =>
      (subtotal - discount).clamp(0, double.infinity).toDouble();

  bool get isEmpty => items.isEmpty;

  CartState copyWith({List<CartItem>? items, double? discount}) {
    return CartState(
      items: items ?? this.items,
      discount: discount ?? this.discount,
    );
  }
}

/// Owns the cart contents and editing operations (TZ §3.2). The cart sends only
/// product+qty(+lineDiscount) to the server, which runs FEFO.
class PosCartController extends StateNotifier<CartState> {
  PosCartController() : super(const CartState());

  /// Adds a product to the cart, merging into an existing line (same product
  /// and no per-line discount) by bumping its quantity.
  void addProduct(Product product, {double quantity = 1, double unitPrice = 0}) {
    final items = [...state.items];
    final index = items.indexWhere(
      (i) => i.productId == product.id && i.lineDiscount == 0,
    );
    if (index >= 0) {
      final existing = items[index];
      items[index] =
          existing.copyWith(quantity: existing.quantity + quantity);
    } else {
      items.add(
        CartItem(
          productId: product.id,
          name: product.name,
          quantity: quantity,
          unitPrice: unitPrice,
        ),
      );
    }
    state = state.copyWith(items: items);
  }

  /// Sets an absolute [quantity] for the line at [index]; values <= 0 remove it.
  void setQuantity(int index, double quantity) {
    if (index < 0 || index >= state.items.length) return;
    if (quantity <= 0) {
      removeAt(index);
      return;
    }
    final items = [...state.items];
    items[index] = items[index].copyWith(quantity: quantity);
    state = state.copyWith(items: items);
  }

  /// Adjusts the quantity of the line at [index] by [delta] (the +/- buttons).
  void changeQuantity(int index, double delta) {
    if (index < 0 || index >= state.items.length) return;
    setQuantity(index, state.items[index].quantity + delta);
  }

  /// Sets a per-line discount (clamped to >= 0).
  void setLineDiscount(int index, double discount) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items];
    items[index] = items[index].copyWith(
      lineDiscount: discount < 0 ? 0 : discount,
    );
    state = state.copyWith(items: items);
  }

  void removeAt(int index) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items]..removeAt(index);
    state = state.copyWith(items: items);
  }

  /// Sets the cart-level discount (clamped to >= 0).
  void setDiscount(double discount) {
    state = state.copyWith(discount: discount < 0 ? 0 : discount);
  }

  /// Empties the cart for the next sale.
  void clear() {
    state = const CartState();
  }
}

/// Cart provider (one per app session).
final posCartControllerProvider =
    StateNotifierProvider<PosCartController, CartState>((ref) {
      return PosCartController();
    });

/// Outcome of submitting a sale, surfaced to the UI.
sealed class SaleSubmitResult {
  const SaleSubmitResult();
}

class SaleSubmitSuccess extends SaleSubmitResult {
  const SaleSubmitSuccess(this.sale);
  final Sale sale;
}

class SaleSubmitFailure extends SaleSubmitResult {
  const SaleSubmitFailure(this.failure);
  final Failure failure;
}

/// Submits the sale and (on success) refreshes the shift so `totalSales`
/// reflects the new sale. `bool` state = busy flag (mirrors
/// `ReceiptEditController`).
class SaleSubmitController extends StateNotifier<bool> {
  SaleSubmitController(this._repository, this._ref) : super(false);

  final PosRepository _repository;
  final Ref _ref;

  /// Books the current cart against the current branch with [payments] and the
  /// cart-level [discount].
  Future<SaleSubmitResult> submit({
    required List<Payment> payments,
    required double discount,
  }) async {
    final shiftState = _ref.read(cashShiftControllerProvider);
    final cart = _ref.read(posCartControllerProvider);
    state = true;
    final result = await _repository.createSale(
      branchId: shiftState.branchId,
      lines: cart.items,
      payments: payments,
      discount: discount,
    );
    state = false;
    switch (result) {
      case Success(:final data):
        // Reflect the sale in the shift's running total.
        await _ref.read(cashShiftControllerProvider.notifier).loadCurrent();
        return SaleSubmitSuccess(data);
      case Error(:final failure):
        return SaleSubmitFailure(failure);
    }
  }

  /// Submits a return for [saleId].
  Future<SaleSubmitResult> returnSale({
    required String saleId,
    required List<SaleReturnLine> lines,
  }) async {
    state = true;
    final result = await _repository.returnSale(saleId: saleId, lines: lines);
    state = false;
    switch (result) {
      case Success(:final data):
        await _ref.read(cashShiftControllerProvider.notifier).loadCurrent();
        return SaleSubmitSuccess(data);
      case Error(:final failure):
        return SaleSubmitFailure(failure);
    }
  }
}

/// Sale-submission provider; `bool` state = busy flag.
final saleSubmitControllerProvider =
    StateNotifierProvider<SaleSubmitController, bool>((ref) {
      return SaleSubmitController(ref.watch(posRepositoryProvider), ref);
    });

/// Loads recent sales for the current shift (for the returns picker). Family
/// keyed by shift id.
final shiftSalesProvider =
    FutureProvider.family<List<Sale>, String>((ref, shiftId) async {
      final repository = ref.watch(posRepositoryProvider);
      final result = await repository.listSales(
        shiftId: shiftId,
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

/// Loads a single sale (with lines + payments) by id, for the returns dialog.
final saleDetailProvider =
    FutureProvider.family<Sale, String>((ref, id) async {
      final repository = ref.watch(posRepositoryProvider);
      final result = await repository.getSale(id);
      switch (result) {
        case Success(:final data):
          return data;
        case Error(:final failure):
          throw failure;
      }
    });

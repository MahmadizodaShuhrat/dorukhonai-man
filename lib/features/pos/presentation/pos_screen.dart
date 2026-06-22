import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/status_colors.dart';
import '../../../core/api/api_result.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/app_data_table.dart';
import '../../../shared/app_toast.dart';
import '../../branch/presentation/branch_provider.dart';
import '../../products/data/product_models.dart';
import '../../products/data/products_repository.dart';
import '../../products/presentation/product_picker.dart';
import '../data/pos_models.dart';
import 'close_shift_dialog.dart';
import 'payment_dialog.dart';
import 'pos_providers.dart';
import 'receipt_view.dart';
import 'returns_dialog.dart';

/// POS / Касса register (TZ_03 §C.2) — the keyboard-first, two-pane desktop
/// register.
///
/// Before a shift is open it shows a centred "Кушодани смена" panel
/// (openingCash). Once open it shows the two-pane register:
///   * LEFT (≈65%): a focused scan/search field (a USB 1D scanner types a code
///     then Enter → exact by-barcode add; a miss opens the picker) and the cart
///     as an [AppDataTable] (Ном · Миқдор stepper with type-a-qty · Нарх · Ҷамъ
///     · ҳазф).
///   * RIGHT (≈35%): a totals panel (subtotal · discount · BIG total) and a
///     payment panel (method + a big ПАРДОХТ button).
///
/// Keyboard map (TZ_03 §D POS-local): F2 focus scan · F4 discount · F9 pay ·
/// Del remove selected row · F7 returns · F10 close shift · Esc clear scan.
/// Quantity also adjusts with `+`/`-` on the selected row.
///
/// All sale/shift logic stays in the existing controllers + repository; this is
/// a UI redesign only. After PAY the server-returned receipt is shown (it may
/// split a product across several FEFO [SaleLine]s), the cart clears, and the
/// scan field is refocused.
class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final _scanController = TextEditingController();
  final _scanFocus = FocusNode();
  final _discountController = TextEditingController();

  /// Index of the cart line highlighted for the Del/`+`/`-` hotkeys.
  int? _selectedRow;

  @override
  void initState() {
    super.initState();
    // Resume any open shift for this session on first build. The REAL branch id
    // (from the session / `GET /branches`, TZ_05 FW1) is seeded reactively in
    // build() via the [currentBranchIdProvider] listener below.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cashShiftControllerProvider.notifier).loadCurrent();
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _scanFocus.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _focusScan() {
    _scanFocus.requestFocus();
    _scanController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _scanController.text.length,
    );
  }

  // ---- Cart operations (delegated to the controller; no logic in widgets) ----

  /// USB-scanner Enter (or manual submit): an exact barcode hit adds to the
  /// cart; otherwise open the picker pre-seeded with the typed term.
  Future<void> _onScanSubmitted(String value) async {
    final code = value.trim();
    _scanController.clear();
    if (code.isEmpty) {
      _focusScan();
      return;
    }
    final repo = ref.read(productsRepositoryProvider);
    final byBarcode = await repo.getByBarcode(code);
    if (!mounted) return;
    switch (byBarcode) {
      case Success(:final data):
        await _addProduct(data);
      case Error():
        // Not an exact barcode → fall back to the picker for a manual choice.
        await _openPicker();
    }
    if (mounted) _focusScan();
  }

  Future<void> _openPicker() async {
    final product = await ProductPickerDialog.show(context);
    if (product == null || !mounted) return;
    await _addProduct(product);
    if (mounted) _focusScan();
  }

  /// Adds [product] to the cart. Prescription-only (`℞`) products require an
  /// explicit confirmation first (TZ_03 §C.2 / TZ_00 §1.2 rule 5).
  Future<void> _addProduct(Product product) async {
    if (product.rxRequired) {
      final confirmed = await _confirmRx(product);
      if (!confirmed || !mounted) return;
    }
    ref.read(posCartControllerProvider.notifier).addProduct(product);
  }

  Future<bool> _confirmRx(Product product) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Доруи ретсептӣ'),
        content: Text(
          '«${product.name}» доруи ретсептӣ (℞) аст. '
          'Илова кардан ба сабадро тасдиқ мекунед?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Бекор'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Тасдиқ'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  void _changeQty(int index, double delta) {
    ref.read(posCartControllerProvider.notifier).changeQuantity(index, delta);
  }

  void _setQty(int index, double quantity) {
    ref.read(posCartControllerProvider.notifier).setQuantity(index, quantity);
  }

  void _removeLine(int index) {
    ref.read(posCartControllerProvider.notifier).removeAt(index);
    setState(() => _selectedRow = null);
  }

  void _removeSelected() {
    final index = _selectedRow;
    if (index != null) _removeLine(index);
  }

  /// `+`/`-` hotkeys adjust the selected row's quantity (TZ_03 §C.2).
  void _bumpSelected(double delta) {
    final index = _selectedRow;
    if (index != null) _changeQty(index, delta);
  }

  void _applyDiscount() {
    final value =
        double.tryParse(_discountController.text.trim().replaceAll(',', '.')) ??
        0;
    ref.read(posCartControllerProvider.notifier).setDiscount(value);
  }

  /// F4: open a quick discount entry dialog for fast keyboard entry.
  void _focusDiscount() {
    showDialog<void>(
      context: context,
      builder: (ctx) => _DiscountDialog(
        initial: ref.read(posCartControllerProvider).discount,
        onApply: (value) {
          _discountController.text = _trimNum(value);
          ref.read(posCartControllerProvider.notifier).setDiscount(value);
        },
      ),
    ).then((_) => _focusScan());
  }

  // ---- Sale submission ----

  Future<void> _pay() async {
    final cart = ref.read(posCartControllerProvider);
    if (cart.isEmpty) {
      AppToast.error(context, 'Сабад холӣ аст');
      return;
    }
    final result = await PaymentDialog.show(context, cart.total);
    if (result == null || !mounted) return;
    final submit = await ref
        .read(saleSubmitControllerProvider.notifier)
        .submit(payments: result.payments, discount: cart.discount);
    if (!mounted) return;
    switch (submit) {
      case SaleSubmitSuccess(:final sale):
        ref.read(posCartControllerProvider.notifier).clear();
        _discountController.clear();
        setState(() => _selectedRow = null);
        await ReceiptDialog.show(context, sale);
        _focusScan();
      case SaleSubmitPendingOffline(:final sale):
        // Offline sale: queued for sync, receipt still prints.
        ref.read(posCartControllerProvider.notifier).clear();
        _discountController.clear();
        setState(() => _selectedRow = null);
        if (mounted) {
          AppToast.info(
            context,
            'Офлайн: фурӯш дар навбати синхрон сабт шуд (чоп шуд).',
          );
        }
        if (mounted) await ReceiptDialog.show(context, sale);
        _focusScan();
      case SaleSubmitFailure(:final failure):
        AppToast.error(context, failure.message);
    }
  }

  // ---- Shift actions ----

  Future<void> _openShift() async {
    final opening = await _OpeningCashDialog.show(context);
    if (opening == null || !mounted) return;
    // Ensure the REAL branch id is resolved before opening (TZ_05 FW1): await
    // the branch lookup so we never send an empty/`Guid.Empty` branchId.
    final branch = await ref.read(currentBranchProvider.future);
    if (!mounted) return;
    final controller = ref.read(cashShiftControllerProvider.notifier);
    if (branch != null && branch.id.isNotEmpty) {
      controller.setBranchId(branch.id);
    }
    final failure = await controller.openShift(opening);
    if (!mounted) return;
    if (failure != null) {
      AppToast.error(context, failure.message);
    } else {
      _focusScan();
    }
  }

  Future<void> _closeShift() async {
    final shift = ref.read(cashShiftControllerProvider).shift;
    if (shift == null) return;
    await CloseShiftDialog.show(context, shift);
  }

  Future<void> _openReturns() async {
    final shift = ref.read(cashShiftControllerProvider).shift;
    if (shift == null) return;
    await ReturnsDialog.show(context, shift.id);
    if (mounted) _focusScan();
  }

  @override
  Widget build(BuildContext context) {
    // Adopt the REAL branch id as soon as it resolves (TZ_05 FW1). Reloading
    // the current shift against the real branch keeps the dashboard KPI and POS
    // in sync (no Guid.Empty / 'default').
    ref.listen<String?>(currentBranchIdProvider, (previous, next) {
      if (next == null || next.isEmpty) return;
      if (ref.read(cashShiftControllerProvider).branchId == next) return;
      ref.read(cashShiftControllerProvider.notifier)
        ..setBranchId(next)
        ..loadCurrent();
    });

    final shiftState = ref.watch(cashShiftControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: shiftState.isLoading && shiftState.shift == null
          ? const Center(child: CircularProgressIndicator())
          : shiftState.hasOpenShift
          ? _buildRegister(shiftState.shift!)
          : _OpenShiftPanel(
              state: shiftState,
              onOpen: shiftState.isLoading ? null : _openShift,
            ),
    );
  }

  /// The full two-pane register, scoped under a slightly larger text theme
  /// (TZ_03 §B.3 "POS override").
  Widget _buildRegister(CashShift shift) {
    final cart = ref.watch(posCartControllerProvider);
    final isSaving = ref.watch(saleSubmitControllerProvider);
    final theme = Theme.of(context);

    // POS-local hotkeys (TZ_03 §D). Scoped so they never clash with the global
    // Ctrl+1..6 / Ctrl+K bindings in the shell.
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.f2): _focusScan,
        const SingleActivator(LogicalKeyboardKey.f4): _focusDiscount,
        const SingleActivator(LogicalKeyboardKey.f9): _pay,
        const SingleActivator(LogicalKeyboardKey.f7): _openReturns,
        const SingleActivator(LogicalKeyboardKey.f10): _closeShift,
        const SingleActivator(LogicalKeyboardKey.delete): _removeSelected,
        const SingleActivator(LogicalKeyboardKey.add): () => _bumpSelected(1),
        const SingleActivator(LogicalKeyboardKey.numpadAdd): () =>
            _bumpSelected(1),
        const SingleActivator(LogicalKeyboardKey.minus): () =>
            _bumpSelected(-1),
        const SingleActivator(LogicalKeyboardKey.numpadSubtract): () =>
            _bumpSelected(-1),
      },
      child: Focus(
        autofocus: true,
        child: AbsorbPointer(
          absorbing: isSaving,
          child: Theme(
            // POS register keeps a larger type scale (cart rows / total / pay).
            data: theme.copyWith(visualDensity: VisualDensity.standard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RegisterHeader(
                  shift: shift,
                  onReturns: _openReturns,
                  onCloseShift: _closeShift,
                ),
                if (isSaving) const LinearProgressIndicator(minHeight: 2),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // LEFT pane (≈65%): scan bar + cart.
                      Expanded(
                        flex: 65,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _ScanBar(
                              controller: _scanController,
                              focusNode: _scanFocus,
                              onSubmitted: _onScanSubmitted,
                              onSearch: _openPicker,
                            ),
                            Expanded(child: _buildCart(cart)),
                            const _FKeyHintBar(),
                          ],
                        ),
                      ),
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: theme.colorScheme.outlineVariant,
                      ),
                      // RIGHT pane (≈35%): totals + payment.
                      Expanded(
                        flex: 35,
                        child: _CheckoutPanel(
                          cart: cart,
                          discountController: _discountController,
                          onApplyDiscount: _applyDiscount,
                          onPay: _pay,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCart(CartState cart) {
    final theme = Theme.of(context);
    if (cart.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: 56,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Сабад холӣ. Штрих-кодро скан кунед ё ҷустуҷӯ кунед.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: AppDataTable(
        minWidth: 560,
        columns: const [
          DataColumn2(label: Text('#'), fixedWidth: 40),
          DataColumn2(label: Text('Дору'), size: ColumnSize.L),
          DataColumn2(label: Text('Миқдор'), fixedWidth: 200),
          DataColumn2(label: Text('Нарх'), numeric: true),
          DataColumn2(label: Text('Ҷамъ'), numeric: true),
          DataColumn2(label: Text(''), fixedWidth: 56),
        ],
        rows: [
          for (var i = 0; i < cart.items.length; i++)
            DataRow2(
              selected: _selectedRow == i,
              onSelectChanged: (_) => setState(() => _selectedRow = i),
              cells: [
                DataCell(Text('${i + 1}')),
                DataCell(
                  Row(
                    children: [
                      if (cart.items[i].rxRequired) ...[
                        Tooltip(
                          message: 'Доруи ретсептӣ',
                          child: Text(
                            '℞',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: StatusColors.of(context).warn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          cart.items[i].name,
                          style: theme.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  _QtyStepper(
                    quantity: cart.items[i].quantity,
                    onDecrement: () => _changeQty(i, -1),
                    onIncrement: () => _changeQty(i, 1),
                    onSet: (value) => _setQty(i, value),
                  ),
                ),
                DataCell(
                  Text(
                    Formatters.money(cart.items[i].unitPrice),
                    style: _tabular(theme),
                  ),
                ),
                DataCell(
                  Text(
                    Formatters.money(cart.items[i].lineTotal),
                    style: _tabular(theme).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataCell(
                  IconButton(
                    tooltip: 'Ҳазф',
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _removeLine(i),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  TextStyle _tabular(ThemeData theme) =>
      (theme.textTheme.titleMedium ?? const TextStyle()).copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  String _trimNum(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';
}

/// Slim register header (TZ_03 §C.2 top strip): shift state + counts.
class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader({
    required this.shift,
    required this.onReturns,
    required this.onCloseShift,
  });

  final CashShift shift;
  final VoidCallback onReturns;
  final VoidCallback onCloseShift;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = StatusColors.of(context);
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: status.ok),
          const SizedBox(width: 8),
          Text(
            'Смена кушода',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Кушода шуд: ${Formatters.dateTime(shift.openedAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            'Фурӯши смена: ${Formatters.money(shift.totalSales)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            tooltip: 'Бозгашти фурӯш (F7)',
            icon: const Icon(Icons.assignment_return_outlined),
            onPressed: onReturns,
          ),
          IconButton(
            tooltip: 'Бастани смена (F10)',
            icon: const Icon(Icons.lock_outline),
            onPressed: onCloseShift,
          ),
        ],
      ),
    );
  }
}

/// Top scan/search field (left pane) — always focused so a USB 1D scanner's
/// keystrokes land here; Enter ends the barcode and triggers an exact lookup.
class _ScanBar extends StatelessWidget {
  const _ScanBar({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onSearch,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              style: Theme.of(context).textTheme.titleMedium,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              decoration: const InputDecoration(
                hintText: 'Штрих-кодро скан кунед ё ном ворид кунед…  (F2)',
                prefixIcon: Icon(Icons.qr_code_scanner),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: onSearch,
            icon: const Icon(Icons.search),
            label: const Text('Ҷустуҷӯ'),
          ),
        ],
      ),
    );
  }
}

/// Quantity stepper used in a cart row: `-` / a tap-to-type field / `+`. The
/// field accepts a typed quantity (TZ_03 §C.2: "type-a-quantity, not just +/-").
class _QtyStepper extends StatefulWidget {
  const _QtyStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    required this.onSet,
  });

  final double quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final ValueChanged<double> onSet;

  @override
  State<_QtyStepper> createState() => _QtyStepperState();
}

class _QtyStepperState extends State<_QtyStepper> {
  late final TextEditingController _controller;
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.quantity));
    _focus.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(_QtyStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reflect external changes (the +/- buttons or `+`/`-` hotkeys) into the
    // field while it is not being edited.
    if (!_focus.hasFocus && widget.quantity != oldWidget.quantity) {
      _controller.text = _format(widget.quantity);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focus.hasFocus) _commit();
  }

  void _commit() {
    final parsed = double.tryParse(_controller.text.trim().replaceAll(',', '.'));
    if (parsed != null && parsed != widget.quantity) {
      widget.onSet(parsed);
    } else {
      _controller.text = _format(widget.quantity);
    }
  }

  String _format(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Кам',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 40, height: 40),
          icon: const Icon(Icons.remove_circle_outline, size: 22),
          onPressed: widget.onDecrement,
        ),
        SizedBox(
          width: 56,
          child: TextField(
            controller: _controller,
            focusNode: _focus,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _commit(),
          ),
        ),
        IconButton(
          tooltip: 'Зиёд',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 40, height: 40),
          icon: const Icon(Icons.add_circle_outline, size: 22),
          onPressed: widget.onIncrement,
        ),
      ],
    );
  }
}

/// Right pane: a totals panel (subtotal · discount · BIG total) over a payment
/// panel (method hints + a big ПАРДОХТ button).
class _CheckoutPanel extends StatelessWidget {
  const _CheckoutPanel({
    required this.cart,
    required this.discountController,
    required this.onApplyDiscount,
    required this.onPay,
  });

  final CartState cart;
  final TextEditingController discountController;
  final VoidCallback onApplyDiscount;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ҲИСОБ',
            style: theme.textTheme.labelLarge?.copyWith(
              letterSpacing: 0.6,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _TotalRow(
            label: 'Зерҷамъ',
            value: Formatters.money(cart.subtotal),
          ),
          const SizedBox(height: 12),
          // Discount field (F4 also opens a quick dialog).
          TextField(
            controller: discountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            onChanged: (_) => onApplyDiscount(),
            onSubmitted: (_) => onApplyDiscount(),
            decoration: const InputDecoration(
              labelText: 'Тахфиф (F4)',
              prefixIcon: Icon(Icons.percent),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 8),
          // BIG total.
          Text(
            'ҲАМАГӢ',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            Formatters.money(cart.total),
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const Spacer(),
          Text(
            'Тарзи пардохт',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _MethodHint(label: 'Нақд', icon: Icons.payments_outlined),
              _MethodHint(label: 'Корт', icon: Icons.credit_card),
              _MethodHint(
                label: 'Қарз',
                icon: Icons.account_balance_wallet_outlined,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 64,
            child: FilledButton.icon(
              onPressed: onPay,
              style: FilledButton.styleFrom(
                textStyle: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              icon: const Icon(Icons.point_of_sale, size: 26),
              label: const Text('Пардохт (F9)'),
            ),
          ),
        ],
      ),
    );
  }
}

/// One label/value row in the totals block.
class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// Static tender-method hint chip (the actual method is chosen in the payment
/// dialog, which already supports cash/card/credit).
class _MethodHint extends StatelessWidget {
  const _MethodHint({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 16, color: theme.colorScheme.primary),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: theme.colorScheme.outlineVariant),
    );
  }
}

/// F-key hint bar shown along the bottom of the left pane (TZ_03 §C.2).
class _FKeyHintBar extends StatelessWidget {
  const _FKeyHintBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: const [
          _Hint(keyLabel: 'F2', action: 'Ҷустуҷӯ'),
          _Hint(keyLabel: 'F4', action: 'Тахфиф'),
          _Hint(keyLabel: 'F9', action: 'Пардохт'),
          _Hint(keyLabel: 'Del', action: 'Ҳазф'),
          _Hint(keyLabel: '+/−', action: 'Миқдор'),
          _Hint(keyLabel: 'F7', action: 'Бозгашт'),
          _Hint(keyLabel: 'F10', action: 'Бастани смена'),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.keyLabel, required this.action});

  final String keyLabel;
  final String action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Text(
            keyLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          action,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Open-shift panel shown when no shift is open (TZ_03 §C.2): a centred card
/// with just the opening cash (no typed "Филиал (ID)" — single branch implicit).
class _OpenShiftPanel extends StatelessWidget {
  const _OpenShiftPanel({required this.state, required this.onOpen});

  final CashShiftState state;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Card(
          elevation: 0,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.point_of_sale,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Смена кушода нашудааст',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Барои оғози фурӯш сменаро кушоед.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (state.failure != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    state.failure!.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Кушодани смена'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Prompts for the opening cash amount when opening a shift.
class _OpeningCashDialog extends StatefulWidget {
  const _OpeningCashDialog();

  static Future<double?> show(BuildContext context) {
    return showDialog<double>(
      context: context,
      builder: (_) => const _OpeningCashDialog(),
    );
  }

  @override
  State<_OpeningCashDialog> createState() => _OpeningCashDialogState();
}

class _OpeningCashDialogState extends State<_OpeningCashDialog> {
  final _controller = TextEditingController(text: '0');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final value = double.parse(_controller.text.trim().replaceAll(',', '.'));
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Кушодани смена'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Нақди ибтидоӣ *',
            prefixIcon: Icon(Icons.payments_outlined),
            border: OutlineInputBorder(),
          ),
          validator: (v) {
            final parsed = double.tryParse(
              (v ?? '').trim().replaceAll(',', '.'),
            );
            if (parsed == null) return 'Рақами дуруст ворид кунед';
            if (parsed < 0) return 'Манфӣ шуда наметавонад';
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Бекор'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Кушодан')),
      ],
    );
  }
}

/// Quick cart-level discount entry (F4).
class _DiscountDialog extends StatefulWidget {
  const _DiscountDialog({required this.initial, required this.onApply});

  final double initial;
  final ValueChanged<double> onApply;

  @override
  State<_DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<_DiscountDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initial == 0 ? '' : _trimNum(widget.initial),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value =
        double.tryParse(_controller.text.trim().replaceAll(',', '.')) ?? 0;
    widget.onApply(value);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Тахфиф'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Маблағи тахфиф',
          prefixIcon: Icon(Icons.percent),
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Бекор'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Татбиқ')),
      ],
    );
  }

  String _trimNum(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';
}

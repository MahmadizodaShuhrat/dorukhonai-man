import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/utils/formatters.dart';
import '../../products/data/product_models.dart';
import '../../products/data/products_repository.dart';
import '../../products/presentation/product_picker.dart';
import '../data/pos_models.dart';
import 'close_shift_dialog.dart';
import 'payment_dialog.dart';
import 'pos_providers.dart';
import 'receipt_view.dart';
import 'returns_dialog.dart';

/// POS / Касса screen (TZ §3.2, Module 5).
///
/// When no shift is open it shows the open-shift panel (branch id + opening
/// cash). Once open it shows the sale screen: a focused scan/search field, the
/// cart as a [DataTable2] with +/- and remove, a big TOTAL, a discount field,
/// a payment action, plus close-shift and returns actions in the app bar.
///
/// Desktop hotkeys (TZ §3.2): F2 focus scan, F4 discount, F9 pay, Del remove
/// the selected line.
class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final _scanController = TextEditingController();
  final _scanFocus = FocusNode();
  final _discountController = TextEditingController();

  /// Index of the cart line highlighted for the Del hotkey.
  int? _selectedRow;

  @override
  void initState() {
    super.initState();
    // Try to load any open shift for this session on first build.
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

  /// USB-scanner Enter (or manual submit): exact barcode hit adds to the cart;
  /// otherwise open the picker pre-seeded with the typed term.
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
        _addProduct(data);
      case Error():
        // Not an exact barcode → fall back to the picker for a manual choice.
        await _openPicker();
    }
    _focusScan();
  }

  Future<void> _openPicker() async {
    final product = await ProductPickerDialog.show(context);
    if (product == null || !mounted) return;
    _addProduct(product);
  }

  void _addProduct(Product product) {
    ref.read(posCartControllerProvider.notifier).addProduct(product);
  }

  void _changeQty(int index, double delta) {
    ref.read(posCartControllerProvider.notifier).changeQuantity(index, delta);
  }

  void _removeLine(int index) {
    ref.read(posCartControllerProvider.notifier).removeAt(index);
    setState(() => _selectedRow = null);
  }

  void _removeSelected() {
    final index = _selectedRow;
    if (index != null) _removeLine(index);
  }

  void _applyDiscount() {
    final value =
        double.tryParse(_discountController.text.trim().replaceAll(',', '.')) ??
        0;
    ref.read(posCartControllerProvider.notifier).setDiscount(value);
  }

  void _focusDiscount() {
    // F4: open a quick discount entry dialog for fast keyboard entry.
    showDialog<void>(
      context: context,
      builder: (ctx) => _DiscountDialog(
        initial: ref.read(posCartControllerProvider).discount,
        onApply: (value) {
          _discountController.text = _trimNum(value);
          ref.read(posCartControllerProvider.notifier).setDiscount(value);
        },
      ),
    );
  }

  // ---- Sale submission ----

  Future<void> _pay() async {
    final cart = ref.read(posCartControllerProvider);
    if (cart.isEmpty) {
      _showSnack('Сабад холӣ аст', isError: true);
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
        await ReceiptDialog.show(context, sale);
        _focusScan();
      case SaleSubmitFailure(:final failure):
        _showSnack(failure.message, isError: true);
    }
  }

  // ---- Shift actions ----

  Future<void> _openShift() async {
    final shiftState = ref.read(cashShiftControllerProvider);
    if (shiftState.branchId.isEmpty) {
      _showSnack('Филиалро ворид кунед', isError: true);
      return;
    }
    final opening = await _OpeningCashDialog.show(context);
    if (opening == null || !mounted) return;
    final failure = await ref
        .read(cashShiftControllerProvider.notifier)
        .openShift(opening);
    if (!mounted) return;
    if (failure != null) {
      _showSnack(failure.message, isError: true);
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
  }

  void _showSnack(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shiftState = ref.watch(cashShiftControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Касса'),
        actions: [
          if (shiftState.hasOpenShift) ...[
            IconButton(
              tooltip: 'Бозгашти фурӯш',
              icon: const Icon(Icons.assignment_return_outlined),
              onPressed: _openReturns,
            ),
            IconButton(
              tooltip: 'Бастани смена',
              icon: const Icon(Icons.lock_outline),
              onPressed: _closeShift,
            ),
          ],
        ],
      ),
      body: shiftState.isLoading && shiftState.shift == null
          ? const Center(child: CircularProgressIndicator())
          : shiftState.hasOpenShift
              ? _buildSale(shiftState.shift!)
              : _OpenShiftPanel(
                  state: shiftState,
                  onBranchChanged: (v) => ref
                      .read(cashShiftControllerProvider.notifier)
                      .setBranchId(v),
                  onOpen: _openShift,
                ),
    );
  }

  Widget _buildSale(CashShift shift) {
    final cart = ref.watch(posCartControllerProvider);
    final isSaving = ref.watch(saleSubmitControllerProvider);

    // Desktop hotkeys: F2 scan, F4 discount, F9 pay, Del remove selected.
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.f2): _focusScan,
        const SingleActivator(LogicalKeyboardKey.f4): _focusDiscount,
        const SingleActivator(LogicalKeyboardKey.f9): _pay,
        const SingleActivator(LogicalKeyboardKey.delete): _removeSelected,
      },
      child: Focus(
        autofocus: true,
        child: AbsorbPointer(
          absorbing: isSaving,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ScanBar(
                controller: _scanController,
                focusNode: _scanFocus,
                onSubmitted: _onScanSubmitted,
                onSearch: _openPicker,
              ),
              if (isSaving) const LinearProgressIndicator(minHeight: 2),
              Expanded(child: _buildCart(cart)),
              _CheckoutBar(
                cart: cart,
                shift: shift,
                discountController: _discountController,
                onApplyDiscount: _applyDiscount,
                onPay: _pay,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCart(CartState cart) {
    if (cart.isEmpty) {
      return const Center(
        child: Text('Сабад холӣ. Штрих-кодро скан кунед ё ҷустуҷӯ кунед.'),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 720,
        showCheckboxColumn: false,
        columns: const [
          DataColumn2(label: Text('Дору'), size: ColumnSize.L),
          DataColumn2(label: Text('Миқдор')),
          DataColumn2(label: Text('Нарх'), numeric: true),
          DataColumn2(label: Text('Ҷамъ'), numeric: true),
          DataColumn2(label: Text(''), size: ColumnSize.S),
        ],
        rows: [
          for (var i = 0; i < cart.items.length; i++)
            DataRow2(
              selected: _selectedRow == i,
              onSelectChanged: (_) => setState(() => _selectedRow = i),
              cells: [
                DataCell(Text(cart.items[i].name)),
                DataCell(_QtyStepper(
                  quantity: cart.items[i].quantity,
                  onDecrement: () => _changeQty(i, -1),
                  onIncrement: () => _changeQty(i, 1),
                )),
                DataCell(Text(Formatters.money(cart.items[i].unitPrice))),
                DataCell(Text(Formatters.money(cart.items[i].lineTotal))),
                DataCell(
                  IconButton(
                    tooltip: 'Ҳазф',
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () => _removeLine(i),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _trimNum(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';
}

/// Top scan/search field — always focused so a USB 1D scanner's keystrokes land
/// here; Enter ends the barcode and triggers an exact lookup.
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

/// Quantity +/- stepper used in a cart row.
class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final double quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Кам',
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.remove_circle_outline, size: 20),
          onPressed: onDecrement,
        ),
        Text(
          quantity == quantity.roundToDouble()
              ? quantity.toStringAsFixed(0)
              : '$quantity',
        ),
        IconButton(
          tooltip: 'Зиёд',
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.add_circle_outline, size: 20),
          onPressed: onIncrement,
        ),
      ],
    );
  }
}

/// Bottom checkout bar: discount entry, the big TOTAL, the shift's running
/// sales figure, and the PAY button (F9).
class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.cart,
    required this.shift,
    required this.discountController,
    required this.onApplyDiscount,
    required this.onPay,
  });

  final CartState cart;
  final CashShift shift;
  final TextEditingController discountController;
  final VoidCallback onApplyDiscount;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 8,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 180,
                child: TextField(
                  controller: discountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ҲАМАГӢ: ${Formatters.money(cart.total)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Смена: ${Formatters.money(shift.totalSales)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: onPay,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 18,
                  ),
                ),
                icon: const Icon(Icons.point_of_sale),
                label: const Text('Пардохт (F9)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Open-shift panel shown when no shift is open: branch id + opening cash.
class _OpenShiftPanel extends StatelessWidget {
  const _OpenShiftPanel({
    required this.state,
    required this.onBranchChanged,
    required this.onOpen,
  });

  final CashShiftState state;
  final ValueChanged<String> onBranchChanged;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Card(
          margin: const EdgeInsets.all(24),
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
                const SizedBox(height: 24),
                TextField(
                  onChanged: onBranchChanged,
                  decoration: const InputDecoration(
                    labelText: 'Филиал (ID) *',
                    prefixIcon: Icon(Icons.store_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                if (state.failure != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    state.failure!.message,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: state.isLoading ? null : onOpen,
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
    final value =
        double.parse(_controller.text.trim().replaceAll(',', '.'));
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
        FilledButton(
          onPressed: _submit,
          child: const Text('Кушодан'),
        ),
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

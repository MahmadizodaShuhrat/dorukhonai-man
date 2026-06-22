import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/app_toast.dart';
import '../../../shared/empty_state.dart';
import '../../../shared/entity_picker.dart';
import '../../../shared/loading_state.dart';
import '../../products/data/product_models.dart';
import '../../products/presentation/product_picker.dart';
import '../../reference/presentation/reference_providers.dart';
import '../data/receipt_models.dart';
import 'receipts_list_screen.dart' show ReceiptStatusChip, statusLabel;
import 'receipts_provider.dart';

/// Full-page goods-receipt editor (Приход, TZ_03 §C.4).
///
/// Replaces the old stacked per-line dialogs with a single page: a header
/// (supplier via [EntityPicker], branch, date) over an INLINE-EDITABLE lines
/// table. A row is added by picking/scanning a product, then quantity / серия /
/// мӯҳлат / нархи харид / нархи фурӯш are edited in-row. A running total updates
/// live; the bottom action bar saves a draft, posts (Тасдиқ), or cancels.
/// Posted/Cancelled receipts render read-only.
class ReceiptEditScreen extends ConsumerStatefulWidget {
  const ReceiptEditScreen({super.key, this.receiptId});

  /// `null` → create mode; non-null → load and edit an existing receipt.
  final String? receiptId;

  @override
  ConsumerState<ReceiptEditScreen> createState() => _ReceiptEditScreenState();
}

class _ReceiptEditScreenState extends ConsumerState<ReceiptEditScreen> {
  /// Supplier id chosen via [EntityPicker] (was a typed-GUID field).
  String? _supplierId;
  final _branchId = TextEditingController();

  DateTime _date = DateTime.now();

  /// One editable draft per line; owns its own [TextEditingController]s.
  final List<_LineDraft> _drafts = [];

  /// Status of the loaded receipt; `null` until loaded / for a fresh create.
  ReceiptStatus? _status;
  String? _loadedId;
  String? _number;

  bool _isLoadingExisting = false;
  String? _loadError;
  bool _initialised = false;

  bool get _isExisting => widget.receiptId != null;
  bool get _isEditable => !_isExisting || _status == ReceiptStatus.draft;

  double get _runningTotal =>
      _drafts.fold<double>(0, (sum, d) => sum + d.lineTotal);

  @override
  void initState() {
    super.initState();
    if (_isExisting) _isLoadingExisting = true;
  }

  @override
  void dispose() {
    _branchId.dispose();
    for (final d in _drafts) {
      d.dispose();
    }
    super.dispose();
  }

  void _hydrateFrom(Receipt receipt) {
    _loadedId = receipt.id;
    _number = receipt.number;
    _status = receipt.status;
    _supplierId = receipt.supplierId.isEmpty ? null : receipt.supplierId;
    _branchId.text = receipt.branchId;
    _date = receipt.date;
    for (final d in _drafts) {
      d.dispose();
    }
    _drafts
      ..clear()
      ..addAll(
        receipt.lines.map(
          (l) => _LineDraft.fromLine(l)..attach(_onLineChanged),
        ),
      );
    _initialised = true;
    _isLoadingExisting = false;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  /// Opens the product picker (search or 1D-barcode scan) and appends a row.
  Future<void> _addLine() async {
    final product = await ProductPickerDialog.show(context);
    if (product == null || !mounted) return;
    setState(() {
      _drafts.add(_LineDraft.forProduct(product, onChanged: _onLineChanged));
    });
  }

  void _onLineChanged() => setState(() {});

  void _removeLine(int index) {
    setState(() {
      _drafts.removeAt(index).dispose();
    });
  }

  Future<void> _pickExpiry(int index) async {
    final draft = _drafts[index];
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.expiry,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => draft.expiry = picked);
  }

  Receipt _buildReceipt() {
    return Receipt(
      id: _loadedId ?? '',
      number: _number ?? '',
      supplierId: _supplierId ?? '',
      branchId: _branchId.text.trim(),
      date: _date,
      status: _status ?? ReceiptStatus.draft,
      lines: List.unmodifiable(_drafts.map((d) => d.toLine())),
      total: _runningTotal,
    );
  }

  /// Validates the whole document, returning the first problem or `null`.
  String? _validate() {
    if (_supplierId == null || _supplierId!.isEmpty) {
      return 'Таъминкунандаро интихоб кунед';
    }
    if (_branchId.text.trim().isEmpty) return 'Филиалро ворид кунед';
    if (_drafts.isEmpty) return 'Ҳадди ақал як сатр илова кунед';
    for (var i = 0; i < _drafts.length; i++) {
      final problem = _drafts[i].validate();
      if (problem != null) return 'Сатри ${i + 1}: $problem';
    }
    return null;
  }

  Future<void> _saveDraft() async {
    final problem = _validate();
    if (problem != null) {
      AppToast.error(context, problem);
      return;
    }
    final controller = ref.read(receiptEditControllerProvider.notifier);
    final receipt = _buildReceipt();
    final result = _isExisting
        ? await controller.update(receipt)
        : await controller.create(receipt);
    _handleResult(result, successMessage: 'Приход ҳамчун лоиҳа нигоҳ дошта шуд');
  }

  Future<void> _post() async {
    // A brand-new receipt must be saved before it can be posted.
    if (!_isExisting || _loadedId == null) {
      AppToast.error(context, 'Аввал приходро нигоҳ доред');
      return;
    }
    final confirmed = await _confirm(
      title: 'Тасдиқи приход',
      body: 'Приход тасдиқ карда шавад? Баъди тасдиқ бақия нав мешавад.',
      confirmLabel: 'Тасдиқ',
    );
    if (confirmed != true) return;
    final result = await ref
        .read(receiptEditControllerProvider.notifier)
        .post(_loadedId!);
    _handleResult(result, successMessage: 'Приход тасдиқ шуд');
  }

  Future<void> _cancelReceipt() async {
    if (!_isExisting || _loadedId == null) {
      Navigator.of(context).pop();
      return;
    }
    final confirmed = await _confirm(
      title: 'Бекор кардани приход',
      body: 'Приход бекор карда шавад?',
      confirmLabel: 'Бекор кардан',
    );
    if (confirmed != true) return;
    final result = await ref
        .read(receiptEditControllerProvider.notifier)
        .cancel(_loadedId!);
    _handleResult(result, successMessage: 'Приход бекор шуд');
  }

  void _handleResult(
    ReceiptSaveResult result, {
    required String successMessage,
  }) {
    if (!mounted) return;
    switch (result) {
      case ReceiptSaveSuccess(:final receipt):
        setState(() => _hydrateFrom(receipt));
        AppToast.success(context, successMessage);
        // For terminal states (posted/cancelled) leave the editor.
        if (!receipt.status.isDraft) Navigator.of(context).pop();
      case ReceiptSaveFailure(:final failure):
        AppToast.error(context, failure.message);
    }
  }

  Future<bool?> _confirm({
    required String title,
    required String body,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Не'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Load the existing receipt once.
    if (_isExisting && !_initialised) {
      final async = ref.watch(receiptDetailProvider(widget.receiptId!));
      async.when(
        data: (receipt) {
          if (!_initialised) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _hydrateFrom(receipt));
            });
          }
        },
        loading: () {},
        error: (err, _) {
          if (_loadError == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _loadError = err is Failure ? err.message : err.toString();
                  _isLoadingExisting = false;
                });
              }
            });
          }
        },
      );
    }

    final isSaving = ref.watch(receiptEditControllerProvider);
    final busy = isSaving || _isLoadingExisting;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isExisting ? 'Приход ${_number ?? ''}'.trim() : 'Приход нав',
        ),
        actions: [
          if (_status != null) ...[
            Center(child: ReceiptStatusChip(status: _status!, dense: false)),
            const SizedBox(width: 16),
          ],
        ],
      ),
      body: _buildBody(busy),
      bottomNavigationBar: _loadError != null
          ? null
          : _ActionBar(
              total: _runningTotal,
              lineCount: _drafts.length,
              editable: _isEditable,
              isExisting: _isExisting,
              status: _status,
              busy: busy,
              onSaveDraft: _saveDraft,
              onPost: _post,
              onCancel: _cancelReceipt,
            ),
    );
  }

  Widget _buildBody(bool busy) {
    if (_loadError != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Хатогӣ',
        message: _loadError!,
        action: FilledButton.tonalIcon(
          onPressed: () {
            setState(() {
              _loadError = null;
              _isLoadingExisting = true;
            });
            ref.invalidate(receiptDetailProvider(widget.receiptId!));
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Аз нав'),
        ),
      );
    }
    if (_isLoadingExisting && !_initialised) {
      return const LoadingState();
    }

    final column = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            supplierId: _supplierId,
            onSupplierChanged: (id) => setState(() => _supplierId = id),
            branchId: _branchId,
            number: _number,
            date: _date,
            editable: _isEditable,
            onPickDate: _pickDate,
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
            child: Row(
              children: [
                Text(
                  'Сатрҳо (${_drafts.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (_isEditable)
                  FilledButton.tonalIcon(
                    onPressed: _addLine,
                    icon: const Icon(Icons.add),
                    label: const Text('Илова сатр / скан штрих-код'),
                  ),
              ],
            ),
          ),
          Expanded(child: _buildLines()),
        ],
      );

    final body = AbsorbPointer(absorbing: busy, child: column);

    // Ctrl+Enter adds a new line (TZ_03 §C.4 keyboard map). Only when editable.
    if (!_isEditable) return body;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true):
            _addLine,
      },
      // Autofocus so the page receives Ctrl+Enter even before a cell is
      // focused (e.g. to add the very first line on an empty receipt).
      child: Focus(autofocus: true, child: body),
    );
  }

  Widget _buildLines() {
    if (_drafts.isEmpty) {
      return EmptyState(
        icon: Icons.playlist_add,
        message: _isEditable
            ? 'Сатр нест. «Илова сатр»-ро пахш кунед ё штрих-код скан кунед.'
            : 'Дар ин приход сатр нест.',
      );
    }

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
      child: DataTable2(
        minWidth: 1000,
        fixedTopRows: 1,
        headingRowColor: WidgetStatePropertyAll(
          theme.colorScheme.surfaceContainer,
        ),
        headingRowHeight: 40,
        dataRowHeight: 56,
        dividerThickness: 1,
        showCheckboxColumn: false,
        columns: const [
          DataColumn2(label: Text('Дору'), size: ColumnSize.L),
          DataColumn2(label: Text('Миқдор'), numeric: true, fixedWidth: 96),
          DataColumn2(label: Text('Серия'), fixedWidth: 120),
          DataColumn2(label: Text('Мӯҳлат'), fixedWidth: 132),
          DataColumn2(label: Text('Нархи харид'), numeric: true, fixedWidth: 120),
          DataColumn2(label: Text('Нархи фурӯш'), numeric: true, fixedWidth: 120),
          DataColumn2(label: Text('Ҷамъ'), numeric: true, fixedWidth: 110),
          DataColumn2(label: Text(''), fixedWidth: 48),
        ],
        rows: [
          for (var i = 0; i < _drafts.length; i++)
            _buildLineRow(i, _drafts[i]),
        ],
      ),
    );
  }

  DataRow2 _buildLineRow(int index, _LineDraft draft) {
    final readOnly = !_isEditable;
    return DataRow2(
      specificRowHeight: 56,
      cells: [
        DataCell(
          Text(
            draft.productName ?? draft.productId,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(
          _CellField(
            controller: draft.quantity,
            enabled: !readOnly,
            numeric: true,
            textAlign: TextAlign.right,
          ),
        ),
        DataCell(
          _CellField(controller: draft.series, enabled: !readOnly),
        ),
        DataCell(
          _ExpiryCell(
            date: draft.expiry,
            enabled: !readOnly,
            onTap: () => _pickExpiry(index),
          ),
        ),
        DataCell(
          _CellField(
            controller: draft.purchasePrice,
            enabled: !readOnly,
            numeric: true,
            textAlign: TextAlign.right,
          ),
        ),
        DataCell(
          _CellField(
            controller: draft.salePrice,
            enabled: !readOnly,
            numeric: true,
            textAlign: TextAlign.right,
          ),
        ),
        DataCell(
          Align(
            alignment: Alignment.centerRight,
            child: Text(Formatters.money(draft.lineTotal)),
          ),
        ),
        DataCell(
          readOnly
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Ҳазфи сатр',
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () => _removeLine(index),
                ),
        ),
      ],
    );
  }
}

/// A mutable, controller-backed editable line. Owns the field controllers and
/// keeps the expiry date; converts to/from the immutable [ReceiptLine].
class _LineDraft {
  _LineDraft({
    this.id,
    required this.productId,
    this.productName,
    required this.expiry,
    required String quantity,
    required String series,
    required String purchasePrice,
    required String salePrice,
  }) : quantity = TextEditingController(text: quantity),
       series = TextEditingController(text: series),
       purchasePrice = TextEditingController(text: purchasePrice),
       salePrice = TextEditingController(text: salePrice);

  factory _LineDraft.fromLine(ReceiptLine line) => _LineDraft(
    id: line.id,
    productId: line.productId,
    productName: line.productName,
    expiry: line.expiryDate,
    quantity: _trimNum(line.quantity),
    series: line.seriesNumber,
    purchasePrice: _trimNum(line.purchasePrice),
    salePrice: _trimNum(line.salePrice),
  );

  factory _LineDraft.forProduct(
    Product product, {
    required VoidCallback onChanged,
  }) {
    final draft = _LineDraft(
      productId: product.id,
      productName: product.name,
      expiry: DateTime.now().add(const Duration(days: 365)),
      quantity: '',
      series: '',
      purchasePrice: '',
      salePrice: '',
    );
    draft.attach(onChanged);
    return draft;
  }

  final String? id;
  final String productId;
  final String? productName;
  DateTime expiry;

  final TextEditingController quantity;
  final TextEditingController series;
  final TextEditingController purchasePrice;
  final TextEditingController salePrice;

  /// Rebuilds the row (to refresh the live line/document total) on any edit.
  void attach(VoidCallback onChanged) {
    quantity.addListener(onChanged);
    purchasePrice.addListener(onChanged);
  }

  double get _qty => _parse(quantity.text) ?? 0;
  double get _purchase => _parse(purchasePrice.text) ?? 0;

  double get lineTotal => _qty * _purchase;

  /// First validation problem for this line, or `null` when valid.
  String? validate() {
    final qty = _parse(quantity.text);
    if (qty == null || qty <= 0) return 'миқдори дуруст ворид кунед';
    if (series.text.trim().isEmpty) return 'серияро ворид кунед';
    final purchase = _parse(purchasePrice.text);
    if (purchase == null || purchase < 0) return 'нархи харидро ворид кунед';
    final sale = _parse(salePrice.text);
    if (sale == null || sale < 0) return 'нархи фурӯшро ворид кунед';
    return null;
  }

  ReceiptLine toLine() => ReceiptLine(
    id: id,
    productId: productId,
    productName: productName,
    quantity: _parse(quantity.text) ?? 0,
    seriesNumber: series.text.trim(),
    expiryDate: expiry,
    purchasePrice: _parse(purchasePrice.text) ?? 0,
    salePrice: _parse(salePrice.text) ?? 0,
  );

  void dispose() {
    quantity.dispose();
    series.dispose();
    purchasePrice.dispose();
    salePrice.dispose();
  }
}

/// Parses a decimal allowing a comma separator (ru-locale input).
double? _parse(String value) =>
    double.tryParse(value.trim().replaceAll(',', '.'));

/// Renders a quantity/price without a trailing `.0` for whole numbers.
String _trimNum(double value) =>
    value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';

/// A compact in-cell text field used for inline-editable numeric/text columns.
class _CellField extends StatelessWidget {
  const _CellField({
    required this.controller,
    this.enabled = true,
    this.numeric = false,
    this.textAlign = TextAlign.start,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool numeric;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      textAlign: textAlign,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: numeric
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
          : null,
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 13.5),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(),
      ),
    );
  }
}

/// In-cell expiry display + date picker. Compact so it never overflows the
/// narrow Мӯҳлат column; tappable when the receipt is editable.
class _ExpiryCell extends StatelessWidget {
  const _ExpiryCell({
    required this.date,
    required this.enabled,
    required this.onTap,
  });

  final DateTime date;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.event_busy,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            Formatters.date(date),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.5),
          ),
        ),
      ],
    );
    if (!enabled) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: content,
      ),
    );
  }
}

/// Supplier / branch / number / date header.
class _Header extends ConsumerWidget {
  const _Header({
    required this.supplierId,
    required this.onSupplierChanged,
    required this.branchId,
    required this.number,
    required this.date,
    required this.editable,
    required this.onPickDate,
  });

  /// Supplier id chosen via [EntityPicker] (name → id), `null` when unset.
  final String? supplierId;
  final ValueChanged<String?> onSupplierChanged;
  final TextEditingController branchId;
  final String? number;
  final DateTime date;
  final bool editable;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: EntityPicker(
              label: 'Таъминкунанда',
              icon: Icons.local_shipping_outlined,
              optionsProvider: (s) => supplierOptionsProvider(s),
              selectedId: supplierId,
              enabled: editable,
              isRequired: true,
              onChanged: onSupplierChanged,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: branchId,
              enabled: editable,
              decoration: const InputDecoration(
                labelText: 'Филиал *',
                prefixIcon: Icon(Icons.store_outlined),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Рақам',
                prefixIcon: Icon(Icons.tag),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              child: Text(
                (number == null || number!.isEmpty) ? '— нав —' : number!,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: editable ? onPickDate : null,
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(Formatters.date(date)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom action bar: running total + line count + Save Draft / Post / Cancel.
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.total,
    required this.lineCount,
    required this.editable,
    required this.isExisting,
    required this.status,
    required this.busy,
    required this.onSaveDraft,
    required this.onPost,
    required this.onCancel,
  });

  final double total;
  final int lineCount;
  final bool editable;
  final bool isExisting;
  final ReceiptStatus? status;
  final bool busy;
  final VoidCallback onSaveDraft;
  final VoidCallback onPost;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canCancel =
        isExisting && status != null && status != ReceiptStatus.cancelled;
    return Material(
      elevation: 8,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            children: [
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ҷамъи харид: ${Formatters.money(total)}',
                      style: theme.textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Сатрҳо: $lineCount',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (canCancel) ...[
                OutlinedButton.icon(
                  onPressed: busy ? null : onCancel,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Бекор'),
                ),
                const SizedBox(width: 8),
              ],
              if (editable)
                FilledButton.tonalIcon(
                  onPressed: busy ? null : onSaveDraft,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Нигоҳ доштан (Лоиҳа)'),
                ),
              if (editable && isExisting) ...[
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: busy ? null : onPost,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Тасдиқ'),
                ),
              ],
              if (!editable && status != null)
                Text(
                  statusLabel(status!),
                  style: theme.textTheme.titleMedium,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

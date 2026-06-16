import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/utils/formatters.dart';
import '../../products/data/product_models.dart';
import '../../products/presentation/product_picker.dart';
import '../data/receipt_models.dart';
import 'receipt_line_dialog.dart';
import 'receipts_list_screen.dart' show statusLabel, StatusChip;
import 'receipts_provider.dart';

/// Create/edit a goods receipt (Приход, TZ §3.4).
///
/// Flow: pick supplier + branch (ids), then add lines via the product picker
/// (search or 1D-barcode scan) → enter quantity / series / expiry /
/// purchase & sale price. A running total shows at the bottom. Actions:
/// Save Draft (create/update), Post, Cancel. Posted/Cancelled receipts are
/// read-only; only a Draft can be edited or posted.
class ReceiptEditScreen extends ConsumerStatefulWidget {
  const ReceiptEditScreen({super.key, this.receiptId});

  /// `null` → create mode; non-null → load and edit an existing receipt.
  final String? receiptId;

  @override
  ConsumerState<ReceiptEditScreen> createState() => _ReceiptEditScreenState();
}

class _ReceiptEditScreenState extends ConsumerState<ReceiptEditScreen> {
  final _supplierId = TextEditingController();
  final _branchId = TextEditingController();

  DateTime _date = DateTime.now();
  final List<ReceiptLine> _lines = [];

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
      _lines.fold<double>(0, (sum, l) => sum + l.lineTotal);

  @override
  void initState() {
    super.initState();
    if (_isExisting) {
      _isLoadingExisting = true;
    }
  }

  @override
  void dispose() {
    _supplierId.dispose();
    _branchId.dispose();
    super.dispose();
  }

  void _hydrateFrom(Receipt receipt) {
    _loadedId = receipt.id;
    _number = receipt.number;
    _status = receipt.status;
    _supplierId.text = receipt.supplierId;
    _branchId.text = receipt.branchId;
    _date = receipt.date;
    _lines
      ..clear()
      ..addAll(receipt.lines);
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

  Future<void> _addLine() async {
    final product = await ProductPickerDialog.show(context);
    if (product == null || !mounted) return;
    await _editLine(product: product);
  }

  /// Opens the line dialog for a new product or an existing line at [index].
  Future<void> _editLine({Product? product, int? index}) async {
    final existing = index != null ? _lines[index] : null;
    final line = await ReceiptLineDialog.show(
      context,
      productId: existing?.productId ?? product!.id,
      productName: existing?.productName ?? product?.name,
      initial: existing,
    );
    if (line == null || !mounted) return;
    setState(() {
      if (index != null) {
        _lines[index] = line;
      } else {
        _lines.add(line);
      }
    });
  }

  void _removeLine(int index) {
    setState(() => _lines.removeAt(index));
  }

  Receipt _buildReceipt() {
    return Receipt(
      id: _loadedId ?? '',
      number: _number ?? '',
      supplierId: _supplierId.text.trim(),
      branchId: _branchId.text.trim(),
      date: _date,
      status: _status ?? ReceiptStatus.draft,
      lines: List.unmodifiable(_lines),
      total: _runningTotal,
    );
  }

  String? _validate() {
    if (_supplierId.text.trim().isEmpty) return 'Таъминкунандаро ворид кунед';
    if (_branchId.text.trim().isEmpty) return 'Филиалро ворид кунед';
    if (_lines.isEmpty) return 'Ҳадди ақал як сатр илова кунед';
    return null;
  }

  Future<void> _saveDraft() async {
    final problem = _validate();
    if (problem != null) {
      _showSnack(problem, isError: true);
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
      _showSnack('Аввал приходро нигоҳ доред', isError: true);
      return;
    }
    final confirmed = await _confirm(
      title: 'Тасдиқи приход',
      body: 'Приход тасдиқ карда шавад? Баъди тасдиқ бақия нав мешавад.',
      confirmLabel: 'Тасдиқ',
    );
    if (confirmed != true) return;
    final result =
        await ref.read(receiptEditControllerProvider.notifier).post(_loadedId!);
    _handleResult(result, successMessage: 'Приход тасдиқ шуд');
  }

  Future<void> _cancel() async {
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

  void _handleResult(ReceiptSaveResult result, {required String successMessage}) {
    if (!mounted) return;
    switch (result) {
      case ReceiptSaveSuccess(:final receipt):
        setState(() => _hydrateFrom(receipt));
        _showSnack(successMessage);
        // For terminal states (posted/cancelled) leave the editor.
        if (!receipt.status.isDraft) Navigator.of(context).pop();
      case ReceiptSaveFailure(:final failure):
        _showSnack(failure.message, isError: true);
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
        title: Text(_isExisting ? 'Приход ${_number ?? ''}'.trim() : 'Приходи нав'),
        actions: [
          if (_status != null) ...[
            Center(child: StatusChip(status: _status!)),
            const SizedBox(width: 12),
          ],
        ],
      ),
      body: _buildBody(busy),
      bottomNavigationBar: _loadError != null
          ? null
          : _ActionBar(
              total: _runningTotal,
              editable: _isEditable,
              isExisting: _isExisting,
              status: _status,
              busy: busy,
              onSaveDraft: _saveDraft,
              onPost: _post,
              onCancel: _cancel,
            ),
    );
  }

  Widget _buildBody(bool busy) {
    if (_loadError != null) {
      return _ErrorView(
        message: _loadError!,
        onRetry: () {
          setState(() {
            _loadError = null;
            _isLoadingExisting = true;
          });
          ref.invalidate(receiptDetailProvider(widget.receiptId!));
        },
      );
    }
    if (_isLoadingExisting && !_initialised) {
      return const Center(child: CircularProgressIndicator());
    }

    return AbsorbPointer(
      absorbing: busy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            supplierId: _supplierId,
            branchId: _branchId,
            date: _date,
            editable: _isEditable,
            onPickDate: _pickDate,
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Text(
                  'Сатрҳо (${_lines.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (_isEditable)
                  FilledButton.tonalIcon(
                    onPressed: _addLine,
                    icon: const Icon(Icons.add),
                    label: const Text('Илова сатр'),
                  ),
              ],
            ),
          ),
          Expanded(child: _buildLines()),
        ],
      ),
    );
  }

  Widget _buildLines() {
    if (_lines.isEmpty) {
      return const Center(child: Text('Сатр нест. «Илова сатр»-ро пахш кунед.'));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 900,
        columns: const [
          DataColumn2(label: Text('Дору'), size: ColumnSize.L),
          DataColumn2(label: Text('Миқдор'), numeric: true),
          DataColumn2(label: Text('Серия')),
          DataColumn2(label: Text('Мӯҳлат')),
          DataColumn2(label: Text('Нархи харид'), numeric: true),
          DataColumn2(label: Text('Нархи фурӯш'), numeric: true),
          DataColumn2(label: Text('Ҷамъ'), numeric: true),
          DataColumn2(label: Text(''), size: ColumnSize.S),
        ],
        rows: [
          for (var i = 0; i < _lines.length; i++)
            DataRow2(
              onTap: _isEditable ? () => _editLine(index: i) : null,
              cells: [
                DataCell(Text(_lines[i].productName ?? _lines[i].productId)),
                DataCell(Text(_trimNum(_lines[i].quantity))),
                DataCell(Text(_lines[i].seriesNumber)),
                DataCell(Text(Formatters.date(_lines[i].expiryDate))),
                DataCell(Text(Formatters.money(_lines[i].purchasePrice))),
                DataCell(Text(Formatters.money(_lines[i].salePrice))),
                DataCell(Text(Formatters.money(_lines[i].lineTotal))),
                DataCell(
                  _isEditable
                      ? IconButton(
                          tooltip: 'Ҳазфи сатр',
                          icon: const Icon(Icons.delete_outline, size: 18),
                          onPressed: () => _removeLine(i),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Renders a quantity without trailing `.0` for whole numbers.
  String _trimNum(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';
}

/// Supplier / branch / date header.
class _Header extends StatelessWidget {
  const _Header({
    required this.supplierId,
    required this.branchId,
    required this.date,
    required this.editable,
    required this.onPickDate,
  });

  final TextEditingController supplierId;
  final TextEditingController branchId;
  final DateTime date;
  final bool editable;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: supplierId,
              enabled: editable,
              decoration: const InputDecoration(
                labelText: 'Таъминкунанда (ID) *',
                prefixIcon: Icon(Icons.local_shipping_outlined),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: branchId,
              enabled: editable,
              decoration: const InputDecoration(
                labelText: 'Филиал (ID) *',
                prefixIcon: Icon(Icons.store_outlined),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: editable ? onPickDate : null,
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(Formatters.date(date)),
          ),
        ],
      ),
    );
  }
}

/// Bottom action bar: running total + Save Draft / Post / Cancel.
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.total,
    required this.editable,
    required this.isExisting,
    required this.status,
    required this.busy,
    required this.onSaveDraft,
    required this.onPost,
    required this.onCancel,
  });

  final double total;
  final bool editable;
  final bool isExisting;
  final ReceiptStatus? status;
  final bool busy;
  final VoidCallback onSaveDraft;
  final VoidCallback onPost;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final canCancel =
        isExisting && status != null && status != ReceiptStatus.cancelled;
    return Material(
      elevation: 8,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Text(
                'Ҷамъ: ${Formatters.money(total)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              if (canCancel)
                OutlinedButton.icon(
                  onPressed: busy ? null : onCancel,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Бекор'),
                ),
              const SizedBox(width: 8),
              if (editable)
                FilledButton.tonalIcon(
                  onPressed: busy ? null : onSaveDraft,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Нигоҳ доштан (Лоиҳа)'),
                ),
              const SizedBox(width: 8),
              if (editable && isExisting)
                FilledButton.icon(
                  onPressed: busy ? null : onPost,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Тасдиқ'),
                ),
              if (!editable && status != null)
                Text(statusLabel(status!)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Аз нав кӯшиш кунед'),
          ),
        ],
      ),
    );
  }
}

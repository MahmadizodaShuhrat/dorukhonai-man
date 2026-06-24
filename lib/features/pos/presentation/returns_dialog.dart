import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../data/pos_models.dart';
import '../data/pos_repository.dart';
import 'pos_providers.dart';
import 'receipt_view.dart';

/// Returns flow (TZ §3.2 «Бозгашти фурӯш»): pick a recent sale from the current
/// shift, choose how much of each line to return, then submit. Stock is
/// restored to the same batches server-side.
class ReturnsDialog extends ConsumerStatefulWidget {
  const ReturnsDialog({super.key, required this.shiftId});

  final String shiftId;

  /// Opens the dialog. Resolves when dismissed.
  static Future<void> show(BuildContext context, String shiftId) {
    return showDialog<void>(
      context: context,
      builder: (_) => ReturnsDialog(shiftId: shiftId),
    );
  }

  @override
  ConsumerState<ReturnsDialog> createState() => _ReturnsDialogState();
}

class _ReturnsDialogState extends ConsumerState<ReturnsDialog> {
  /// The sale chosen from the list; until then we show the sale picker.
  String? _selectedSaleId;

  @override
  Widget build(BuildContext context) {
    final saleId = _selectedSaleId;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: saleId == null
              ? _SalePicker(
                  shiftId: widget.shiftId,
                  onPicked: (id) => setState(() => _selectedSaleId = id),
                )
              : _ReturnLinesView(
                  saleId: saleId,
                  onBack: () => setState(() => _selectedSaleId = null),
                ),
        ),
      ),
    );
  }
}

/// Lists recent sales of the current shift for the cashier to pick from.
class _SalePicker extends ConsumerWidget {
  const _SalePicker({required this.shiftId, required this.onPicked});

  final String shiftId;
  final ValueChanged<String> onPicked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final salesAsync = ref.watch(shiftSalesProvider(shiftId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l.returnsPickTitle,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              tooltip: l.commonClose,
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: salesAsync.when(
            data: (sales) {
              if (sales.isEmpty) {
                return Center(child: Text(l.returnsNoSales));
              }
              return ListView.separated(
                itemCount: sales.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final sale = sales[index];
                  return ListTile(
                    dense: true,
                    title: Text(l.receiptCheckNumber(sale.number)),
                    subtitle: Text(Formatters.dateTime(sale.createdAt)),
                    trailing: Text(Formatters.money(sale.total)),
                    onTap: () => onPicked(sale.id),
                  );
                },
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Text(err is Failure ? err.message : err.toString()),
            ),
          ),
        ),
      ],
    );
  }
}

/// Loads a sale's lines and lets the cashier pick return quantities per line.
class _ReturnLinesView extends ConsumerStatefulWidget {
  const _ReturnLinesView({required this.saleId, required this.onBack});

  final String saleId;
  final VoidCallback onBack;

  @override
  ConsumerState<_ReturnLinesView> createState() => _ReturnLinesViewState();
}

class _ReturnLinesViewState extends ConsumerState<_ReturnLinesView> {
  /// Return quantity selected per sale-line id.
  final Map<String, double> _qty = {};

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final saleAsync = ref.watch(saleDetailProvider(widget.saleId));
    final busy = ref.watch(saleSubmitControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: l.returnsBack,
              icon: const Icon(Icons.arrow_back),
              onPressed: widget.onBack,
            ),
            Expanded(
              child: Text(
                l.returnsLinesTitle,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              tooltip: l.commonClose,
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: saleAsync.when(
            data: (sale) => _buildLines(l, sale),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Text(err is Failure ? err.message : err.toString()),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: busy ? null : _submit,
            icon: const Icon(Icons.assignment_return_outlined),
            label: Text(l.returnsSubmit),
          ),
        ),
      ],
    );
  }

  Widget _buildLines(AppLocalizations l, Sale sale) {
    if (sale.lines.isEmpty) {
      return Center(child: Text(l.returnsNoLines));
    }
    return ListView.separated(
      itemCount: sale.lines.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final line = sale.lines[index];
        final selected = _qty[line.id] ?? 0;
        return ListTile(
          title: Text(line.productName ?? line.productId),
          subtitle: Text(
            l.returnsLineSubtitle(
              line.seriesNumber ?? '—',
              _trimNum(line.quantity),
              Formatters.money(line.unitPrice),
            ),
          ),
          trailing: SizedBox(
            width: 132,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: l.posQtyDecrease,
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: selected <= 0
                      ? null
                      : () => setState(
                            () => _qty[line.id] = selected - 1,
                          ),
                ),
                Text(_trimNum(selected)),
                IconButton(
                  tooltip: l.posQtyIncrease,
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: selected >= line.quantity
                      ? null
                      : () => setState(
                            () => _qty[line.id] = selected + 1,
                          ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final lines = <SaleReturnLine>[
      for (final entry in _qty.entries)
        if (entry.value > 0)
          SaleReturnLine(saleLineId: entry.key, quantity: entry.value),
    ];
    if (lines.isEmpty) {
      _showSnack(l.returnsSelectAtLeastOne, isError: true);
      return;
    }
    final result = await ref
        .read(saleSubmitControllerProvider.notifier)
        .returnSale(saleId: widget.saleId, lines: lines);
    if (!mounted) return;
    switch (result) {
      case SaleSubmitSuccess(:final sale):
        Navigator.of(context).pop();
        await ReceiptDialog.show(context, sale);
      case SaleSubmitFailure(:final failure):
        _showSnack(failure.message, isError: true);
      case SaleSubmitPendingOffline():
        // Returns are online-only (TZ_04 §1: возврат DEGRADED, not offline).
        _showSnack(l.returnsOfflineUnsupported, isError: true);
    }
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

  String _trimNum(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';
}

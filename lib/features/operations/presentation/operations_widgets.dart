import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/app_data_table.dart';
import 'operations_providers.dart';

/// Validates a MODUL 6 draft before posting. Returns a Tajik error message, or
/// `null` when the draft is valid. [branchId] must be resolved (the real branch,
/// TZ_05 FW1). When [enforceMaxOnHand] is true (write-off / supplier-return),
/// each quantity must be positive and `<= onHand` (server also rejects, but the
/// client guards early). For inventory the counted quantity may differ freely.
String? validateOperationLines(
  AppLocalizations l,
  List<OperationLine> lines,
  String? branchId, {
  bool enforceMaxOnHand = true,
  bool requirePositive = true,
}) {
  if (branchId == null || branchId.isEmpty) {
    return l.opValBranchUnresolved;
  }
  if (lines.isEmpty) return l.opValAtLeastOneBatch;
  for (final line in lines) {
    if (requirePositive && line.quantity <= 0) {
      return l.opValQtyPositive(line.productName);
    }
    if (enforceMaxOnHand && line.quantity > line.onHand) {
      return l.opValQtyMax(line.productName, _qty(line.onHand));
    }
  }
  return null;
}

/// Editable draft-lines table shared by the three MODUL 6 editors. Each row
/// shows the product/series/on-hand and an editable quantity; the trailing
/// action removes the row. Optionally shows a live discrepancy column
/// (inventory: counted − on-hand).
class OperationLinesTable extends ConsumerWidget {
  const OperationLinesTable({
    super.key,
    required this.provider,
    required this.quantityLabel,
    this.emptyMessage,
    this.showDiscrepancy = false,
  });

  final StateNotifierProvider<OperationDraftController, List<OperationLine>>
      provider;
  final String quantityLabel;
  final String? emptyMessage;

  /// When true (Инвентаризатсия) a "Фарқият" column shows counted − on-hand.
  final bool showDiscrepancy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lines = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    return AppDataTable(
      minWidth: showDiscrepancy ? 720 : 620,
      emptyMessage: emptyMessage ?? l.opEmptyDefault,
      emptyIcon: Icons.playlist_add,
      columns: [
        DataColumn2(label: Text(l.opColDrug), size: ColumnSize.L),
        DataColumn2(label: Text(l.opColSeries)),
        DataColumn2(label: Text(l.opColRemaining), numeric: true),
        DataColumn2(label: Text(quantityLabel), fixedWidth: 160),
        if (showDiscrepancy)
          DataColumn2(label: Text(l.opColDiscrepancy), numeric: true),
        const DataColumn2(label: Text(''), fixedWidth: 56),
      ],
      rows: [
        for (var i = 0; i < lines.length; i++)
          DataRow2(
            cells: [
              DataCell(Text(lines[i].productName)),
              DataCell(Text(lines[i].seriesNumber)),
              DataCell(Text(_qty(lines[i].onHand))),
              DataCell(
                _QtyField(
                  key: ValueKey('qty-${lines[i].batchId}'),
                  value: lines[i].quantity,
                  onChanged: (v) => controller.setQuantity(i, v),
                ),
              ),
              if (showDiscrepancy)
                DataCell(
                  _DiscrepancyText(
                    difference: lines[i].quantity - lines[i].onHand,
                  ),
                ),
              DataCell(
                IconButton(
                  tooltip: l.commonDelete,
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => controller.removeAt(i),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// Inline editable quantity field that commits a parsed double on change.
class _QtyField extends StatefulWidget {
  const _QtyField({super.key, required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<_QtyField> createState() => _QtyFieldState();
}

class _QtyFieldState extends State<_QtyField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.value));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _format(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : '$v';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          border: OutlineInputBorder(),
        ),
        onChanged: (text) {
          final parsed = double.tryParse(text.trim().replaceAll(',', '.'));
          if (parsed != null) widget.onChanged(parsed);
        },
      ),
    );
  }
}

/// Coloured discrepancy value: green for zero, amber for a shortfall, blue for
/// a surplus.
class _DiscrepancyText extends StatelessWidget {
  const _DiscrepancyText({required this.difference});

  final double difference;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = difference == 0
        ? theme.colorScheme.onSurfaceVariant
        : (difference < 0 ? theme.colorScheme.error : theme.colorScheme.primary);
    final sign = difference > 0 ? '+' : '';
    return Text(
      '$sign${_qty(difference)}',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// A bordered, titled card hosting a MODUL 6 history table.
class OperationHistoryCard extends StatelessWidget {
  const OperationHistoryCard({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 240,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title.toUpperCase(),
              style: theme.textTheme.titleSmall?.copyWith(
                letterSpacing: 0.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

String _qty(double value) =>
    value == value.roundToDouble() ? value.toInt().toString() : '$value';

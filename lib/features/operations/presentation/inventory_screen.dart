import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/app_data_table.dart';
import '../../../shared/app_scaffold.dart';
import '../../../shared/app_toast.dart';
import '../../../shared/empty_state.dart';
import '../../../shared/loading_state.dart';
import '../../branch/presentation/branch_provider.dart';
import '../data/operations_models.dart';
import '../data/operations_repository.dart';
import 'batch_picker.dart';
import 'operations_providers.dart';
import 'operations_widgets.dart';

/// Инвентаризатсия (inventory count) screen (TZ_05 FW3 / MODUL 6). Pick batches,
/// enter the COUNTED quantity (free to differ from on-hand), and post
/// `POST /inventory`. The server returns discrepancies; the draft table also
/// shows a live counted − on-hand difference. All logic stays in the providers.
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _addBatch() async {
    final branchId = ref.read(currentBranchIdProvider);
    final item = await BatchPickerDialog.show(context, branchId: branchId);
    if (item == null || !mounted) return;
    ref.read(inventoryDraftProvider.notifier).addOrUpdate(
          OperationLine(
            batchId: item.batchId,
            productName: item.productName,
            seriesNumber: item.seriesNumber,
            onHand: item.quantity,
            // Default the count to on-hand so an unchanged row is a no-op.
            quantity: item.quantity,
          ),
        );
  }

  Future<void> _submit() async {
    final lines = ref.read(inventoryDraftProvider);
    final branchId = (await ref.read(currentBranchProvider.future))?.id;
    if (!mounted) return;
    // Counted quantities may exceed on-hand and may legitimately be zero.
    final failure = validateOperationLines(
      lines,
      branchId,
      enforceMaxOnHand: false,
      requirePositive: false,
    );
    if (failure != null) {
      AppToast.error(context, failure);
      return;
    }
    ref.read(operationSubmittingProvider.notifier).state = true;
    final repo = ref.read(operationsRepositoryProvider);
    final result = await repo.createInventory(
      branchId: branchId!,
      note: _noteController.text,
      lines: [
        for (final l in lines)
          InventoryLineRequest(batchId: l.batchId, countedQuantity: l.quantity),
      ],
    );
    if (!mounted) return;
    ref.read(operationSubmittingProvider.notifier).state = false;
    switch (result) {
      case Success(:final data):
        ref.read(inventoryDraftProvider.notifier).clear();
        _noteController.clear();
        ref.invalidate(inventoryHistoryProvider);
        if (data.discrepancies.isEmpty) {
          AppToast.success(context, 'Инвентаризатсия сабт шуд (фарқият нест).');
        } else {
          await _showDiscrepancies(data.discrepancies);
        }
      case Error(:final failure):
        AppToast.error(context, failure.message);
    }
  }

  Future<void> _showDiscrepancies(List<InventoryDiscrepancy> rows) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Фарқиятҳои инвентаризатсия'),
        content: SizedBox(
          width: 520,
          height: 360,
          child: AppDataTable(
            minWidth: 480,
            columns: const [
              DataColumn2(label: Text('Дору'), size: ColumnSize.L),
              DataColumn2(label: Text('Интизор'), numeric: true),
              DataColumn2(label: Text('Ҳисобшуда'), numeric: true),
              DataColumn2(label: Text('Фарқият'), numeric: true),
            ],
            rows: [
              for (final d in rows)
                DataRow2(
                  cells: [
                    DataCell(Text(d.productName ?? d.batchId)),
                    DataCell(Text(_qty(d.expected))),
                    DataCell(Text(_qty(d.counted))),
                    DataCell(
                      Text(
                        '${d.difference > 0 ? '+' : ''}${_qty(d.difference)}',
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Хуб'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lines = ref.watch(inventoryDraftProvider);
    final submitting = ref.watch(operationSubmittingProvider);
    return AppScaffold(
      title: 'Инвентаризатсия',
      icon: Icons.fact_check_outlined,
      subtitle: 'Ҳисоб кардани бақия ва танзими фарқият',
      actions: [
        FilledButton.icon(
          onPressed: submitting || lines.isEmpty ? null : _submit,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Сабт кардан'),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (submitting) const LinearProgressIndicator(minHeight: 2),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Эзоҳ',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _addBatch,
                icon: const Icon(Icons.add),
                label: const Text('Партия илова'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: OperationLinesTable(
              provider: inventoryDraftProvider,
              quantityLabel: 'Ҳисобшуда',
              showDiscrepancy: true,
              emptyMessage: 'Партия илова кунед барои ҳисоб.',
            ),
          ),
          const SizedBox(height: 16),
          const _InventoryHistory(),
        ],
      ),
    );
  }
}

class _InventoryHistory extends ConsumerWidget {
  const _InventoryHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(inventoryHistoryProvider);
    return OperationHistoryCard(
      title: 'Инвентаризатсияҳои охирин',
      child: async.when(
        loading: () => const LoadingState(),
        error: (err, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Хатогӣ',
          message: err is Failure ? err.message : 'Боркунӣ ноком шуд.',
          action: FilledButton.tonalIcon(
            onPressed: () => ref.invalidate(inventoryHistoryProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Аз нав'),
          ),
        ),
        data: (paged) {
          if (paged.items.isEmpty) {
            return const EmptyState(
              message: 'Ҳоло инвентаризатсия сабт нашудааст.',
            );
          }
          return AppDataTable(
            minWidth: 480,
            columns: const [
              DataColumn2(label: Text('Сана')),
              DataColumn2(label: Text('Рақам')),
              DataColumn2(label: Text('Сатрҳо'), numeric: true),
            ],
            rows: [
              for (final d in paged.items)
                DataRow2(
                  cells: [
                    DataCell(Text(Formatters.dateTime(d.createdAt))),
                    DataCell(Text(d.number ?? '—')),
                    DataCell(Text('${d.lineCount}')),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

String _qty(double value) =>
    value == value.roundToDouble() ? value.toInt().toString() : '$value';

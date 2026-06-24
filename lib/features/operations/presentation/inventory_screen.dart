import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/app_localizations.dart';
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
    final l = AppLocalizations.of(context);
    // Counted quantities may exceed on-hand and may legitimately be zero.
    final failure = validateOperationLines(
      l,
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
          AppToast.success(context, l.inventorySavedNoDiff);
        } else {
          await _showDiscrepancies(data.discrepancies);
        }
      case Error(:final failure):
        AppToast.error(context, failure.message);
    }
  }

  Future<void> _showDiscrepancies(List<InventoryDiscrepancy> rows) {
    final l = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.inventoryDiscrepanciesTitle),
        content: SizedBox(
          width: 520,
          height: 360,
          child: AppDataTable(
            minWidth: 480,
            columns: [
              DataColumn2(label: Text(l.opColDrug), size: ColumnSize.L),
              DataColumn2(label: Text(l.inventoryColExpected), numeric: true),
              DataColumn2(label: Text(l.inventoryColCounted), numeric: true),
              DataColumn2(label: Text(l.inventoryColDiff), numeric: true),
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
            child: Text(l.inventoryOk),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lines = ref.watch(inventoryDraftProvider);
    final submitting = ref.watch(operationSubmittingProvider);
    return AppScaffold(
      title: l.inventoryTitle,
      icon: Icons.fact_check_outlined,
      subtitle: l.inventorySubtitle,
      actions: [
        FilledButton.icon(
          onPressed: submitting || lines.isEmpty ? null : _submit,
          icon: const Icon(Icons.save_outlined),
          label: Text(l.inventorySubmit),
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
                  decoration: InputDecoration(
                    labelText: l.inventoryNote,
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _addBatch,
                icon: const Icon(Icons.add),
                label: Text(l.inventoryAddBatch),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: OperationLinesTable(
              provider: inventoryDraftProvider,
              quantityLabel: l.inventoryCountedLabel,
              showDiscrepancy: true,
              emptyMessage: l.inventoryEmptyDraft,
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
    final l = AppLocalizations.of(context);
    final async = ref.watch(inventoryHistoryProvider);
    return OperationHistoryCard(
      title: l.inventoryHistoryTitle,
      child: async.when(
        loading: () => const LoadingState(),
        error: (err, _) => EmptyState(
          icon: Icons.error_outline,
          title: l.commonError,
          message: err is Failure ? err.message : l.commonLoadFailed,
          action: FilledButton.tonalIcon(
            onPressed: () => ref.invalidate(inventoryHistoryProvider),
            icon: const Icon(Icons.refresh),
            label: Text(l.commonRetry),
          ),
        ),
        data: (paged) {
          if (paged.items.isEmpty) {
            return EmptyState(
              message: l.inventoryHistoryEmpty,
            );
          }
          return AppDataTable(
            minWidth: 480,
            columns: [
              DataColumn2(label: Text(l.opColDate)),
              DataColumn2(label: Text(l.opColNumber)),
              DataColumn2(label: Text(l.opColLines), numeric: true),
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

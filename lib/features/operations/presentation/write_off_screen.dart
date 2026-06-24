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

/// Списание (write-off) screen (TZ_05 FW3 / MODUL 6). Pick batches via the
/// [BatchPickerDialog], choose a reason + optional note, enter quantities, and
/// post `POST /write-offs`. A history list shows recent write-offs. All data
/// logic lives in the Riverpod controllers; the widget only dispatches.
class WriteOffScreen extends ConsumerStatefulWidget {
  const WriteOffScreen({super.key});

  @override
  ConsumerState<WriteOffScreen> createState() => _WriteOffScreenState();
}

class _WriteOffScreenState extends ConsumerState<WriteOffScreen> {
  final _noteController = TextEditingController();
  WriteOffReason _reason = WriteOffReason.expired;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _addBatch() async {
    final branchId = ref.read(currentBranchIdProvider);
    final item = await BatchPickerDialog.show(context, branchId: branchId);
    if (item == null || !mounted) return;
    ref.read(writeOffDraftProvider.notifier).addOrUpdate(
          OperationLine(
            batchId: item.batchId,
            productName: item.productName,
            seriesNumber: item.seriesNumber,
            onHand: item.quantity,
            quantity: 1,
          ),
        );
  }

  Future<void> _submit() async {
    final lines = ref.read(writeOffDraftProvider);
    final branchId = (await ref.read(currentBranchProvider.future))?.id;
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    final failure = validateOperationLines(l, lines, branchId);
    if (failure != null) {
      AppToast.error(context, failure);
      return;
    }
    ref.read(operationSubmittingProvider.notifier).state = true;
    final repo = ref.read(operationsRepositoryProvider);
    final result = await repo.createWriteOff(
      branchId: branchId!,
      reason: _reason,
      note: _noteController.text,
      lines: [
        for (final l in lines)
          WriteOffLineRequest(batchId: l.batchId, quantity: l.quantity),
      ],
    );
    if (!mounted) return;
    ref.read(operationSubmittingProvider.notifier).state = false;
    switch (result) {
      case Success():
        ref.read(writeOffDraftProvider.notifier).clear();
        _noteController.clear();
        ref.invalidate(writeOffHistoryProvider);
        AppToast.success(context, l.writeOffSaved);
      case Error(:final failure):
        AppToast.error(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lines = ref.watch(writeOffDraftProvider);
    final submitting = ref.watch(operationSubmittingProvider);
    return AppScaffold(
      title: l.writeOffTitle,
      icon: Icons.delete_sweep_outlined,
      subtitle: l.writeOffSubtitle,
      actions: [
        FilledButton.icon(
          onPressed: submitting || lines.isEmpty ? null : _submit,
          icon: const Icon(Icons.save_outlined),
          label: Text(l.writeOffSubmit),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (submitting) const LinearProgressIndicator(minHeight: 2),
          Row(
            children: [
              SizedBox(
                width: 240,
                child: DropdownButtonFormField<WriteOffReason>(
                  initialValue: _reason,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l.writeOffReason,
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    for (final r in WriteOffReason.values)
                      DropdownMenuItem(value: r, child: Text(r.label(l))),
                  ],
                  onChanged: (v) =>
                      setState(() => _reason = v ?? WriteOffReason.other),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: l.writeOffNote,
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _addBatch,
                icon: const Icon(Icons.add),
                label: Text(l.writeOffAddBatch),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: OperationLinesTable(
              provider: writeOffDraftProvider,
              quantityLabel: l.opColQty,
              emptyMessage: l.writeOffEmptyDraft,
            ),
          ),
          const SizedBox(height: 16),
          const _WriteOffHistory(),
        ],
      ),
    );
  }
}

/// Recent write-offs (`GET /write-offs`).
class _WriteOffHistory extends ConsumerWidget {
  const _WriteOffHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(writeOffHistoryProvider);
    return OperationHistoryCard(
      title: l.writeOffHistoryTitle,
      child: async.when(
        loading: () => const LoadingState(),
        error: (err, _) => EmptyState(
          icon: Icons.error_outline,
          title: l.commonError,
          message: err is Failure ? err.message : l.commonLoadFailed,
          action: FilledButton.tonalIcon(
            onPressed: () => ref.invalidate(writeOffHistoryProvider),
            icon: const Icon(Icons.refresh),
            label: Text(l.commonRetry),
          ),
        ),
        data: (paged) {
          if (paged.items.isEmpty) {
            return EmptyState(message: l.writeOffHistoryEmpty);
          }
          return AppDataTable(
            minWidth: 520,
            columns: [
              DataColumn2(label: Text(l.opColDate)),
              DataColumn2(label: Text(l.opColNumber)),
              DataColumn2(label: Text(l.opColReason)),
              DataColumn2(label: Text(l.opColLines), numeric: true),
            ],
            rows: [
              for (final w in paged.items)
                DataRow2(
                  cells: [
                    DataCell(Text(Formatters.dateTime(w.createdAt))),
                    DataCell(Text(w.number ?? '—')),
                    DataCell(Text(w.reason.label(l))),
                    DataCell(Text('${w.lineCount}')),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

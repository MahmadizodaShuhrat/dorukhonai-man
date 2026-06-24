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
import '../../../shared/entity_picker.dart';
import '../../../shared/loading_state.dart';
import '../../branch/presentation/branch_provider.dart';
import '../../reference/presentation/reference_providers.dart';
import '../data/operations_models.dart';
import '../data/operations_repository.dart';
import 'batch_picker.dart';
import 'operations_providers.dart';
import 'operations_widgets.dart';

/// Бозгашт ба таъминкунанда (supplier return) screen (TZ_05 FW3 / MODUL 6).
/// Choose a supplier via the [EntityPicker], pick batches, enter quantities, and
/// post `POST /supplier-returns`. All logic stays in the providers.
class SupplierReturnScreen extends ConsumerStatefulWidget {
  const SupplierReturnScreen({super.key});

  @override
  ConsumerState<SupplierReturnScreen> createState() =>
      _SupplierReturnScreenState();
}

class _SupplierReturnScreenState extends ConsumerState<SupplierReturnScreen> {
  final _noteController = TextEditingController();
  String? _supplierId;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _addBatch() async {
    final branchId = ref.read(currentBranchIdProvider);
    final item = await BatchPickerDialog.show(context, branchId: branchId);
    if (item == null || !mounted) return;
    ref.read(supplierReturnDraftProvider.notifier).addOrUpdate(
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
    final l = AppLocalizations.of(context);
    final supplierId = _supplierId;
    if (supplierId == null || supplierId.isEmpty) {
      AppToast.error(context, l.supplierReturnSelectSupplier);
      return;
    }
    final lines = ref.read(supplierReturnDraftProvider);
    final branchId = (await ref.read(currentBranchProvider.future))?.id;
    if (!mounted) return;
    final failure = validateOperationLines(l, lines, branchId);
    if (failure != null) {
      AppToast.error(context, failure);
      return;
    }
    ref.read(operationSubmittingProvider.notifier).state = true;
    final repo = ref.read(operationsRepositoryProvider);
    final result = await repo.createSupplierReturn(
      supplierId: supplierId,
      branchId: branchId!,
      note: _noteController.text,
      lines: [
        for (final l in lines)
          SupplierReturnLineRequest(batchId: l.batchId, quantity: l.quantity),
      ],
    );
    if (!mounted) return;
    ref.read(operationSubmittingProvider.notifier).state = false;
    switch (result) {
      case Success():
        ref.read(supplierReturnDraftProvider.notifier).clear();
        _noteController.clear();
        setState(() => _supplierId = null);
        ref.invalidate(supplierReturnHistoryProvider);
        AppToast.success(context, l.supplierReturnSaved);
      case Error(:final failure):
        AppToast.error(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lines = ref.watch(supplierReturnDraftProvider);
    final submitting = ref.watch(operationSubmittingProvider);
    return AppScaffold(
      title: l.supplierReturnTitle,
      icon: Icons.assignment_return_outlined,
      subtitle: l.supplierReturnSubtitle,
      actions: [
        FilledButton.icon(
          onPressed: submitting || lines.isEmpty ? null : _submit,
          icon: const Icon(Icons.save_outlined),
          label: Text(l.supplierReturnSubmit),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (submitting) const LinearProgressIndicator(minHeight: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 320,
                child: EntityPicker(
                  label: l.supplierReturnSupplier,
                  icon: Icons.local_shipping_outlined,
                  isRequired: true,
                  optionsProvider: (s) => supplierOptionsProvider(s),
                  selectedId: _supplierId,
                  onChanged: (id) => setState(() => _supplierId = id),
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
              provider: supplierReturnDraftProvider,
              quantityLabel: l.opColQty,
              emptyMessage: l.supplierReturnEmptyDraft,
            ),
          ),
          const SizedBox(height: 16),
          const _SupplierReturnHistory(),
        ],
      ),
    );
  }
}

class _SupplierReturnHistory extends ConsumerWidget {
  const _SupplierReturnHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(supplierReturnHistoryProvider);
    return OperationHistoryCard(
      title: l.supplierReturnHistoryTitle,
      child: async.when(
        loading: () => const LoadingState(),
        error: (err, _) => EmptyState(
          icon: Icons.error_outline,
          title: l.commonError,
          message: err is Failure ? err.message : l.commonLoadFailed,
          action: FilledButton.tonalIcon(
            onPressed: () => ref.invalidate(supplierReturnHistoryProvider),
            icon: const Icon(Icons.refresh),
            label: Text(l.commonRetry),
          ),
        ),
        data: (paged) {
          if (paged.items.isEmpty) {
            return EmptyState(message: l.supplierReturnHistoryEmpty);
          }
          return AppDataTable(
            minWidth: 520,
            columns: [
              DataColumn2(label: Text(l.opColDate)),
              DataColumn2(label: Text(l.opColNumber)),
              DataColumn2(label: Text(l.opColSupplier), size: ColumnSize.L),
              DataColumn2(label: Text(l.opColLines), numeric: true),
            ],
            rows: [
              for (final r in paged.items)
                DataRow2(
                  cells: [
                    DataCell(Text(Formatters.dateTime(r.createdAt))),
                    DataCell(Text(r.number ?? '—')),
                    DataCell(Text(r.supplierName ?? '—')),
                    DataCell(Text('${r.lineCount}')),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

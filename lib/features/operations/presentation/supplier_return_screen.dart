import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/utils/formatters.dart';
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
    final supplierId = _supplierId;
    if (supplierId == null || supplierId.isEmpty) {
      AppToast.error(context, 'Таъминкунандаро интихоб кунед.');
      return;
    }
    final lines = ref.read(supplierReturnDraftProvider);
    final branchId = (await ref.read(currentBranchProvider.future))?.id;
    if (!mounted) return;
    final failure = validateOperationLines(lines, branchId);
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
        AppToast.success(context, 'Бозгашт ба таъминкунанда сабт шуд.');
      case Error(:final failure):
        AppToast.error(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lines = ref.watch(supplierReturnDraftProvider);
    final submitting = ref.watch(operationSubmittingProvider);
    return AppScaffold(
      title: 'Бозгашт ба таъминкунанда',
      icon: Icons.assignment_return_outlined,
      subtitle: 'Баргардонидани партияҳо ба таъминкунанда',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 320,
                child: EntityPicker(
                  label: 'Таъминкунанда',
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
              provider: supplierReturnDraftProvider,
              quantityLabel: 'Миқдор',
              emptyMessage: 'Партия илова кунед барои бозгашт.',
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
    final async = ref.watch(supplierReturnHistoryProvider);
    return OperationHistoryCard(
      title: 'Бозгаштҳои охирин',
      child: async.when(
        loading: () => const LoadingState(),
        error: (err, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Хатогӣ',
          message: err is Failure ? err.message : 'Боркунӣ ноком шуд.',
          action: FilledButton.tonalIcon(
            onPressed: () => ref.invalidate(supplierReturnHistoryProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Аз нав'),
          ),
        ),
        data: (paged) {
          if (paged.items.isEmpty) {
            return const EmptyState(message: 'Ҳоло бозгашт сабт нашудааст.');
          }
          return AppDataTable(
            minWidth: 520,
            columns: const [
              DataColumn2(label: Text('Сана')),
              DataColumn2(label: Text('Рақам')),
              DataColumn2(label: Text('Таъминкунанда'), size: ColumnSize.L),
              DataColumn2(label: Text('Сатрҳо'), numeric: true),
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

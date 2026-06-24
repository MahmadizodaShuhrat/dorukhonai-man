import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/app_data_table.dart';
import '../../../shared/app_scaffold.dart';
import '../../../shared/entity_picker.dart';
import '../../../shared/status_chip.dart';
import '../../reference/presentation/reference_providers.dart';
import '../data/receipt_models.dart';
import 'receipt_edit_screen.dart';
import 'receipts_provider.dart';

/// Goods-receipts list (Приход, TZ_03 §C.4): a full-width [AppDataTable] of
/// receipt headers (№ · Сана · Таъминкунанда · Статус · Ҷамъ) under a
/// page-header with a "+ Приход нав" primary action and a filter bar (status
/// chips, date range, supplier picker). Tapping a row opens the full-page
/// editor; the editor controller refreshes the list on every mutation.
class ReceiptsListScreen extends ConsumerWidget {
  const ReceiptsListScreen({super.key});

  Future<void> _openEditor(BuildContext context, {String? receiptId}) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ReceiptEditScreen(receiptId: receiptId),
      ),
    );
    // The edit controller refreshes the list on every successful mutation.
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(receiptsListControllerProvider);
    final controller = ref.read(receiptsListControllerProvider.notifier);

    // Resolve supplier ids → names so the column shows a name, never a GUID
    // (TZ_03 §C.4/§C.5). Falls back to the id while options are still loading.
    final supplierNames = <String, String>{
      for (final o
          in ref.watch(supplierOptionsProvider('')).valueOrNull ??
              const [])
        o.id: o.label,
    };

    return AppScaffold(
      icon: Icons.inventory_2_outlined,
      title: l.receiptsTitle,
      subtitle: l.commonTotalCount(state.total),
      padBody: false,
      actions: [
        IconButton(
          tooltip: l.receiptsRefresh,
          icon: const Icon(Icons.refresh),
          onPressed: state.isLoading ? null : controller.refresh,
        ),
        FilledButton.icon(
          onPressed: () => _openEditor(context),
          icon: const Icon(Icons.add),
          label: Text(l.receiptsNew),
        ),
      ],
      body: Column(
        children: [
          _FilterBar(state: state, controller: controller),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: _buildTable(context, l, state, controller, supplierNames),
            ),
          ),
          _PaginationBar(state: state, controller: controller),
        ],
      ),
    );
  }

  Widget _buildTable(
    BuildContext context,
    AppLocalizations l,
    ReceiptsListState state,
    ReceiptsListController controller,
    Map<String, String> supplierNames,
  ) {
    return Stack(
      children: [
        AppDataTable(
          minWidth: 760,
          isLoading: state.isLoading,
          errorMessage: state.receipts.isEmpty ? state.failure?.message : null,
          onRetry: controller.refresh,
          emptyMessage: l.receiptsEmpty,
          emptyIcon: Icons.inventory_2_outlined,
          columns: [
            DataColumn2(label: Text(l.receiptColNumber), size: ColumnSize.S),
            DataColumn2(label: Text(l.receiptColDate), fixedWidth: 110),
            DataColumn2(label: Text(l.receiptColSupplier), size: ColumnSize.L),
            DataColumn2(label: Text(l.receiptColStatus), fixedWidth: 130),
            DataColumn2(
              label: Text(l.receiptColTotal),
              numeric: true,
              fixedWidth: 120,
            ),
          ],
          rows: [
            for (final receipt in state.receipts)
              DataRow2(
                onTap: () => _openEditor(context, receiptId: receipt.id),
                cells: [
                  DataCell(Text(receipt.number)),
                  DataCell(Text(Formatters.date(receipt.date))),
                  DataCell(
                    Text(
                      supplierNames[receipt.supplierId] ?? receipt.supplierId,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: ReceiptStatusChip(status: receipt.status),
                      ),
                    ),
                  ),
                  DataCell(Text(Formatters.money(receipt.total))),
                ],
              ),
          ],
        ),
        if (state.isLoading && state.receipts.isNotEmpty)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }
}

/// Filter bar (TZ_03 §C.4): status chips (Ҳама / Лоиҳа / Тасдиқшуда /
/// Бекоршуда), a date-range picker, and a supplier [EntityPicker].
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.state, required this.controller});

  final ReceiptsListState state;
  final ReceiptsListController controller;

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: state.from != null && state.to != null
          ? DateTimeRange(start: state.from!, end: state.to!)
          : null,
    );
    if (picked != null) {
      await controller.filterByDateRange(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hasRange = state.from != null && state.to != null;
    final rangeLabel = hasRange
        ? '${Formatters.date(state.from!)} – ${Formatters.date(state.to!)}'
        : l.receiptDateFilter;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ChoiceChip(
            label: Text(l.receiptFilterAll),
            selected: state.status == null,
            onSelected: (_) => controller.filterByStatus(null),
          ),
          for (final status in ReceiptStatus.values)
            ChoiceChip(
              label: Text(statusLabel(l, status)),
              selected: state.status == status,
              onSelected: (_) => controller.filterByStatus(status),
            ),
          const SizedBox(width: 4),
          OutlinedButton.icon(
            onPressed: () => _pickRange(context),
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(rangeLabel),
          ),
          if (hasRange)
            IconButton(
              tooltip: l.receiptClearDate,
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () => controller.filterByDateRange(null, null),
            ),
          SizedBox(
            width: 260,
            child: EntityPicker(
              label: l.receiptColSupplier,
              icon: Icons.local_shipping_outlined,
              optionsProvider: (s) => supplierOptionsProvider(s),
              selectedId: state.supplierId.isEmpty ? null : state.supplierId,
              onChanged: (id) => controller.filterBySupplier(id ?? ''),
            ),
          ),
        ],
      ),
    );
  }
}

/// Coloured chip rendering a [ReceiptStatus] via the shared [StatusChip] +
/// [StatusColors] tones (Draft=info, Posted=ok, Cancelled=danger).
class ReceiptStatusChip extends StatelessWidget {
  const ReceiptStatusChip({super.key, required this.status, this.dense = true});

  final ReceiptStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return StatusChip(
      label: statusLabel(AppLocalizations.of(context), status),
      tone: statusTone(status),
      dense: dense,
    );
  }
}

/// Maps a [ReceiptStatus] to its semantic [StatusTone].
StatusTone statusTone(ReceiptStatus status) => switch (status) {
  ReceiptStatus.draft => StatusTone.info,
  ReceiptStatus.posted => StatusTone.ok,
  ReceiptStatus.cancelled => StatusTone.danger,
};

/// Localized label for a [ReceiptStatus].
String statusLabel(AppLocalizations l, ReceiptStatus status) => switch (status) {
  ReceiptStatus.draft => l.receiptStatusDraft,
  ReceiptStatus.posted => l.receiptStatusPosted,
  ReceiptStatus.cancelled => l.receiptStatusCancelled,
};

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({required this.state, required this.controller});

  final ReceiptsListState state;
  final ReceiptsListController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Text(
            l.receiptPageOf(state.page, state.pageCount),
            style: theme.textTheme.bodySmall,
          ),
          const Spacer(),
          IconButton(
            tooltip: l.commonPrevious,
            icon: const Icon(Icons.chevron_left),
            onPressed: state.hasPrevious && !state.isLoading
                ? controller.previousPage
                : null,
          ),
          Text('${state.page} / ${state.pageCount}'),
          IconButton(
            tooltip: l.commonNext,
            icon: const Icon(Icons.chevron_right),
            onPressed: state.hasNext && !state.isLoading
                ? controller.nextPage
                : null,
          ),
        ],
      ),
    );
  }
}

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../data/receipt_models.dart';
import 'receipt_edit_screen.dart';
import 'receipts_provider.dart';

/// Goods-receipts list (Приход, TZ §3.4): status filter chips + a paginated
/// [DataTable2] of receipt headers. Tapping a row opens the editor; the FAB
/// creates a new draft.
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
    final state = ref.watch(receiptsListControllerProvider);
    final controller = ref.read(receiptsListControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Приход'),
        actions: [
          IconButton(
            tooltip: 'Навсозӣ',
            icon: const Icon(Icons.refresh),
            onPressed: state.isLoading ? null : controller.refresh,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Приходи нав'),
      ),
      body: Column(
        children: [
          _StatusFilterBar(
            selected: state.status,
            onSelected: controller.filterByStatus,
          ),
          Expanded(child: _buildBody(context, state, controller)),
          _PaginationBar(state: state, controller: controller),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ReceiptsListState state,
    ReceiptsListController controller,
  ) {
    if (state.failure != null && state.receipts.isEmpty) {
      return _ErrorView(
        message: state.failure!.message,
        onRetry: controller.refresh,
      );
    }
    if (!state.isLoading && state.receipts.isEmpty) {
      return const _EmptyView();
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DataTable2(
            columnSpacing: 16,
            horizontalMargin: 12,
            minWidth: 760,
            columns: const [
              DataColumn2(label: Text('№'), size: ColumnSize.S),
              DataColumn2(label: Text('Сана')),
              DataColumn2(label: Text('Таъминкунанда'), size: ColumnSize.L),
              DataColumn2(label: Text('Статус'), size: ColumnSize.S),
              DataColumn2(
                label: Text('Ҷамъ'),
                numeric: true,
              ),
            ],
            rows: [
              for (final receipt in state.receipts)
                DataRow2(
                  onTap: () => _openEditor(context, receiptId: receipt.id),
                  cells: [
                    DataCell(Text(receipt.number)),
                    DataCell(Text(Formatters.date(receipt.date))),
                    DataCell(Text(receipt.supplierId)),
                    DataCell(StatusChip(status: receipt.status)),
                    DataCell(Text(Formatters.money(receipt.total))),
                  ],
                ),
            ],
          ),
        ),
        if (state.isLoading)
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

/// Status filter chips: All / Draft / Posted / Cancelled.
class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar({required this.selected, required this.onSelected});

  final ReceiptStatus? selected;
  final ValueChanged<ReceiptStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Ҳама'),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          const SizedBox(width: 8),
          for (final status in ReceiptStatus.values) ...[
            ChoiceChip(
              label: Text(statusLabel(status)),
              selected: selected == status,
              onSelected: (_) => onSelected(status),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

/// Coloured chip rendering a [ReceiptStatus].
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final ReceiptStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color bg, Color fg) = switch (status) {
      ReceiptStatus.draft => (scheme.surfaceContainerHighest, scheme.onSurface),
      ReceiptStatus.posted => (scheme.primaryContainer, scheme.onPrimaryContainer),
      ReceiptStatus.cancelled => (scheme.errorContainer, scheme.onErrorContainer),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusLabel(status),
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Tajik label for a [ReceiptStatus].
String statusLabel(ReceiptStatus status) => switch (status) {
  ReceiptStatus.draft => 'Лоиҳа',
  ReceiptStatus.posted => 'Тасдиқшуда',
  ReceiptStatus.cancelled => 'Бекоршуда',
};

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({required this.state, required this.controller});

  final ReceiptsListState state;
  final ReceiptsListController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Text('Ҳамагӣ: ${state.total}'),
            const Spacer(),
            IconButton(
              tooltip: 'Қаблӣ',
              icon: const Icon(Icons.chevron_left),
              onPressed: state.hasPrevious && !state.isLoading
                  ? controller.previousPage
                  : null,
            ),
            Text('${state.page} / ${state.pageCount}'),
            IconButton(
              tooltip: 'Баъдӣ',
              icon: const Icon(Icons.chevron_right),
              onPressed: state.hasNext && !state.isLoading
                  ? controller.nextPage
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          const Text('Приход ёфт нашуд'),
        ],
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

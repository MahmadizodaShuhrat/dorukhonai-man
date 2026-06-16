import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../data/stock_models.dart';
import 'stock_movements_screen.dart';
import 'stock_provider.dart';

/// Stock / warehouse screen (Анбор, TZ §3.5) with three tabs:
///  - «Бақия» — on-hand stock with search;
///  - «Мӯҳлати наздик» — items expiring soon, rows tinted yellow/red;
///  - «Камшуда» — products below their minimum level.
/// Tapping a stock/low row opens the product's movement history.
class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Анбор'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Бақия'),
              Tab(text: 'Мӯҳлати наздик'),
              Tab(text: 'Камшуда'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _StockListTab(),
            _ExpiringTab(),
            _LowStockTab(),
          ],
        ),
      ),
    );
  }
}

/// «Бақия» — on-hand stock list with a search field.
class _StockListTab extends ConsumerStatefulWidget {
  const _StockListTab();

  @override
  ConsumerState<_StockListTab> createState() => _StockListTabState();
}

class _StockListTabState extends ConsumerState<_StockListTab> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(stockListControllerProvider.notifier).search(value);
    });
  }

  Future<void> _openMovements(String productId, String productName) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => StockMovementsScreen(
          productId: productId,
          productName: productName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockListControllerProvider);
    final controller = ref.read(stockListControllerProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Ҷустуҷӯ (ном ё штрих-код)…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    ),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: _StockTableView(
            state: state,
            onRetry: controller.refresh,
            emptyText: 'Бақия нест',
            minWidth: 820,
            columns: const [
              DataColumn2(label: Text('Дору'), size: ColumnSize.L),
              DataColumn2(label: Text('Штрих-код')),
              DataColumn2(label: Text('Серия')),
              DataColumn2(label: Text('Мӯҳлат')),
              DataColumn2(label: Text('Миқдор'), numeric: true),
              DataColumn2(label: Text('Нарх'), numeric: true),
            ],
            rowBuilder: (item) => DataRow2(
              onTap: () => _openMovements(item.productId, item.productName),
              cells: [
                DataCell(Text(item.productName)),
                DataCell(Text(item.barcode ?? '—')),
                DataCell(Text(item.seriesNumber)),
                DataCell(Text(Formatters.date(item.expiryDate))),
                DataCell(Text(_qty(item.quantity))),
                DataCell(Text(Formatters.money(item.salePrice))),
              ],
            ),
          ),
        ),
        _PaginationBar(
          total: state.total,
          page: state.page,
          pageCount: state.pageCount,
          isLoading: state.isLoading,
          hasPrevious: state.hasPrevious,
          hasNext: state.hasNext,
          onPrevious: controller.previousPage,
          onNext: controller.nextPage,
        ),
      ],
    );
  }
}

/// «Мӯҳлати наздик» — expiring stock; rows tinted by proximity. Red within
/// 30 days (or already expired), yellow within the selected window.
class _ExpiringTab extends ConsumerWidget {
  const _ExpiringTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expiringStockControllerProvider);
    final controller = ref.read(expiringStockControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              const Text('Дар давоми: '),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('90 рӯз'),
                selected: controller.days == 90,
                onSelected: (_) => controller.setDays(90),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('30 рӯз'),
                selected: controller.days == 30,
                onSelected: (_) => controller.setDays(30),
              ),
            ],
          ),
        ),
        Expanded(
          child: _StockTableView(
            state: state,
            onRetry: controller.refresh,
            emptyText: 'Доруи мӯҳлаташ наздик нест',
            minWidth: 760,
            columns: const [
              DataColumn2(label: Text('Дору'), size: ColumnSize.L),
              DataColumn2(label: Text('Серия')),
              DataColumn2(label: Text('Мӯҳлат')),
              DataColumn2(label: Text('Боқимонда (рӯз)'), numeric: true),
              DataColumn2(label: Text('Миқдор'), numeric: true),
            ],
            rowBuilder: (item) {
              final days = item.daysUntilExpiry();
              final color = _expiryColor(days, scheme);
              return DataRow2(
                color: color == null
                    ? null
                    : WidgetStatePropertyAll(color),
                cells: [
                  DataCell(Text(item.productName)),
                  DataCell(Text(item.seriesNumber)),
                  DataCell(Text(Formatters.date(item.expiryDate))),
                  DataCell(Text('$days')),
                  DataCell(Text(_qty(item.quantity))),
                ],
              );
            },
          ),
        ),
        _PaginationBar(
          total: state.total,
          page: state.page,
          pageCount: state.pageCount,
          isLoading: state.isLoading,
          hasPrevious: state.hasPrevious,
          hasNext: state.hasNext,
          onPrevious: controller.previousPage,
          onNext: controller.nextPage,
        ),
      ],
    );
  }

  /// Row tint by days-to-expiry: red ≤30 (or expired), yellow ≤90.
  Color? _expiryColor(int days, ColorScheme scheme) {
    if (days <= 30) return scheme.errorContainer.withValues(alpha: 0.5);
    if (days <= 90) return Colors.amber.withValues(alpha: 0.25);
    return null;
  }
}

/// «Камшуда» — products below their minimum stock level.
class _LowStockTab extends ConsumerWidget {
  const _LowStockTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lowStockControllerProvider);
    final controller = ref.read(lowStockControllerProvider.notifier);

    return Column(
      children: [
        Expanded(
          child: _StockTableView<LowStockItem>(
            state: state,
            onRetry: controller.refresh,
            emptyText: 'Доруи камшуда нест',
            minWidth: 640,
            columns: const [
              DataColumn2(label: Text('Дору'), size: ColumnSize.L),
              DataColumn2(label: Text('Бақияи ҷамъ'), numeric: true),
              DataColumn2(label: Text('Минимум'), numeric: true),
              DataColumn2(label: Text('Камбуд'), numeric: true),
            ],
            rowBuilder: (item) => DataRow2(
              cells: [
                DataCell(Text(item.productName)),
                DataCell(Text(_qty(item.totalQuantity))),
                DataCell(Text(_qty(item.minStockLevel))),
                DataCell(Text(_qty(item.shortfall))),
              ],
            ),
          ),
        ),
        _PaginationBar(
          total: state.total,
          page: state.page,
          pageCount: state.pageCount,
          isLoading: state.isLoading,
          hasPrevious: state.hasPrevious,
          hasNext: state.hasNext,
          onPrevious: controller.previousPage,
          onNext: controller.nextPage,
        ),
      ],
    );
  }
}

/// Shared table view: handles error/empty/loading + renders a [DataTable2].
class _StockTableView<T> extends StatelessWidget {
  const _StockTableView({
    required this.state,
    required this.onRetry,
    required this.emptyText,
    required this.minWidth,
    required this.columns,
    required this.rowBuilder,
  });

  final StockTabState<T> state;
  final VoidCallback onRetry;
  final String emptyText;
  final double minWidth;
  final List<DataColumn2> columns;
  final DataRow2 Function(T item) rowBuilder;

  @override
  Widget build(BuildContext context) {
    if (state.failure != null && state.items.isEmpty) {
      return _ErrorView(message: state.failure!.message, onRetry: onRetry);
    }
    if (!state.isLoading && state.items.isEmpty) {
      return _EmptyView(text: emptyText);
    }
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DataTable2(
            columnSpacing: 16,
            horizontalMargin: 12,
            minWidth: minWidth,
            columns: columns,
            rows: [for (final item in state.items) rowBuilder(item)],
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

/// Formats a quantity without a trailing `.0` for whole numbers.
String _qty(double value) =>
    value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.total,
    required this.page,
    required this.pageCount,
    required this.isLoading,
    required this.hasPrevious,
    required this.hasNext,
    required this.onPrevious,
    required this.onNext,
  });

  final int total;
  final int page;
  final int pageCount;
  final bool isLoading;
  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Text('Ҳамагӣ: $total'),
            const Spacer(),
            IconButton(
              tooltip: 'Қаблӣ',
              icon: const Icon(Icons.chevron_left),
              onPressed: hasPrevious && !isLoading ? onPrevious : null,
            ),
            Text('$page / $pageCount'),
            IconButton(
              tooltip: 'Баъдӣ',
              icon: const Icon(Icons.chevron_right),
              onPressed: hasNext && !isLoading ? onNext : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warehouse_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(text),
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

import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/status_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/app_data_table.dart';
import '../../../shared/app_scaffold.dart';
import '../../../shared/status_chip.dart';
import '../data/stock_models.dart';
import 'stock_detail_panel.dart';
import 'stock_provider.dart';

/// Which warehouse view is active (TZ_03 §C.3 view-tabs).
enum StockView { onHand, expiring, low }

/// Currently-selected product for the master-detail [StockDetailPanel].
/// Holds the id + display name (movements are fetched lazily from the id).
class StockSelection {
  const StockSelection({required this.productId, required this.productName});

  final String productId;
  final String productName;
}

/// The active [StockView]; switching tabs keeps the side-panel selection.
final stockViewProvider = StateProvider<StockView>((ref) => StockView.onHand);

/// The selected row for the detail panel (`null` → panel hidden).
final stockSelectionProvider = StateProvider<StockSelection?>((ref) => null);

/// Stock / warehouse screen (Анбор, TZ_03 §C.3) — a desktop master-detail.
///
/// A segmented view-control in the page header switches between three
/// endpoints — «Бақия» (on-hand), «Мӯҳлати наздик» (expiring, with a 30/60/90
/// day selector and expiry-tinted rows), and «Камшуда» (below min level, with a
/// shortfall bar). A search/filter bar sits above an [AppDataTable]; selecting a
/// row opens a [StockDetailPanel] showing the product, its batches, and its
/// movement ledger.
///
/// This is the entry widget wired in the router; its INTERNALS are reworked but
/// the class name/location is preserved.
class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final view = ref.watch(stockViewProvider);
    final selection = ref.watch(stockSelectionProvider);

    // Subtitle = a live count for the active view.
    final subtitle = switch (view) {
      StockView.onHand => _countLabel(
        ref.watch(stockListControllerProvider).total,
        l.stockUnitItems,
      ),
      StockView.expiring => _countLabel(
        ref.watch(expiringStockControllerProvider).total,
        l.stockUnitExpiring,
      ),
      StockView.low => _countLabel(
        ref.watch(lowStockControllerProvider).total,
        l.stockUnitLow,
      ),
    };

    // A real Scaffold hosts the page so it renders standalone (tests) and
    // inside the desktop shell alike, and provides a ScaffoldMessenger for
    // toasts raised from the detail panel.
    return Scaffold(
      body: AppScaffold(
        title: l.stockTitle,
        icon: Icons.warehouse_outlined,
        subtitle: subtitle,
        padBody: false,
        center: _ViewTabs(
          view: view,
          onChanged: (v) => ref.read(stockViewProvider.notifier).state = v,
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: switch (view) {
                StockView.onHand => const _StockListTab(),
                StockView.expiring => const _ExpiringTab(),
                StockView.low => const _LowStockTab(),
              },
            ),
            if (selection != null) ...[
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              StockDetailPanel(
                key: ValueKey(selection.productId),
                selection: selection,
                onClose: () =>
                    ref.read(stockSelectionProvider.notifier).state = null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _countLabel(int total, String noun) => '$total $noun';
}

/// Segmented control for the three stock views (header centre slot).
class _ViewTabs extends StatelessWidget {
  const _ViewTabs({required this.view, required this.onChanged});

  final StockView view;
  final ValueChanged<StockView> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SegmentedButton<StockView>(
      showSelectedIcon: false,
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      segments: [
        ButtonSegment(
          value: StockView.onHand,
          label: Text(l.stockTabOnHand),
          icon: const Icon(Icons.inventory_2_outlined, size: 16),
        ),
        ButtonSegment(
          value: StockView.expiring,
          label: Text(l.stockTabExpiring),
          icon: const Icon(Icons.schedule_outlined, size: 16),
        ),
        ButtonSegment(
          value: StockView.low,
          label: Text(l.stockTabLow),
          icon: const Icon(Icons.trending_down, size: 16),
        ),
      ],
      selected: {view},
      onSelectionChanged: (s) => onChanged(s.first),
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

  void _select(StockItem item) {
    ref.read(stockSelectionProvider.notifier).state = StockSelection(
      productId: item.productId,
      productName: item.productName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(stockListControllerProvider);
    final controller = ref.read(stockListControllerProvider.notifier);
    final selectedId = ref.watch(stockSelectionProvider)?.productId;

    return Column(
      children: [
        _FilterBar(
          searchController: _searchController,
          onSearchChanged: _onSearchChanged,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppDataTable(
              minWidth: 860,
              fixedLeftColumns: 1,
              isLoading: state.isLoading,
              errorMessage: state.failure != null && state.items.isEmpty
                  ? state.failure!.message
                  : null,
              onRetry: controller.refresh,
              emptyMessage: l.stockEmptyOnHand,
              emptyIcon: Icons.warehouse_outlined,
              columns: [
                DataColumn2(label: Text(l.stockColName), size: ColumnSize.L),
                DataColumn2(label: Text(l.stockColBarcode)),
                DataColumn2(label: Text(l.stockColSeries)),
                DataColumn2(label: Text(l.stockColExpiry)),
                DataColumn2(label: Text(l.stockColRemaining), numeric: true),
                DataColumn2(label: Text(l.stockColPrice), numeric: true),
              ],
              rows: [
                for (final item in state.items)
                  DataRow2(
                    selected: item.productId == selectedId,
                    onTap: () => _select(item),
                    cells: [
                      DataCell(Text(item.productName)),
                      DataCell(Text(item.barcode ?? '—')),
                      DataCell(Text(item.seriesNumber)),
                      DataCell(_ExpiryCell(item: item)),
                      DataCell(Text(formatQuantity(item.quantity))),
                      DataCell(_money(item.salePrice)),
                    ],
                  ),
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

/// «Мӯҳлати наздик» — expiring stock; rows tinted by proximity via
/// [StatusColors]. A 30/60/90-day window selector drives the query.
class _ExpiringTab extends ConsumerWidget {
  const _ExpiringTab();

  void _select(WidgetRef ref, StockItem item) {
    ref.read(stockSelectionProvider.notifier).state = StockSelection(
      productId: item.productId,
      productName: item.productName,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(expiringStockControllerProvider);
    final controller = ref.read(expiringStockControllerProvider.notifier);
    final selectedId = ref.watch(stockSelectionProvider)?.productId;
    final status = StatusColors.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(l.stockExpiryLabel),
                    for (final d in const [30, 60, 90])
                      ChoiceChip(
                        label: Text(l.stockDaysOption(d)),
                        selected: controller.days == d,
                        onSelected: (_) => controller.setDays(d),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Flexible(child: _ExpiryLegend()),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppDataTable(
              minWidth: 820,
              fixedLeftColumns: 1,
              isLoading: state.isLoading,
              errorMessage: state.failure != null && state.items.isEmpty
                  ? state.failure!.message
                  : null,
              onRetry: controller.refresh,
              emptyMessage: l.stockEmptyExpiring,
              emptyIcon: Icons.event_available_outlined,
              columns: [
                DataColumn2(label: Text(l.stockColName), size: ColumnSize.L),
                DataColumn2(label: Text(l.stockColSeries)),
                DataColumn2(label: Text(l.stockColExpiry)),
                DataColumn2(label: Text(l.stockColRemainingDays), numeric: true),
                DataColumn2(label: Text(l.stockColRemaining), numeric: true),
              ],
              rows: [
                for (final item in state.items)
                  DataRow2(
                    selected: item.productId == selectedId,
                    color: WidgetStatePropertyAll(
                      _expiryRowTint(item.daysUntilExpiry(), status),
                    ),
                    onTap: () => _select(ref, item),
                    cells: [
                      DataCell(Text(item.productName)),
                      DataCell(Text(item.seriesNumber)),
                      DataCell(_ExpiryCell(item: item, chip: true)),
                      DataCell(Text('${item.daysUntilExpiry()}')),
                      DataCell(Text(formatQuantity(item.quantity))),
                    ],
                  ),
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

/// «Камшуда» — products below their minimum stock level, with a shortfall bar.
class _LowStockTab extends ConsumerWidget {
  const _LowStockTab();

  void _select(WidgetRef ref, LowStockItem item) {
    ref.read(stockSelectionProvider.notifier).state = StockSelection(
      productId: item.productId,
      productName: item.productName,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(lowStockControllerProvider);
    final controller = ref.read(lowStockControllerProvider.notifier);
    final selectedId = ref.watch(stockSelectionProvider)?.productId;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: AppDataTable(
              minWidth: 720,
              fixedLeftColumns: 1,
              isLoading: state.isLoading,
              errorMessage: state.failure != null && state.items.isEmpty
                  ? state.failure!.message
                  : null,
              onRetry: controller.refresh,
              emptyMessage: l.stockEmptyLow,
              emptyIcon: Icons.check_circle_outline,
              columns: [
                DataColumn2(label: Text(l.stockColName), size: ColumnSize.L),
                DataColumn2(label: Text(l.stockColTotalRemaining), numeric: true),
                DataColumn2(label: Text(l.stockColMinimum), numeric: true),
                DataColumn2(label: Text(l.stockColShortfall), size: ColumnSize.L),
              ],
              rows: [
                for (final item in state.items)
                  DataRow2(
                    selected: item.productId == selectedId,
                    onTap: () => _select(ref, item),
                    cells: [
                      DataCell(Text(item.productName)),
                      DataCell(Text(formatQuantity(item.totalQuantity))),
                      DataCell(Text(formatQuantity(item.minStockLevel))),
                      DataCell(_ShortfallBar(item: item)),
                    ],
                  ),
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

/// Search/filter bar above the on-hand table.
class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.searchController,
    required this.onSearchChanged,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: l.stockSearchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    onSearchChanged('');
                  },
                ),
          isDense: true,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

/// Expiry date coloured by proximity tone. In [chip] mode (the dedicated
/// expiring tab) it appends a [StatusChip]; otherwise it stays compact and just
/// tints the date text so it fits the narrow on-hand column.
class _ExpiryCell extends StatelessWidget {
  const _ExpiryCell({required this.item, this.chip = false});

  final StockItem item;
  final bool chip;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final days = item.daysUntilExpiry();
    final (tone, _) = expiryTone(days);
    final color = _toneColor(context, tone);
    final dateText = Text(
      Formatters.date(item.expiryDate),
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: color,
        fontWeight: tone == StatusTone.ok ? null : FontWeight.w600,
      ),
    );
    if (!chip) return dateText;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: dateText),
        const SizedBox(width: 6),
        StatusChip(label: expiryLabel(l, days), tone: tone, dense: true),
      ],
    );
  }

  Color _toneColor(BuildContext context, StatusTone tone) {
    final s = StatusColors.of(context);
    return switch (tone) {
      StatusTone.danger => s.danger,
      StatusTone.warn => s.warn,
      _ => Theme.of(context).colorScheme.onSurface,
    };
  }
}

/// Visual shortfall bar (deficit vs minimum) for the «Камшуда» tab.
class _ShortfallBar extends StatelessWidget {
  const _ShortfallBar({required this.item});

  final LowStockItem item;

  @override
  Widget build(BuildContext context) {
    final status = StatusColors.of(context);
    final ratio = item.minStockLevel <= 0
        ? 1.0
        : (item.totalQuantity / item.minStockLevel).clamp(0.0, 1.0);
    // The redder/emptier the bar, the larger the shortfall.
    final isCritical = ratio <= 0.5;
    final color = isCritical ? status.danger : status.warn;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.18),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '−${formatQuantity(item.shortfall)}',
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Inline legend explaining the expiry colour scale.
class _ExpiryLegend extends StatelessWidget {
  const _ExpiryLegend();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.end,
      children: [
        StatusChip(label: l.stockLegendNear, tone: StatusTone.danger, dense: true),
        StatusChip(label: l.stockLegendSoon, tone: StatusTone.warn, dense: true),
      ],
    );
  }
}

/// Right-aligned money cell with tabular figures.
Widget _money(double value) => Text(
  Formatters.money(value),
  style: const TextStyle(
    fontFeatures: [FontFeature.tabularFigures()],
  ),
);

/// Expiry scale (TZ_03 §B.2): `<0` expired (danger), `0–30` near (danger),
/// `31–90` soon (warn), `>90` healthy (ok). Returns the tone + whether the row
/// should be tinted.
(StatusTone, bool) expiryTone(int days) {
  if (days < 0) return (StatusTone.danger, true);
  if (days <= 30) return (StatusTone.danger, true);
  if (days <= 90) return (StatusTone.warn, true);
  return (StatusTone.ok, false);
}

/// Short label for an expiry chip.
String expiryLabel(AppLocalizations l, int days) {
  if (days < 0) return l.stockExpired;
  return l.stockExpiryDaysShort(days);
}

/// Soft row tint for the expiring table, transparent for healthy rows.
Color _expiryRowTint(int days, StatusColors status) {
  final (tone, tint) = expiryTone(days);
  if (!tint) return Colors.transparent;
  final base = tone == StatusTone.danger ? status.danger : status.warn;
  return base.withValues(alpha: 0.10);
}

/// Formats a quantity without a trailing `.0` for whole numbers.
String formatQuantity(double value) =>
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
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Text(l.commonTotalCount(total)),
            const Spacer(),
            IconButton(
              tooltip: l.commonPrevious,
              icon: const Icon(Icons.chevron_left),
              onPressed: hasPrevious && !isLoading ? onPrevious : null,
            ),
            Text('$page / $pageCount'),
            IconButton(
              tooltip: l.commonNext,
              icon: const Icon(Icons.chevron_right),
              onPressed: hasNext && !isLoading ? onNext : null,
            ),
          ],
        ),
      ),
    );
  }
}

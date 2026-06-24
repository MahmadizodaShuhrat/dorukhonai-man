import 'package:data_table_2/data_table_2.dart';
import 'package:fl_chart/fl_chart.dart';
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
import '../../../shared/status_chip.dart';
import '../../pos/data/pos_models.dart';
import '../../stock/data/stock_models.dart';
import '../data/report_export.dart';
import '../data/report_models.dart';
import 'reports_provider.dart';

/// Reports hub (TZ_03 §C.6 / TZ_01 §4.7). A left rail of report kinds drives a
/// content area with date-range filters, an [AppDataTable] (and an `fl_chart`
/// sales chart), plus PDF/CSV export. The entry widget [ReportsScreen] is the
/// class wired into `router.dart` — only its internals are reworked.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final filter = ref.watch(reportsFilterProvider);
    return AppScaffold(
      title: l.reportsTitle,
      icon: Icons.bar_chart,
      subtitle: filter.kind.label(l),
      padBody: false,
      actions: [
        _ExportButton(
          icon: Icons.picture_as_pdf_outlined,
          label: 'PDF',
          onPressed: () => _export(context, ref, asPdf: true),
        ),
        _ExportButton(
          icon: Icons.table_view_outlined,
          label: 'CSV',
          onPressed: () => _export(context, ref, asPdf: false),
        ),
      ],
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ReportRail(),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: switch (filter.kind) {
                ReportKind.sales => const _SalesView(),
                ReportKind.profit => const _ProfitView(),
                ReportKind.stockValue => const _StockValueView(),
                ReportKind.expiring => const _ExpiringView(),
                ReportKind.zReport => const _ZReportView(),
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _export(
    BuildContext context,
    WidgetRef ref, {
    required bool asPdf,
  }) async {
    final l = AppLocalizations.of(context);
    final filter = ref.read(reportsFilterProvider);
    final table = _currentTable(l, ref, filter);
    if (table == null || table.rows.isEmpty) {
      AppToast.info(context, l.reportsNoExportData);
      return;
    }
    const exporter = ReportExporter();
    try {
      if (asPdf) {
        await exporter.printPdf(table);
      } else {
        final result = await exporter.saveCsv(table);
        if (context.mounted) {
          AppToast.success(context, l.reportsCsvSaved(result.path));
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context, l.reportsExportFailed('$e'));
      }
    }
  }

  /// Builds the export table for the active view from already-loaded data.
  ReportTable? _currentTable(
    AppLocalizations l,
    WidgetRef ref,
    ReportsFilter filter,
  ) {
    final rangeLine =
        '${Formatters.date(filter.range.from)} — ${Formatters.date(filter.range.to)}';
    switch (filter.kind) {
      case ReportKind.sales:
        final rows = ref.read(salesReportProvider).valueOrNull;
        if (rows == null) return null;
        return ReportTable(
          title: l.reportsTitleSales(filter.groupBy.label(l)),
          subtitle: rangeLine,
          headers: [
            l.reportColGroup,
            l.reportColReceipt,
            l.reportColQty,
            l.reportColSubtotal,
            l.reportColDiscount,
            l.reportColTotal,
          ],
          numericColumns: const {1, 2, 3, 4, 5},
          rows: [
            for (final r in rows)
              [
                r.label,
                '${r.salesCount}',
                _qty(r.quantity),
                Formatters.money(r.subtotal),
                Formatters.money(r.discount),
                Formatters.money(r.total),
              ],
          ],
        );
      case ReportKind.profit:
        final p = ref.read(profitReportProvider).valueOrNull;
        if (p == null) return null;
        return ReportTable(
          title: l.reportsTitleProfit,
          subtitle: rangeLine,
          headers: [l.reportColMetric, l.reportColAmount],
          numericColumns: const {1},
          rows: [
            [l.reportRevenue, Formatters.money(p.revenue)],
            [l.reportCost, Formatters.money(p.cost)],
            [l.reportProfit, Formatters.money(p.profit)],
            [l.reportMargin, '${(p.margin * 100).toStringAsFixed(1)}%'],
          ],
        );
      case ReportKind.stockValue:
        final rows = ref.read(stockValueReportProvider).valueOrNull;
        if (rows == null) return null;
        return ReportTable(
          title: l.reportsTitleStockValue,
          headers: [
            l.reportColDrug,
            l.reportColQty,
            l.reportColPurchaseValue,
            l.reportColSaleValue,
          ],
          numericColumns: const {1, 2, 3},
          rows: [
            for (final r in rows)
              [
                r.productName,
                _qty(r.quantity),
                Formatters.money(r.purchaseValue),
                Formatters.money(r.saleValue),
              ],
          ],
        );
      case ReportKind.expiring:
        final rows = ref.read(expiringReportProvider).valueOrNull;
        if (rows == null) return null;
        return ReportTable(
          title: l.reportsTitleExpiring,
          headers: [
            l.reportColDrug,
            l.reportColSeries,
            l.reportColExpiry,
            l.reportColDays,
            l.reportColRemaining,
          ],
          numericColumns: const {3, 4},
          rows: [
            for (final r in rows)
              [
                r.productName,
                r.seriesNumber,
                Formatters.date(r.expiryDate),
                '${r.daysUntilExpiry()}',
                _qty(r.quantity),
              ],
          ],
        );
      case ReportKind.zReport:
        final z = ref.read(zReportProvider).valueOrNull;
        if (z == null) return null;
        return ReportTable(
          title: l.reportsTitleZReport(z.shiftId),
          headers: [l.reportColMetric, l.reportColAmount],
          numericColumns: const {1},
          rows: _zRows(l, z),
        );
    }
  }
}

/// Rows shared by the Z-report table + export.
List<List<String>> _zRows(AppLocalizations l, ZReport z) => [
  [l.reportZOpened, Formatters.dateTime(z.openedAt)],
  if (z.closedAt != null) [l.reportZClosed, Formatters.dateTime(z.closedAt!)],
  [l.reportZOpeningCash, Formatters.money(z.openingCash)],
  [l.reportZSalesCount, '${z.salesCount}'],
  [l.reportZTotalSales, Formatters.money(z.totalSales)],
  [l.reportZReturns, Formatters.money(z.totalReturns)],
  [l.reportZNet, Formatters.money(z.netTotal)],
  [l.reportZCash, Formatters.money(z.amountFor(PaymentMethod.cash))],
  [l.reportZCard, Formatters.money(z.amountFor(PaymentMethod.card))],
  [l.reportZCredit, Formatters.money(z.amountFor(PaymentMethod.credit))],
  [l.reportZExpectedCash, Formatters.money(z.expectedCash)],
  if (z.closingCash != null)
    [l.reportZActualCash, Formatters.money(z.closingCash!)],
];

String _qty(double q) =>
    q == q.roundToDouble() ? q.toInt().toString() : q.toStringAsFixed(2);

// ---------------------------------------------------------------------------
// Left rail
// ---------------------------------------------------------------------------

class _ReportRail extends ConsumerWidget {
  const _ReportRail();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final active = ref.watch(reportsFilterProvider).kind;
    return SizedBox(
      width: 220,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        children: [
          for (final kind in ReportKind.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Material(
                color: kind == active
                    ? theme.colorScheme.secondaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: ListTile(
                  dense: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  leading: Icon(_iconFor(kind), size: 20),
                  title: Text(kind.label(l)),
                  selected: kind == active,
                  onTap: () =>
                      ref.read(reportsFilterProvider.notifier).setKind(kind),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _iconFor(ReportKind kind) => switch (kind) {
    ReportKind.sales => Icons.point_of_sale,
    ReportKind.profit => Icons.trending_up,
    ReportKind.stockValue => Icons.inventory_2_outlined,
    ReportKind.expiring => Icons.event_busy_outlined,
    ReportKind.zReport => Icons.receipt_long,
  };
}

// ---------------------------------------------------------------------------
// Shared filter widgets
// ---------------------------------------------------------------------------

/// Date-range toolbar: two date fields + quick presets.
class _DateRangeBar extends ConsumerWidget {
  const _DateRangeBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final controller = ref.read(reportsFilterProvider.notifier);
    final range = ref.watch(reportsFilterProvider).range;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _DateField(
          label: l.reportDateFrom,
          value: range.from,
          onChanged: controller.setFrom,
        ),
        _DateField(
          label: l.reportDateTo,
          value: range.to,
          onChanged: controller.setTo,
        ),
        FilledButton.tonal(
          onPressed: () => controller.setRange(ReportDateRange.today()),
          child: Text(l.reportPresetToday),
        ),
        FilledButton.tonal(
          onPressed: () => controller.setRange(ReportDateRange.lastDays(7)),
          child: Text(l.reportPreset7Days),
        ),
        FilledButton.tonal(
          onPressed: () => controller.setRange(ReportDateRange.thisMonth()),
          child: Text(l.reportPresetThisMonth),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (picked != null) onChanged(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_today, size: 16),
            isDense: true,
          ),
          child: Text(Formatters.date(value)),
        ),
      ),
    );
  }
}

/// Standard layout for a report view: an optional filter bar above the body.
class _ReportBody extends StatelessWidget {
  const _ReportBody({this.filters, required this.child});

  final Widget? filters;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (filters != null) ...[
          filters!,
          const SizedBox(height: 16),
        ],
        Expanded(child: child),
      ],
    );
  }
}

/// Renders an [AsyncValue] with the shared loading/error/empty chrome.
class _AsyncReport<T> extends StatelessWidget {
  const _AsyncReport({
    required this.value,
    required this.onRetry,
    required this.builder,
    this.isEmpty,
  });

  final AsyncValue<T> value;
  final VoidCallback onRetry;
  final Widget Function(T data) builder;

  /// Optional emptiness test (defaults to never-empty).
  final bool Function(T data)? isEmpty;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return value.when(
      loading: () => const LoadingState(),
      error: (err, _) => EmptyState(
        icon: Icons.error_outline,
        title: l.commonError,
        message: err is Failure ? err.message : l.commonLoadFailed,
        action: FilledButton.tonalIcon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(l.commonRetry),
        ),
      ),
      data: (data) {
        if (isEmpty?.call(data) ?? false) {
          return EmptyState(message: l.commonNoData);
        }
        return builder(data);
      },
    );
  }
}

DataColumn2 _numCol(String label, {ColumnSize size = ColumnSize.S}) =>
    DataColumn2(label: Text(label), numeric: true, size: size);

DataCell _numCell(String text) =>
    DataCell(Align(alignment: Alignment.centerRight, child: Text(text)));

// ---------------------------------------------------------------------------
// Sales view (with chart)
// ---------------------------------------------------------------------------

class _SalesView extends ConsumerWidget {
  const _SalesView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final filter = ref.watch(reportsFilterProvider);
    final async = ref.watch(salesReportProvider);
    return _ReportBody(
      filters: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _DateRangeBar(),
          const SizedBox(height: 12),
          SegmentedButton<SalesGroupBy>(
            segments: [
              for (final g in SalesGroupBy.values)
                ButtonSegment(value: g, label: Text(g.label(l))),
            ],
            selected: {filter.groupBy},
            onSelectionChanged: (s) =>
                ref.read(reportsFilterProvider.notifier).setGroupBy(s.first),
          ),
        ],
      ),
      child: _AsyncReport<List<SalesReportRow>>(
        value: async,
        onRetry: () => ref.invalidate(salesReportProvider),
        isEmpty: (rows) => rows.isEmpty,
        builder: (rows) {
          final showChart = filter.groupBy == SalesGroupBy.day;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showChart) ...[
                SizedBox(height: 220, child: _SalesChart(rows: rows)),
                const SizedBox(height: 16),
              ],
              Expanded(
                child: AppDataTable(
                  columns: [
                    DataColumn2(label: Text(l.reportColGroup), size: ColumnSize.L),
                    _numCol(l.reportColReceipt),
                    _numCol(l.reportColQty),
                    _numCol(l.reportColSubtotal, size: ColumnSize.M),
                    _numCol(l.reportColDiscount, size: ColumnSize.M),
                    _numCol(l.reportColTotal, size: ColumnSize.M),
                  ],
                  rows: [
                    for (final r in rows)
                      DataRow2(
                        cells: [
                          DataCell(Text(r.label)),
                          _numCell('${r.salesCount}'),
                          _numCell(_qty(r.quantity)),
                          _numCell(Formatters.money(r.subtotal)),
                          _numCell(Formatters.money(r.discount)),
                          _numCell(Formatters.money(r.total)),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Bar chart of daily sales totals (TZ_03 §C.6 "optional fl_chart sales chart").
class _SalesChart extends StatelessWidget {
  const _SalesChart({required this.rows});

  final List<SalesReportRow> rows;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (rows.isEmpty) {
      return Center(child: Text(l.reportNoChartData));
    }
    final maxY = rows.fold<double>(0, (m, r) => r.total > m ? r.total : m);
    return BarChart(
      BarChartData(
        maxY: maxY == 0 ? 1 : maxY * 1.2,
        barGroups: [
          for (var i = 0; i < rows.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: rows[i].total,
                  color: theme.colorScheme.primary,
                  width: 14,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
        ],
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 44),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= rows.length) return const SizedBox.shrink();
                final label = _shortLabel(rows[i]);
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(label, style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _shortLabel(SalesReportRow r) {
    final d = r.date;
    if (d != null) return '${d.day}.${d.month}';
    return r.label.length > 6 ? r.label.substring(0, 6) : r.label;
  }
}

// ---------------------------------------------------------------------------
// Profit view
// ---------------------------------------------------------------------------

class _ProfitView extends ConsumerWidget {
  const _ProfitView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(profitReportProvider);
    return _ReportBody(
      filters: const _DateRangeBar(),
      child: _AsyncReport<ProfitReport>(
        value: async,
        onRetry: () => ref.invalidate(profitReportProvider),
        builder: (p) => Align(
          alignment: Alignment.topLeft,
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _MetricCard(
                label: l.reportRevenue,
                value: Formatters.money(p.revenue),
                icon: Icons.payments_outlined,
              ),
              _MetricCard(
                label: l.reportCost,
                value: Formatters.money(p.cost),
                icon: Icons.shopping_cart_outlined,
              ),
              _MetricCard(
                label: l.reportProfit,
                value: Formatters.money(p.profit),
                icon: Icons.trending_up,
                tone: p.profit >= 0 ? StatusTone.ok : StatusTone.danger,
              ),
              _MetricCard(
                label: l.reportMargin,
                value: '${(p.margin * 100).toStringAsFixed(1)}%',
                icon: Icons.percent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.tone,
  });

  final String label;
  final String value;
  final IconData icon;
  final StatusTone? tone;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (tone != null) ...[
            const SizedBox(height: 8),
            StatusChip(
              label: tone == StatusTone.ok ? l.reportPositive : l.reportNegative,
              tone: tone!,
              dense: true,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stock-value view
// ---------------------------------------------------------------------------

class _StockValueView extends ConsumerWidget {
  const _StockValueView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(stockValueReportProvider);
    return _ReportBody(
      child: _AsyncReport<List<StockValueRow>>(
        value: async,
        onRetry: () => ref.invalidate(stockValueReportProvider),
        isEmpty: (rows) => rows.isEmpty,
        builder: (rows) {
          final totalPurchase =
              rows.fold<double>(0, (s, r) => s + r.purchaseValue);
          final totalSale = rows.fold<double>(0, (s, r) => s + r.saleValue);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 16,
                children: [
                  _MetricCard(
                    label: l.reportColPurchaseValue,
                    value: Formatters.money(totalPurchase),
                    icon: Icons.inventory_2_outlined,
                  ),
                  _MetricCard(
                    label: l.reportColSaleValue,
                    value: Formatters.money(totalSale),
                    icon: Icons.sell_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AppDataTable(
                  columns: [
                    DataColumn2(label: Text(l.reportColDrug), size: ColumnSize.L),
                    _numCol(l.reportColQty),
                    _numCol(l.reportColPurchaseValue, size: ColumnSize.M),
                    _numCol(l.reportColSaleValue, size: ColumnSize.M),
                  ],
                  rows: [
                    for (final r in rows)
                      DataRow2(
                        cells: [
                          DataCell(Text(r.productName)),
                          _numCell(_qty(r.quantity)),
                          _numCell(Formatters.money(r.purchaseValue)),
                          _numCell(Formatters.money(r.saleValue)),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Expiring view
// ---------------------------------------------------------------------------

class _ExpiringView extends ConsumerWidget {
  const _ExpiringView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(expiringReportProvider);
    return _ReportBody(
      child: _AsyncReport<List<StockItem>>(
        value: async,
        onRetry: () => ref.invalidate(expiringReportProvider),
        isEmpty: (rows) => rows.isEmpty,
        builder: (rows) => AppDataTable(
          columns: [
            DataColumn2(label: Text(l.reportColDrug), size: ColumnSize.L),
            DataColumn2(label: Text(l.reportColSeries)),
            DataColumn2(label: Text(l.reportColExpiry)),
            _numCol(l.reportColDays),
            _numCol(l.reportColRemaining),
          ],
          rows: [
            for (final r in rows)
              DataRow2(
                cells: [
                  DataCell(Text(r.productName)),
                  DataCell(Text(r.seriesNumber)),
                  DataCell(Text(Formatters.date(r.expiryDate))),
                  DataCell(
                    Align(
                      alignment: Alignment.centerRight,
                      child: StatusChip(
                        label: '${r.daysUntilExpiry()}',
                        tone: _expiryTone(r.daysUntilExpiry()),
                        dense: true,
                      ),
                    ),
                  ),
                  _numCell(_qty(r.quantity)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Expiry scale (TZ_03 §B.2): <=30 danger, <=90 warn, else ok.
  StatusTone _expiryTone(int days) {
    if (days <= 30) return StatusTone.danger;
    if (days <= 90) return StatusTone.warn;
    return StatusTone.ok;
  }
}

// ---------------------------------------------------------------------------
// Z-report view
// ---------------------------------------------------------------------------

class _ZReportView extends ConsumerStatefulWidget {
  const _ZReportView();

  @override
  ConsumerState<_ZReportView> createState() => _ZReportViewState();
}

class _ZReportViewState extends ConsumerState<_ZReportView> {
  late final TextEditingController _shiftController;

  @override
  void initState() {
    super.initState();
    _shiftController = TextEditingController(
      text: ref.read(reportsFilterProvider).shiftId ?? '',
    );
  }

  @override
  void dispose() {
    _shiftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(zReportProvider);
    return _ReportBody(
      filters: Row(
        children: [
          SizedBox(
            width: 320,
            child: TextField(
              controller: _shiftController,
              decoration: InputDecoration(
                labelText: l.reportShiftIdField,
                prefixIcon: const Icon(Icons.tag, size: 16),
                isDense: true,
              ),
              onSubmitted: (v) =>
                  ref.read(reportsFilterProvider.notifier).setShiftId(v.trim()),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: () => ref
                .read(reportsFilterProvider.notifier)
                .setShiftId(_shiftController.text.trim()),
            icon: const Icon(Icons.search),
            label: Text(l.commonOpen),
          ),
        ],
      ),
      child: _AsyncReport<ZReport?>(
        value: async,
        onRetry: () => ref.invalidate(zReportProvider),
        builder: (z) {
          if (z == null) {
            return EmptyState(
              icon: Icons.receipt_long,
              message: l.reportEnterShiftId,
            );
          }
          final pairs = _zRows(l, z);
          return AppDataTable(
            columns: [
              DataColumn2(label: Text(l.reportColMetric), size: ColumnSize.L),
              DataColumn2(label: Text(l.reportColAmount), numeric: true),
            ],
            rows: [
              for (final pair in pairs)
                DataRow2(
                  cells: [
                    DataCell(Text(pair[0])),
                    _numCell(pair[1]),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Export button
// ---------------------------------------------------------------------------

class _ExportButton extends StatelessWidget {
  const _ExportButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

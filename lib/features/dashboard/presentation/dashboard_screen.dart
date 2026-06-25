import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/status_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/app_scaffold.dart';
import '../../../shared/empty_state.dart';
import '../../../shared/loading_state.dart';
import '../../../shared/status_chip.dart';
import '../../pos/data/pos_models.dart';
import '../../stock/data/stock_models.dart';
import 'dashboard_providers.dart';

/// Desktop dashboard (TZ_03 §C.1): a KPI row, near-expiry + low-stock preview
/// lists, a quick-actions panel, and a 7-day sales sparkline. All data is read
/// through [dashboard_providers]; widgets hold no business logic.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return AppScaffold(
      title: l.dashTitle,
      icon: Icons.dashboard_outlined,
      subtitle: l.dashSubtitleToday(Formatters.date(DateTime.now())),
      actions: [
        IconButton(
          tooltip: l.commonRefresh,
          icon: const Icon(Icons.refresh),
          onPressed: () => _refreshAll(ref),
        ),
      ],
      body: ListView(
        children: const [
          _KpiRow(),
          SizedBox(height: 16),
          _AlertsRow(),
          SizedBox(height: 16),
          _SalesTrendCard(),
        ],
      ),
    );
  }

  void _refreshAll(WidgetRef ref) {
    ref.invalidate(todaySalesProvider);
    ref.invalidate(currentShiftProvider);
    ref.invalidate(expiringStockProvider);
    ref.invalidate(lowStockProvider);
    ref.invalidate(salesTrendProvider);
  }
}

// ---------------------------------------------------------------------------
// KPI ROW
// ---------------------------------------------------------------------------

class _KpiRow extends ConsumerWidget {
  const _KpiRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todaySalesProvider);
    final expiring = ref.watch(expiringStockProvider);
    final low = ref.watch(lowStockProvider);
    final shift = ref.watch(currentShiftProvider);
    final status = StatusColors.of(context);
    final l = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // 4-up on wide screens, 2-up when the content area gets narrow.
        final columns = constraints.maxWidth < 880 ? 2 : 4;
        const spacing = 16.0;
        final cardWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: cardWidth,
              child: _KpiCard(
                label: l.dashKpiTodaySales,
                icon: Icons.point_of_sale_outlined,
                onTap: () => context.go(AppRoutes.pos),
                child: today.when(
                  loading: () => const _KpiSkeleton(),
                  error: (_, _) => const _KpiError(),
                  data: (d) => _KpiValue(
                    value: Formatters.money(d.total),
                    caption: l.dashKpiReceiptsCount(d.count),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _KpiCard(
                label: l.dashKpiExpiringSoon(kExpiringWindowDays),
                icon: Icons.event_busy_outlined,
                accent: status.warn,
                onTap: () => context.go(AppRoutes.stock),
                child: expiring.when(
                  loading: () => const _KpiSkeleton(),
                  error: (_, _) => const _KpiError(),
                  data: (p) => _KpiValue(
                    value: '${p.total}',
                    caption: l.dashKpiDrugUnit,
                    valueColor: p.total > 0 ? status.warn : null,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _KpiCard(
                label: l.dashKpiLowStock,
                icon: Icons.trending_down_outlined,
                accent: status.danger,
                onTap: () => context.go(AppRoutes.stock),
                child: low.when(
                  loading: () => const _KpiSkeleton(),
                  error: (_, _) => const _KpiError(),
                  data: (p) => _KpiValue(
                    value: '${p.total}',
                    caption: l.dashKpiDrugUnit,
                    valueColor: p.total > 0 ? status.danger : null,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _KpiCard(
                label: l.dashKpiShift,
                icon: Icons.access_time_outlined,
                onTap: () => context.go(AppRoutes.pos),
                child: shift.when(
                  loading: () => const _KpiSkeleton(),
                  error: (_, _) => const _KpiError(),
                  data: (s) => _ShiftValue(shift: s),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A single KPI card: flat-bordered surface, label header, large value slot,
/// optional accent strip, click-through (TZ_03 §B.4 flat-bordered cards).
class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.icon,
    required this.child,
    this.accent,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Widget child;
  final Color? accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _BorderedCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (accent != null)
            Container(height: 3, color: accent),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: accent ?? theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 0.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiValue extends StatelessWidget {
  const _KpiValue({required this.value, this.caption, this.valueColor});

  final String value;
  final String? caption;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 2),
          Text(
            caption!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// Shift KPI value: green "Кушода · HH:mm" or grey "Баста".
class _ShiftValue extends StatelessWidget {
  const _ShiftValue({required this.shift});

  final CashShift? shift;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = StatusColors.of(context);
    final l = AppLocalizations.of(context);
    final open = shift != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.circle, size: 12, color: open ? status.ok : theme.colorScheme.outline),
            const SizedBox(width: 6),
            Text(
              open ? l.dashShiftOpen : l.dashShiftClosed,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: open ? status.ok : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          open ? Formatters.dateTime(shift!.openedAt) : l.dashShiftNotOpen,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _KpiSkeleton extends StatelessWidget {
  const _KpiSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}

class _KpiError extends StatelessWidget {
  const _KpiError();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SizedBox(
      height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          l.dashKpiErrorShort,
          style: TextStyle(color: StatusColors.of(context).danger),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ALERTS ROW: near-expiry list + low-stock list + quick actions
// ---------------------------------------------------------------------------

class _AlertsRow extends StatelessWidget {
  const _AlertsRow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        // Stack vertically on narrow widths; otherwise three columns.
        if (constraints.maxWidth < 980) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 360, child: _ExpiringCard()),
              SizedBox(height: spacing),
              SizedBox(height: 320, child: _LowStockCard()),
              SizedBox(height: spacing),
              _QuickActionsCard(),
            ],
          );
        }
        // Fixed-height row (not IntrinsicHeight): the cards contain scrolling
        // ListViews (viewports), whose intrinsic height cannot be measured —
        // IntrinsicHeight would crash. A bounded height lets each card's inner
        // list scroll within it.
        return const SizedBox(
          height: 360,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 4, child: _ExpiringCard()),
              SizedBox(width: spacing),
              Expanded(flex: 3, child: _LowStockCard()),
              SizedBox(width: spacing),
              Expanded(flex: 3, child: _QuickActionsCard()),
            ],
          ),
        );
      },
    );
  }
}

class _ExpiringCard extends ConsumerWidget {
  const _ExpiringCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expiring = ref.watch(expiringStockProvider);
    final status = StatusColors.of(context);
    final l = AppLocalizations.of(context);
    return _SectionCard(
      title: l.dashExpiringTitle,
      icon: Icons.warning_amber_rounded,
      iconColor: status.warn,
      footer: _SeeAllButton(
        label: l.dashSeeAllStock,
        onPressed: () => context.go(AppRoutes.stock),
      ),
      child: expiring.when(
        loading: () => const LoadingState(),
        error: (e, _) => _SectionError(onRetry: () => ref.invalidate(expiringStockProvider)),
        data: (paged) {
          final rows = _sortedByExpiry(paged.items).take(kPreviewRows).toList();
          if (rows.isEmpty) {
            return EmptyState(
              icon: Icons.verified_outlined,
              message: l.dashNoExpiring,
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _ExpiringHeaderRow(),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) => _ExpiringRow(item: rows[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<StockItem> _sortedByExpiry(List<StockItem> items) {
    final sorted = [...items]
      ..sort((a, b) => a.daysUntilExpiry().compareTo(b.daysUntilExpiry()));
    return sorted;
  }
}

class _ExpiringHeaderRow extends StatelessWidget {
  const _ExpiringHeaderRow();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(l.dashColDrug, style: style)),
          Expanded(flex: 2, child: Text(l.dashColSeries, style: style)),
          Expanded(flex: 3, child: Text(l.dashColExpiry, style: style)),
          Expanded(
            flex: 2,
            child: Text(l.dashColRemaining, style: style, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _ExpiringRow extends StatelessWidget {
  const _ExpiringRow({required this.item});

  final StockItem item;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final days = item.daysUntilExpiry();
    final (tone, label) = _expiryTone(l, days);
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => context.go(AppRoutes.stock),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                item.productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                item.seriesNumber,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: StatusChip(label: label, tone: tone, dense: true),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _qty(item.quantity),
                textAlign: TextAlign.right,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LowStockCard extends ConsumerWidget {
  const _LowStockCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final low = ref.watch(lowStockProvider);
    final status = StatusColors.of(context);
    final l = AppLocalizations.of(context);
    return _SectionCard(
      title: l.dashLowStockTitle,
      icon: Icons.production_quantity_limits_outlined,
      iconColor: status.danger,
      footer: _SeeAllButton(
        label: l.dashSeeAllStock,
        onPressed: () => context.go(AppRoutes.stock),
      ),
      child: low.when(
        loading: () => const LoadingState(),
        error: (e, _) => _SectionError(onRetry: () => ref.invalidate(lowStockProvider)),
        data: (paged) {
          final rows = paged.items.take(kPreviewRows).toList();
          if (rows.isEmpty) {
            return EmptyState(
              icon: Icons.inventory_2_outlined,
              message: l.dashNoLowStock,
            );
          }
          return ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) => _LowStockRow(item: rows[i]),
          );
        },
      ),
    );
  }
}

class _LowStockRow extends StatelessWidget {
  const _LowStockRow({required this.item});

  final LowStockItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = StatusColors.of(context);
    final ratio = item.minStockLevel <= 0
        ? 0.0
        : (item.totalQuantity / item.minStockLevel).clamp(0.0, 1.0);
    return InkWell(
      onTap: () => context.go(AppRoutes.stock),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Text(
                  '${_qty(item.totalQuantity)} / ${_qty(item.minStockLevel)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: status.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 5,
                backgroundColor: status.dangerContainer,
                valueColor: AlwaysStoppedAnimation(status.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsCard extends ConsumerWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shift = ref.watch(currentShiftProvider);
    final shiftOpen = shift.maybeWhen(data: (s) => s != null, orElse: () => false);
    final l = AppLocalizations.of(context);
    return _SectionCard(
      title: l.dashQuickActions,
      icon: Icons.bolt_outlined,
      expandChild: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _QuickAction(
            icon: Icons.add,
            label: l.dashQuickNewReceipt,
            onPressed: () => context.go(AppRoutes.receipts),
          ),
          const SizedBox(height: 10),
          _QuickAction(
            icon: shiftOpen ? Icons.lock_clock_outlined : Icons.play_arrow_outlined,
            label: shiftOpen ? l.dashQuickCloseShift : l.dashQuickOpenShift,
            onPressed: () => context.go(AppRoutes.pos),
          ),
          const SizedBox(height: 10),
          _QuickAction(
            icon: Icons.point_of_sale_outlined,
            label: l.dashQuickSale,
            onPressed: () => context.go(AppRoutes.pos),
          ),
          const SizedBox(height: 10),
          _QuickAction(
            icon: Icons.search,
            label: l.dashQuickSearchDrug,
            onPressed: () => context.go(AppRoutes.stock),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Align(alignment: Alignment.centerLeft, child: Text(label)),
      style: FilledButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        minimumSize: const Size.fromHeight(0),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SALES TREND (7-day bar chart)
// ---------------------------------------------------------------------------

class _SalesTrendCard extends ConsumerWidget {
  const _SalesTrendCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trend = ref.watch(salesTrendProvider);
    final l = AppLocalizations.of(context);
    return SizedBox(
      height: 240,
      child: _SectionCard(
        title: l.dashSalesTrendTitle,
        icon: Icons.bar_chart_outlined,
        child: trend.when(
          loading: () => const LoadingState(),
          error: (e, _) =>
              _SectionError(onRetry: () => ref.invalidate(salesTrendProvider)),
          data: (days) {
            if (days.every((d) => d.total == 0)) {
              return EmptyState(
                icon: Icons.show_chart_outlined,
                message: l.dashNoSalesTrend,
              );
            }
            return _SalesBarChart(days: days);
          },
        ),
      ),
    );
  }
}

class _SalesBarChart extends StatelessWidget {
  const _SalesBarChart({required this.days});

  final List<DailySales> days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final maxY = days.fold<double>(0, (m, d) => d.total > m ? d.total : m);
    final chartMax = maxY <= 0 ? 1.0 : maxY * 1.25;
    final dow = [l.dowMon, l.dowTue, l.dowWed, l.dowThu, l.dowFri, l.dowSat, l.dowSun];

    return Padding(
      padding: const EdgeInsets.only(top: 12, right: 8),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: chartMax,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY <= 0 ? 1 : maxY / 2,
            getDrawingHorizontalLine: (_) => FlLine(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              strokeWidth: 1,
              dashArray: const [4, 5],
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= days.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      dow[days[i].day.weekday - 1],
                      style: theme.textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, _) {
                final d = days[group.x];
                return BarTooltipItem(
                  '${Formatters.date(d.day)}\n${Formatters.money(d.total)}',
                  theme.textTheme.bodySmall!.copyWith(
                    color: theme.colorScheme.onInverseSurface,
                  ),
                );
              },
            ),
          ),
          barGroups: [
            for (var i = 0; i < days.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: days[i].total,
                    width: 22,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(7),
                    ),
                    // Modern vertical gradient (deep → light teal).
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.55),
                      ],
                    ),
                    // Faint full-height track behind every bar so the chart
                    // looks intentional even on zero-sale days.
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: chartMax,
                      color: theme.colorScheme.primary.withValues(alpha: 0.06),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared building blocks
// ---------------------------------------------------------------------------

/// Flat-bordered surface (elevation 0, outlineVariant border, radius 10) per
/// TZ_03 §B.4. Optionally tappable for click-through KPIs.
class _BorderedCard extends StatelessWidget {
  const _BorderedCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// A titled section card with a header row (icon + title + optional footer).
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.iconColor,
    this.footer,
    this.expandChild = true,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Color? iconColor;
  final Widget? footer;

  /// When `true` (the height-bounded cards), [child] fills the remaining space
  /// via [Expanded]. The quick-actions card shrink-wraps instead, so it can be
  /// dropped into an unbounded [Column] on narrow layouts.
  final bool expandChild;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _BorderedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor ?? theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          if (expandChild) Expanded(child: child) else child,
          if (footer != null) ...[
            const SizedBox(height: 4),
            footer!,
          ],
        ],
      ),
    );
  }
}

class _SeeAllButton extends StatelessWidget {
  const _SeeAllButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(onPressed: onPressed, child: Text(label)),
    );
  }
}

class _SectionError extends StatelessWidget {
  const _SectionError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return EmptyState(
      icon: Icons.error_outline,
      title: l.commonError,
      message: l.commonLoadDataFailed,
      action: FilledButton.tonalIcon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: Text(l.commonRetry),
      ),
    );
  }
}

/// Days-to-expiry → (chip tone, label). Mirrors the stock scale (TZ_03 §B.2):
/// `<0` gone (red), `0–30` near (red), `31–90` soon (amber), `>90` ok (green).
(StatusTone, String) _expiryTone(AppLocalizations l, int days) {
  if (days < 0) return (StatusTone.danger, l.dashExpiryGone);
  if (days <= 30) return (StatusTone.danger, l.dashExpiryDays(days));
  if (days <= 90) return (StatusTone.warn, l.dashExpiryDays(days));
  return (StatusTone.ok, l.dashExpiryDays(days));
}

/// Compact quantity: drops a trailing `.0` for whole numbers.
String _qty(double value) =>
    value == value.roundToDouble() ? value.toInt().toString() : value.toString();

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../pos/data/pos_models.dart';
import '../../stock/data/stock_models.dart';
import '../data/report_models.dart';
import '../data/reports_repository.dart';

/// The available report views shown in the left rail (TZ_03 §C.6).
enum ReportKind {
  sales('Фурӯш'),
  profit('Фоида'),
  stockValue('Арзиши анбор'),
  expiring('Мӯҳлаташ наздик'),
  zReport('Z-ҳисобот');

  const ReportKind(this.label);

  /// Tajik UI label for the rail.
  final String label;
}

/// An inclusive date range for date-windowed reports.
@immutable
class ReportDateRange {
  const ReportDateRange(this.from, this.to);

  final DateTime from;
  final DateTime to;

  /// Today (single day).
  factory ReportDateRange.today() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return ReportDateRange(start, start);
  }

  /// Last [days] days ending today (inclusive).
  factory ReportDateRange.lastDays(int days) {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    return ReportDateRange(end.subtract(Duration(days: days - 1)), end);
  }

  /// The current calendar month up to today.
  factory ReportDateRange.thisMonth() {
    final now = DateTime.now();
    return ReportDateRange(
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month, now.day),
    );
  }

  ReportDateRange copyWith({DateTime? from, DateTime? to}) =>
      ReportDateRange(from ?? this.from, to ?? this.to);

  @override
  bool operator ==(Object other) =>
      other is ReportDateRange && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}

/// UI filter state shared across the report views: which report is active, the
/// date window, the sales grouping, and (for Z-report) the selected shift id.
@immutable
class ReportsFilter {
  const ReportsFilter({
    this.kind = ReportKind.sales,
    required this.range,
    this.groupBy = SalesGroupBy.day,
    this.shiftId,
  });

  final ReportKind kind;
  final ReportDateRange range;
  final SalesGroupBy groupBy;

  /// Shift id entered for the Z-report view (`null` until provided).
  final String? shiftId;

  ReportsFilter copyWith({
    ReportKind? kind,
    ReportDateRange? range,
    SalesGroupBy? groupBy,
    String? shiftId,
    bool clearShiftId = false,
  }) {
    return ReportsFilter(
      kind: kind ?? this.kind,
      range: range ?? this.range,
      groupBy: groupBy ?? this.groupBy,
      shiftId: clearShiftId ? null : (shiftId ?? this.shiftId),
    );
  }
}

/// Holds the [ReportsFilter] and lets the screen mutate it. No fetching here —
/// the family data providers below watch this and re-fetch on change.
class ReportsFilterController extends StateNotifier<ReportsFilter> {
  ReportsFilterController()
    : super(ReportsFilter(range: ReportDateRange.lastDays(7)));

  void setKind(ReportKind kind) => state = state.copyWith(kind: kind);

  void setRange(ReportDateRange range) => state = state.copyWith(range: range);

  void setFrom(DateTime from) =>
      state = state.copyWith(range: state.range.copyWith(from: from));

  void setTo(DateTime to) =>
      state = state.copyWith(range: state.range.copyWith(to: to));

  void setGroupBy(SalesGroupBy groupBy) =>
      state = state.copyWith(groupBy: groupBy);

  void setShiftId(String? shiftId) => state = (shiftId == null || shiftId.isEmpty)
      ? state.copyWith(clearShiftId: true)
      : state.copyWith(shiftId: shiftId);
}

/// Current reports filter (rail selection + date range + grouping + shift).
final reportsFilterProvider =
    StateNotifierProvider<ReportsFilterController, ReportsFilter>(
      (ref) => ReportsFilterController(),
    );

/// Sales report rows for the current range + grouping. Throws the [Failure] so
/// the UI can render it via `AsyncValue.error`.
final salesReportProvider = FutureProvider<List<SalesReportRow>>((ref) async {
  final filter = ref.watch(reportsFilterProvider);
  final repo = ref.watch(reportsRepositoryProvider);
  final result = await repo.sales(
    from: filter.range.from,
    to: filter.range.to,
    groupBy: filter.groupBy,
  );
  return switch (result) {
    Success(:final data) => data,
    Error(:final failure) => throw failure,
  };
});

/// Aggregate profit for the current range.
final profitReportProvider = FutureProvider<ProfitReport>((ref) async {
  final filter = ref.watch(reportsFilterProvider);
  final repo = ref.watch(reportsRepositoryProvider);
  final result = await repo.profit(
    from: filter.range.from,
    to: filter.range.to,
  );
  return switch (result) {
    Success(:final data) => data,
    Error(:final failure) => throw failure,
  };
});

/// Current stock value (per-product rows).
final stockValueReportProvider =
    FutureProvider<List<StockValueRow>>((ref) async {
      final repo = ref.watch(reportsRepositoryProvider);
      final result = await repo.stockValue();
      return switch (result) {
        Success(:final data) => data,
        Error(:final failure) => throw failure,
      };
    });

/// Products expiring soon.
final expiringReportProvider = FutureProvider<List<StockItem>>((ref) async {
  final repo = ref.watch(reportsRepositoryProvider);
  final result = await repo.expiring();
  return switch (result) {
    Success(:final data) => data,
    Error(:final failure) => throw failure,
  };
});

/// Z-report for the shift id entered in the filter. Returns `null` when no
/// shift id has been supplied yet (so the view can prompt for one).
final zReportProvider = FutureProvider<ZReport?>((ref) async {
  final shiftId = ref.watch(reportsFilterProvider).shiftId;
  if (shiftId == null || shiftId.isEmpty) return null;
  final repo = ref.watch(reportsRepositoryProvider);
  final result = await repo.zReport(shiftId);
  return switch (result) {
    Success(:final data) => data,
    Error(:final failure) => throw failure,
  };
});

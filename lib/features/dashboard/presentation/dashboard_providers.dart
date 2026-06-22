import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/api/paged.dart';
import '../../branch/presentation/branch_provider.dart';
import '../../pos/data/pos_models.dart';
import '../../pos/data/pos_repository.dart';
import '../../stock/data/stock_models.dart';
import '../../stock/data/stock_repository.dart';

/// Read-only providers backing the dashboard (TZ_03 §C.1). They reuse the
/// existing stock/POS repositories; no new endpoints are introduced. Each is a
/// `FutureProvider` so the UI can render the shared loading/error/empty states
/// and refresh independently.
///
/// `autoDispose` keeps the data fresh: the dashboard re-fetches every time it
/// is shown (e.g. after returning from a sale or opening a shift).

/// Number of days used for the "Мӯҳлаташ наздик" (near-expiry) widget/KPI.
const int kExpiringWindowDays = 90;

/// How many rows the near-expiry / low-stock preview lists show.
const int kPreviewRows = 8;

/// How many days of history the sales sparkline covers.
const int kSalesSparkDays = 7;

/// Aggregated daily sales total for the 7-day sparkline.
class DailySales {
  const DailySales({required this.day, required this.total, required this.count});

  /// Date-only key for the bucket.
  final DateTime day;

  /// Sum of [Sale.total] for the day.
  final double total;

  /// Number of sales (cheques) for the day.
  final int count;
}

/// Today's sales summary (total revenue + cheque count) derived from the
/// `GET /sales?from=&to=` list for the current day.
class TodaySales {
  const TodaySales({required this.total, required this.count});

  static const empty = TodaySales(total: 0, count: 0);

  final double total;
  final int count;
}

/// Returns midnight (date-only) of [value].
DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// Pages through `GET /sales` for [from, to) and returns every header. The list
/// endpoint is paged (envelope `{items,total,page,size}`); the dashboard needs
/// the full day/window, so we follow pages until exhausted (capped for safety).
Future<List<Sale>> _fetchSales(
  PosRepository repo, {
  required DateTime from,
  required DateTime to,
}) async {
  const size = 100;
  const maxPages = 50; // safety cap (~5000 sales)
  final all = <Sale>[];
  var page = 1;
  while (page <= maxPages) {
    final result = await repo.listSales(
      from: from,
      to: to,
      page: page,
      size: size,
    );
    switch (result) {
      case Success(:final data):
        all.addAll(data.items);
        if (data.items.isEmpty || all.length >= data.total) {
          return all;
        }
        page++;
      case Error(:final failure):
        throw failure;
    }
  }
  return all;
}

/// Today's revenue + cheque count (`GET /sales?from=today&to=tomorrow`).
final todaySalesProvider = FutureProvider.autoDispose<TodaySales>((ref) async {
  final repo = ref.watch(posRepositoryProvider);
  final start = _dateOnly(DateTime.now());
  final end = start.add(const Duration(days: 1));
  final sales = await _fetchSales(repo, from: start, to: end);
  if (sales.isEmpty) return TodaySales.empty;
  final total = sales.fold<double>(0, (sum, s) => sum + s.total);
  return TodaySales(total: total, count: sales.length);
});

/// Daily sales totals for the trailing [kSalesSparkDays] days (oldest → newest),
/// with empty days filled in as zero so the chart has a continuous axis.
final salesTrendProvider =
    FutureProvider.autoDispose<List<DailySales>>((ref) async {
  final repo = ref.watch(posRepositoryProvider);
  final today = _dateOnly(DateTime.now());
  final start = today.subtract(const Duration(days: kSalesSparkDays - 1));
  final end = today.add(const Duration(days: 1));
  final sales = await _fetchSales(repo, from: start, to: end);

  final totals = <DateTime, double>{};
  final counts = <DateTime, int>{};
  for (final sale in sales) {
    final key = _dateOnly(sale.createdAt);
    totals[key] = (totals[key] ?? 0) + sale.total;
    counts[key] = (counts[key] ?? 0) + 1;
  }

  return List<DailySales>.generate(kSalesSparkDays, (i) {
    final day = start.add(Duration(days: i));
    return DailySales(
      day: day,
      total: totals[day] ?? 0,
      count: counts[day] ?? 0,
    );
  });
});

/// The current open shift, or `null` when no shift is open (a 404 from the API
/// is treated as "no open shift", not an error).
final currentShiftProvider =
    FutureProvider.autoDispose<CashShift?>((ref) async {
  final repo = ref.watch(posRepositoryProvider);
  // Query the REAL branch (TZ_05 FW1) so the KPI matches POS instead of hitting
  // Guid.Empty. A null id simply omits the param (server resolves the default).
  final branchId = ref.watch(currentBranchIdProvider);
  final result = await repo.currentShift(branchId: branchId);
  switch (result) {
    case Success(:final data):
      return data.status.isOpen ? data : null;
    case Error(:final failure):
      // No open shift → server replies 404; surface as "closed", not an error.
      if (failure case ServerFailure(:final statusCode) when statusCode == 404) {
        return null;
      }
      throw failure;
  }
});

/// Near-expiry batches within [kExpiringWindowDays]. The full first page is
/// fetched; the KPI uses [Paged.total] and the preview list shows the top rows
/// sorted by soonest expiry.
final expiringStockProvider =
    FutureProvider.autoDispose<Paged<StockItem>>((ref) async {
  final repo = ref.watch(stockRepositoryProvider);
  final result = await repo.expiring(days: kExpiringWindowDays, page: 1, size: 50);
  switch (result) {
    case Success(:final data):
      return data;
    case Error(:final failure):
      throw failure;
  }
});

/// Low-stock alerts (`totalQuantity < minStockLevel`).
final lowStockProvider =
    FutureProvider.autoDispose<Paged<LowStockItem>>((ref) async {
  final repo = ref.watch(stockRepositoryProvider);
  final result = await repo.low(page: 1, size: 50);
  switch (result) {
    case Success(:final data):
      return data;
    case Error(:final failure):
      throw failure;
  }
});

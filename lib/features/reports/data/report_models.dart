/// Reports (Ҳисоботҳо) models — plain Dart with hand-written `fromJson`
/// (no codegen, per project rules). Field names match the API contract
/// EXACTLY (camelCase). These are read-only projections, so there is no
/// `toJson`. See TZ_01 §4.7 and TZ_03 §C.6.
library;

import '../../../l10n/app_localizations.dart';

/// How a sales report is grouped (the `groupBy` query parameter of
/// `GET /reports/sales`).
enum SalesGroupBy {
  day('day'),
  product('product'),
  seller('seller');

  const SalesGroupBy(this.wire);

  /// The exact token used on the wire (`?groupBy=`).
  final String wire;

  /// Localized UI label for the segmented selector.
  String label(AppLocalizations l) => switch (this) {
    SalesGroupBy.day => l.reportGroupByDay,
    SalesGroupBy.product => l.reportGroupByProduct,
    SalesGroupBy.seller => l.reportGroupBySeller,
  };
}

/// A single grouped sales row from `GET /reports/sales?groupBy=`.
///
/// The server groups by day / product / seller; each row carries a [label]
/// (the group key — a date, product name, or seller name), the number of
/// receipts, the quantity sold, and the money totals.
///
/// Contract (tolerant): `{ key|label|date|productName|sellerName, salesCount|
/// count, quantity, subtotal?, discount?, total }`.
class SalesReportRow {
  const SalesReportRow({
    required this.label,
    required this.salesCount,
    required this.quantity,
    required this.subtotal,
    required this.discount,
    required this.total,
    this.date,
  });

  /// Group key rendered in the first column (date string / product / seller).
  final String label;
  final int salesCount;
  final double quantity;
  final double subtotal;
  final double discount;
  final double total;

  /// Parsed date when the row is a day bucket (used for the chart axis).
  final DateTime? date;

  factory SalesReportRow.fromJson(Map<String, dynamic> json) {
    final dateRaw =
        (json['date'] ?? json['day'] ?? json['key']) as String?;
    final parsedDate =
        dateRaw == null ? null : DateTime.tryParse(dateRaw);
    final label =
        (json['label'] ??
                json['key'] ??
                json['productName'] ??
                json['sellerName'] ??
                json['userName'] ??
                json['date'] ??
                json['day'] ??
                '—')
            .toString();
    return SalesReportRow(
      label: label,
      salesCount:
          (json['salesCount'] as num?)?.toInt() ??
          (json['count'] as num?)?.toInt() ??
          0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      date: parsedDate,
    );
  }
}

/// Aggregate profit figures from `GET /reports/profit?from=&to=`.
///
/// Contract (tolerant): `{ revenue, cost, profit, margin? }`. [margin] is the
/// profit/revenue ratio (0..1); computed locally when the server omits it.
class ProfitReport {
  const ProfitReport({
    required this.revenue,
    required this.cost,
    required this.profit,
    required this.margin,
  });

  final double revenue;
  final double cost;
  final double profit;

  /// Profit margin as a fraction (0..1).
  final double margin;

  factory ProfitReport.fromJson(Map<String, dynamic> json) {
    final revenue = (json['revenue'] as num?)?.toDouble() ?? 0;
    final cost = (json['cost'] as num?)?.toDouble() ?? 0;
    final profit =
        (json['profit'] as num?)?.toDouble() ?? (revenue - cost);
    final rawMargin = (json['margin'] as num?)?.toDouble();
    return ProfitReport(
      revenue: revenue,
      cost: cost,
      profit: profit,
      margin: rawMargin ?? (revenue == 0 ? 0 : profit / revenue),
    );
  }
}

/// A stock-value row from `GET /reports/stock-value`.
///
/// The endpoint may return either a single aggregate object or a per-product
/// breakdown. Each row carries the product name, the quantity on hand, and the
/// value at purchase and sale prices.
///
/// Contract (tolerant): `{ productName?, quantity, purchaseValue|costValue,
/// saleValue|retailValue }`.
class StockValueRow {
  const StockValueRow({
    required this.productName,
    required this.quantity,
    required this.purchaseValue,
    required this.saleValue,
  });

  final String productName;
  final double quantity;
  final double purchaseValue;
  final double saleValue;

  factory StockValueRow.fromJson(Map<String, dynamic> json) {
    return StockValueRow(
      productName:
          (json['productName'] ?? json['name'] ?? '—').toString(),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      purchaseValue:
          (json['purchaseValue'] as num?)?.toDouble() ??
          (json['costValue'] as num?)?.toDouble() ??
          0,
      saleValue:
          (json['saleValue'] as num?)?.toDouble() ??
          (json['retailValue'] as num?)?.toDouble() ??
          0,
    );
  }
}

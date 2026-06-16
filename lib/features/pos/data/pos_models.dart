/// POS / Касса models (Module 5) — plain Dart with hand-written
/// `fromJson`/`toJson` (no codegen). Field names match the API contract
/// EXACTLY (camelCase). See TZ §3.2 and the Module-5 contract.
library;

/// Lifecycle status of a cash shift.
///
/// Wire values (contract): `"Open" | "Closed"`.
enum ShiftStatus {
  open('Open'),
  closed('Closed');

  const ShiftStatus(this.wire);

  /// The exact camelCase token used on the wire.
  final String wire;

  /// Parses a wire token, defaulting to [ShiftStatus.open] for unknowns.
  static ShiftStatus fromWire(String? value) {
    for (final status in ShiftStatus.values) {
      if (status.wire == value) return status;
    }
    return ShiftStatus.open;
  }

  bool get isOpen => this == ShiftStatus.open;
  bool get isClosed => this == ShiftStatus.closed;
}

/// Tender method for a [Payment].
///
/// Wire values (contract): `"Cash" | "Card" | "Credit"`.
enum PaymentMethod {
  cash('Cash'),
  card('Card'),
  credit('Credit');

  const PaymentMethod(this.wire);

  /// The exact camelCase token used on the wire.
  final String wire;

  /// Parses a wire token, defaulting to [PaymentMethod.cash] for unknowns.
  static PaymentMethod fromWire(String? value) {
    for (final method in PaymentMethod.values) {
      if (method.wire == value) return method;
    }
    return PaymentMethod.cash;
  }
}

/// A cash shift (смена).
///
/// Contract: `{ id, branchId, userId, openedAt: iso-datetime,
/// closedAt: iso-datetime|null, openingCash, closingCash|null, totalSales,
/// status }`.
class CashShift {
  const CashShift({
    required this.id,
    required this.branchId,
    required this.userId,
    required this.openedAt,
    this.closedAt,
    required this.openingCash,
    this.closingCash,
    required this.totalSales,
    required this.status,
  });

  final String id;
  final String branchId;
  final String userId;
  final DateTime openedAt;
  final DateTime? closedAt;
  final double openingCash;
  final double? closingCash;
  final double totalSales;
  final ShiftStatus status;

  factory CashShift.fromJson(Map<String, dynamic> json) {
    final closedRaw = json['closedAt'] as String?;
    return CashShift(
      id: json['id'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      openedAt:
          DateTime.tryParse(json['openedAt'] as String? ?? '') ??
          DateTime.now(),
      closedAt:
          (closedRaw == null || closedRaw.isEmpty)
              ? null
              : DateTime.tryParse(closedRaw),
      openingCash: (json['openingCash'] as num?)?.toDouble() ?? 0,
      closingCash: (json['closingCash'] as num?)?.toDouble(),
      totalSales: (json['totalSales'] as num?)?.toDouble() ?? 0,
      status: ShiftStatus.fromWire(json['status'] as String?),
    );
  }
}

/// A single tender on a sale.
///
/// Contract: `{ method, amount }`.
class Payment {
  const Payment({required this.method, required this.amount});

  final PaymentMethod method;
  final double amount;

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      method: PaymentMethod.fromWire(json['method'] as String?),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Payload accepted by `POST /sales`.
  Map<String, dynamic> toJson() => {
    'method': method.wire,
    'amount': amount,
  };
}

/// One line of a sale, as returned by the server.
///
/// The server applies FEFO and may split one requested product across several
/// [SaleLine]s (one per consumed batch), so each line carries its own
/// `batchId`/`seriesNumber` and the snapshot `unitPrice`.
///
/// Contract: `{ id, productId, productName?, batchId, seriesNumber?, quantity,
/// unitPrice, lineDiscount, lineTotal }`.
class SaleLine {
  const SaleLine({
    required this.id,
    required this.productId,
    this.productName,
    required this.batchId,
    this.seriesNumber,
    required this.quantity,
    required this.unitPrice,
    required this.lineDiscount,
    required this.lineTotal,
  });

  final String id;
  final String productId;
  final String? productName;
  final String batchId;
  final String? seriesNumber;
  final double quantity;
  final double unitPrice;
  final double lineDiscount;
  final double lineTotal;

  factory SaleLine.fromJson(Map<String, dynamic> json) {
    return SaleLine(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String?,
      batchId: json['batchId'] as String? ?? '',
      seriesNumber: json['seriesNumber'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      lineDiscount: (json['lineDiscount'] as num?)?.toDouble() ?? 0,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// A completed sale (header + server-allocated lines + payments).
///
/// Contract: `{ id, number, branchId, shiftId, userId, createdAt,
/// lines: [SaleLine], payments: [Payment], subtotal, discount, total }`.
/// In list responses `lines`/`payments` may be empty (headers only).
class Sale {
  const Sale({
    required this.id,
    required this.number,
    required this.branchId,
    required this.shiftId,
    required this.userId,
    required this.createdAt,
    this.lines = const [],
    this.payments = const [],
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  final String id;
  final String number;
  final String branchId;
  final String shiftId;
  final String userId;
  final DateTime createdAt;
  final List<SaleLine> lines;
  final List<Payment> payments;
  final double subtotal;
  final double discount;
  final double total;

  /// Total tendered across all payments (client-side helper).
  double get paid => payments.fold<double>(0, (sum, p) => sum + p.amount);

  /// Cash change due when tendered exceeds the total (never negative).
  double get changeDue =>
      (paid - total).clamp(0, double.infinity).toDouble();

  factory Sale.fromJson(Map<String, dynamic> json) {
    final rawLines = (json['lines'] as List<dynamic>?) ?? const [];
    final rawPayments = (json['payments'] as List<dynamic>?) ?? const [];
    return Sale(
      id: json['id'] as String? ?? '',
      number: json['number'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      shiftId: json['shiftId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      lines: rawLines
          .map((e) => SaleLine.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      payments: rawPayments
          .map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Z-report figures returned by `GET /reports/z-report/{shiftId}`.
///
/// Contract: `{ shiftId, branchId, openedAt, closedAt, openingCash,
/// closingCash, salesCount, totalSales, totalReturns, netTotal,
/// byMethod: { Cash, Card, Credit }, expectedCash }`.
class ZReport {
  const ZReport({
    required this.shiftId,
    required this.branchId,
    required this.openedAt,
    this.closedAt,
    required this.openingCash,
    this.closingCash,
    required this.salesCount,
    required this.totalSales,
    required this.totalReturns,
    required this.netTotal,
    required this.byMethod,
    required this.expectedCash,
  });

  final String shiftId;
  final String branchId;
  final DateTime openedAt;
  final DateTime? closedAt;
  final double openingCash;
  final double? closingCash;
  final int salesCount;
  final double totalSales;
  final double totalReturns;
  final double netTotal;

  /// Totals tendered per [PaymentMethod].
  final Map<PaymentMethod, double> byMethod;
  final double expectedCash;

  /// Convenience accessor for one method's tendered total (0 when absent).
  double amountFor(PaymentMethod method) => byMethod[method] ?? 0;

  factory ZReport.fromJson(Map<String, dynamic> json) {
    final rawByMethod =
        (json['byMethod'] as Map<String, dynamic>?) ?? const {};
    final byMethod = <PaymentMethod, double>{};
    for (final method in PaymentMethod.values) {
      final value = rawByMethod[method.wire];
      byMethod[method] = (value as num?)?.toDouble() ?? 0;
    }
    final closedRaw = json['closedAt'] as String?;
    return ZReport(
      shiftId: json['shiftId'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      openedAt:
          DateTime.tryParse(json['openedAt'] as String? ?? '') ??
          DateTime.now(),
      closedAt:
          (closedRaw == null || closedRaw.isEmpty)
              ? null
              : DateTime.tryParse(closedRaw),
      openingCash: (json['openingCash'] as num?)?.toDouble() ?? 0,
      closingCash: (json['closingCash'] as num?)?.toDouble(),
      salesCount: (json['salesCount'] as num?)?.toInt() ?? 0,
      totalSales: (json['totalSales'] as num?)?.toDouble() ?? 0,
      totalReturns: (json['totalReturns'] as num?)?.toDouble() ?? 0,
      netTotal: (json['netTotal'] as num?)?.toDouble() ?? 0,
      byMethod: byMethod,
      expectedCash: (json['expectedCash'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// A client-side cart line built before checkout. The cart sends only
/// `productId` + `quantity` (+ optional `lineDiscount`) to `POST /sales`; the
/// server runs FEFO and returns the authoritative [SaleLine]s (which may split
/// one product across several batches). [unitPrice] here is only an indicative
/// price (e.g. the product's last sale price) shown to the cashier — the server
/// snapshots the real per-batch price at sale time.
class CartItem {
  const CartItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.lineDiscount = 0,
  });

  final String productId;
  final String name;
  final double quantity;

  /// Indicative unit price for the on-screen running total only.
  final double unitPrice;
  final double lineDiscount;

  /// Indicative line total (`quantity * unitPrice - lineDiscount`, never
  /// negative). The server is the source of truth for the booked amount.
  double get lineTotal =>
      (quantity * unitPrice - lineDiscount).clamp(0, double.infinity).toDouble();

  CartItem copyWith({
    String? productId,
    String? name,
    double? quantity,
    double? unitPrice,
    double? lineDiscount,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      lineDiscount: lineDiscount ?? this.lineDiscount,
    );
  }

  /// Line payload for `POST /sales` body (`{ productId, quantity,
  /// lineDiscount? }`). `lineDiscount` is omitted when zero.
  Map<String, dynamic> toRequestJson() => {
    'productId': productId,
    'quantity': quantity,
    if (lineDiscount > 0) 'lineDiscount': lineDiscount,
  };
}

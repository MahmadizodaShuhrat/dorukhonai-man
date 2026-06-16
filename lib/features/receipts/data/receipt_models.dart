/// Receipt (Приход) models — plain Dart with hand-written `fromJson`/`toJson`
/// (no codegen). Field names match the API contract EXACTLY (camelCase).
library;

/// Lifecycle status of a receipt document.
///
/// Wire values (contract): `"Draft" | "Posted" | "Cancelled"`.
enum ReceiptStatus {
  draft('Draft'),
  posted('Posted'),
  cancelled('Cancelled');

  const ReceiptStatus(this.wire);

  /// The exact camelCase token used on the wire.
  final String wire;

  /// Parses a wire token, defaulting to [ReceiptStatus.draft] for unknowns.
  static ReceiptStatus fromWire(String? value) {
    for (final status in ReceiptStatus.values) {
      if (status.wire == value) return status;
    }
    return ReceiptStatus.draft;
  }

  bool get isDraft => this == ReceiptStatus.draft;
  bool get isPosted => this == ReceiptStatus.posted;
  bool get isCancelled => this == ReceiptStatus.cancelled;
}

/// A single line of a receipt.
///
/// Contract: `{ id: guid|null, productId, productName?, quantity,
/// seriesNumber, expiryDate: iso-date, purchasePrice, salePrice }`.
class ReceiptLine {
  const ReceiptLine({
    this.id,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.seriesNumber,
    required this.expiryDate,
    required this.purchasePrice,
    required this.salePrice,
  });

  final String? id;
  final String productId;
  final String? productName;
  final double quantity;
  final String seriesNumber;
  final DateTime expiryDate;
  final double purchasePrice;
  final double salePrice;

  /// Line subtotal at purchase price (`quantity * purchasePrice`).
  double get lineTotal => quantity * purchasePrice;

  factory ReceiptLine.fromJson(Map<String, dynamic> json) {
    return ReceiptLine(
      id: json['id'] as String?,
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      seriesNumber: json['seriesNumber'] as String? ?? '',
      expiryDate:
          DateTime.tryParse(json['expiryDate'] as String? ?? '') ??
          DateTime.now(),
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble() ?? 0,
      salePrice: (json['salePrice'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Full line JSON (used when reading). For the create/update payload the
  /// repository strips `id`/`productName` — see [toCreateJson].
  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'productName': productName,
    'quantity': quantity,
    'seriesNumber': seriesNumber,
    'expiryDate': _dateOnly(expiryDate),
    'purchasePrice': purchasePrice,
    'salePrice': salePrice,
  };

  /// Line payload accepted by `POST`/`PUT /receipts` (no `id`/`productName`).
  Map<String, dynamic> toCreateJson() => {
    'productId': productId,
    'quantity': quantity,
    'seriesNumber': seriesNumber,
    'expiryDate': _dateOnly(expiryDate),
    'purchasePrice': purchasePrice,
    'salePrice': salePrice,
  };

  ReceiptLine copyWith({
    String? Function()? id,
    String? productId,
    String? Function()? productName,
    double? quantity,
    String? seriesNumber,
    DateTime? expiryDate,
    double? purchasePrice,
    double? salePrice,
  }) {
    return ReceiptLine(
      id: id != null ? id() : this.id,
      productId: productId ?? this.productId,
      productName: productName != null ? productName() : this.productName,
      quantity: quantity ?? this.quantity,
      seriesNumber: seriesNumber ?? this.seriesNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
    );
  }
}

/// A receipt document (header + lines).
///
/// Contract: `{ id, number, supplierId, branchId, date: iso-datetime,
/// status, lines: [ReceiptLine], total }`. In list responses `lines` may be
/// empty (headers only).
class Receipt {
  const Receipt({
    required this.id,
    required this.number,
    required this.supplierId,
    required this.branchId,
    required this.date,
    required this.status,
    this.lines = const [],
    required this.total,
  });

  final String id;
  final String number;
  final String supplierId;
  final String branchId;
  final DateTime date;
  final ReceiptStatus status;
  final List<ReceiptLine> lines;
  final double total;

  /// Sum of line subtotals (client-side; the server is the source of truth).
  double get computedTotal =>
      lines.fold<double>(0, (sum, line) => sum + line.lineTotal);

  factory Receipt.fromJson(Map<String, dynamic> json) {
    final rawLines = (json['lines'] as List<dynamic>?) ?? const [];
    return Receipt(
      id: json['id'] as String? ?? '',
      number: json['number'] as String? ?? '',
      supplierId: json['supplierId'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      status: ReceiptStatus.fromWire(json['status'] as String?),
      lines: rawLines
          .map((e) => ReceiptLine.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Create/update payload accepted by `POST`/`PUT /receipts`:
  /// `{ supplierId, branchId, date, lines: [...] }`.
  Map<String, dynamic> toCreateJson() => {
    'supplierId': supplierId,
    'branchId': branchId,
    'date': date.toUtc().toIso8601String(),
    'lines': lines.map((l) => l.toCreateJson()).toList(growable: false),
  };
}

/// Renders a [DateTime] as a date-only ISO string (`yyyy-MM-dd`) for
/// `expiryDate`, which the contract types as `iso-date`.
String _dateOnly(DateTime value) {
  final y = value.year.toString().padLeft(4, '0');
  final m = value.month.toString().padLeft(2, '0');
  final d = value.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

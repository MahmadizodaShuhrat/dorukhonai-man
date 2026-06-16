/// Stock (Анбор) models — plain Dart with hand-written `fromJson` (no codegen).
/// Field names match the API contract EXACTLY (camelCase). These are read-only
/// projections, so there is no `toJson`.
library;

/// A batch of a product on hand at a branch.
///
/// Contract: `{ productId, productName, barcode?, batchId, seriesNumber,
/// expiryDate: iso-date, quantity, salePrice, branchId }`. Listed only while
/// `quantity > 0`.
class StockItem {
  const StockItem({
    required this.productId,
    required this.productName,
    this.barcode,
    required this.batchId,
    required this.seriesNumber,
    required this.expiryDate,
    required this.quantity,
    required this.salePrice,
    required this.branchId,
  });

  final String productId;
  final String productName;
  final String? barcode;
  final String batchId;
  final String seriesNumber;
  final DateTime expiryDate;
  final double quantity;
  final double salePrice;
  final String branchId;

  /// Whole days until expiry from [now] (negative once expired).
  int daysUntilExpiry([DateTime? now]) {
    final today = _dateOnly(now ?? DateTime.now());
    final exp = _dateOnly(expiryDate);
    return exp.difference(today).inDays;
  }

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      barcode: json['barcode'] as String?,
      batchId: json['batchId'] as String? ?? '',
      seriesNumber: json['seriesNumber'] as String? ?? '',
      expiryDate:
          DateTime.tryParse(json['expiryDate'] as String? ?? '') ??
          DateTime.now(),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      salePrice: (json['salePrice'] as num?)?.toDouble() ?? 0,
      branchId: json['branchId'] as String? ?? '',
    );
  }
}

/// A low-stock alert row.
///
/// Contract: `{ productId, productName, totalQuantity, minStockLevel }` where
/// `totalQuantity < minStockLevel`.
class LowStockItem {
  const LowStockItem({
    required this.productId,
    required this.productName,
    required this.totalQuantity,
    required this.minStockLevel,
  });

  final String productId;
  final String productName;
  final double totalQuantity;
  final double minStockLevel;

  /// How far below the threshold the product is (always >= 0 for alert rows).
  double get shortfall =>
      (minStockLevel - totalQuantity).clamp(0, double.infinity).toDouble();

  factory LowStockItem.fromJson(Map<String, dynamic> json) {
    return LowStockItem(
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      totalQuantity: (json['totalQuantity'] as num?)?.toDouble() ?? 0,
      minStockLevel: (json['minStockLevel'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// A single stock-movement ledger entry.
///
/// Contract: `{ id, productId, batchId, type, quantity, createdAt,
/// documentType }`, ordered `createdAt` desc.
class StockMovement {
  const StockMovement({
    required this.id,
    required this.productId,
    required this.batchId,
    required this.type,
    required this.quantity,
    required this.createdAt,
    this.documentType,
  });

  final String id;
  final String productId;
  final String batchId;
  final String type;
  final double quantity;
  final DateTime createdAt;
  final String? documentType;

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      batchId: json['batchId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      documentType: json['documentType'] as String?,
    );
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

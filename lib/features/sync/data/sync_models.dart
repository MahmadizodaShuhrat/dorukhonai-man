/// Sync DTOs (offline) — plain Dart with hand-written `fromJson`/`toJson`.
/// Field names match the SHARED SYNC CONTRACT EXACTLY (camelCase). Base
/// `/api/v1`, JWT Bearer. See TZ_04 §4.
library;

/// One stock row in the catalog snapshot.
/// Contract: `{ branchId, batchId, productId, quantity }`.
class SyncStockRow {
  const SyncStockRow({
    required this.branchId,
    required this.batchId,
    required this.productId,
    required this.quantity,
  });

  final String branchId;
  final String batchId;
  final String productId;
  final double quantity;

  factory SyncStockRow.fromJson(Map<String, dynamic> json) {
    return SyncStockRow(
      branchId: json['branchId'] as String? ?? '',
      batchId: json['batchId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// One batch row in the catalog snapshot.
/// Contract: `{ id, productId, seriesNumber, expiryDate, salePrice,
/// purchasePrice }`.
class SyncBatchRow {
  const SyncBatchRow({
    required this.id,
    required this.productId,
    required this.seriesNumber,
    required this.expiryDate,
    required this.salePrice,
    required this.purchasePrice,
  });

  final String id;
  final String productId;
  final String seriesNumber;
  final DateTime expiryDate;
  final double salePrice;
  final double purchasePrice;

  factory SyncBatchRow.fromJson(Map<String, dynamic> json) {
    return SyncBatchRow(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      seriesNumber: json['seriesNumber'] as String? ?? '',
      expiryDate:
          DateTime.tryParse(json['expiryDate'] as String? ?? '') ??
          DateTime.now(),
      salePrice: (json['salePrice'] as num?)?.toDouble() ?? 0,
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Result of pushing one queued sale.
/// Contract: `{ clientId, status: "ok"|"duplicate"|"conflict", saleId?,
/// message? }`.
class SalePushResult {
  const SalePushResult({
    required this.clientId,
    required this.status,
    this.saleId,
    this.message,
  });

  final String clientId;

  /// `ok` | `duplicate` | `conflict`.
  final String status;
  final String? saleId;
  final String? message;

  bool get isAccepted => status == 'ok' || status == 'duplicate';
  bool get isConflict => status == 'conflict';

  factory SalePushResult.fromJson(Map<String, dynamic> json) {
    return SalePushResult(
      clientId: json['clientId'] as String? ?? '',
      status: json['status'] as String? ?? 'conflict',
      saleId: json['saleId'] as String?,
      message: json['message'] as String?,
    );
  }
}

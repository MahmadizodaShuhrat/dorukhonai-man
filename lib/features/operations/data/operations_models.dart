/// MODUL 6 (Амалиёти анбор) models — plain Dart with hand-written
/// `fromJson`/`toJson` (no codegen). Field names match the NEW-ENDPOINT
/// CONTRACT (camelCase) EXACTLY.
library;

/// Reason for a write-off (`POST /write-offs` → `reason`). Wire values are the
/// exact contract strings.
enum WriteOffReason {
  expired('Expired', 'Мӯҳлат гузашта'),
  damaged('Damaged', 'Вайроншуда'),
  lost('Lost', 'Гумшуда'),
  other('Other', 'Дигар');

  const WriteOffReason(this.wire, this.label);

  /// Exact contract string sent to the API.
  final String wire;

  /// Tajik label for the UI.
  final String label;

  static WriteOffReason fromWire(String? value) {
    for (final r in WriteOffReason.values) {
      if (r.wire == value) return r;
    }
    return WriteOffReason.other;
  }
}

/// A write-off line in a request: `{ batchId, quantity }`.
class WriteOffLineRequest {
  const WriteOffLineRequest({required this.batchId, required this.quantity});

  final String batchId;
  final double quantity;

  Map<String, dynamic> toJson() => {'batchId': batchId, 'quantity': quantity};
}

/// A persisted write-off document header (`GET /write-offs`).
/// Contract (tolerant): `{ id, number?, branchId, reason, note?, createdAt,
/// total? | lineCount? }`.
class WriteOff {
  const WriteOff({
    required this.id,
    this.number,
    required this.reason,
    this.note,
    required this.createdAt,
    this.lineCount = 0,
  });

  final String id;
  final String? number;
  final WriteOffReason reason;
  final String? note;
  final DateTime createdAt;
  final int lineCount;

  factory WriteOff.fromJson(Map<String, dynamic> json) {
    return WriteOff(
      id: json['id'] as String? ?? '',
      number: json['number'] as String?,
      reason: WriteOffReason.fromWire(json['reason'] as String?),
      note: json['note'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      lineCount:
          (json['lineCount'] as num?)?.toInt() ??
          (json['lines'] is List ? (json['lines'] as List).length : 0),
    );
  }
}

/// An inventory line in a request: `{ batchId, countedQuantity }`.
class InventoryLineRequest {
  const InventoryLineRequest({
    required this.batchId,
    required this.countedQuantity,
  });

  final String batchId;
  final double countedQuantity;

  Map<String, dynamic> toJson() => {
    'batchId': batchId,
    'countedQuantity': countedQuantity,
  };
}

/// A single discrepancy returned by `POST /inventory`.
/// Contract (tolerant): `{ batchId, productName?, expected, counted, difference }`.
class InventoryDiscrepancy {
  const InventoryDiscrepancy({
    required this.batchId,
    this.productName,
    required this.expected,
    required this.counted,
    required this.difference,
  });

  final String batchId;
  final String? productName;
  final double expected;
  final double counted;
  final double difference;

  factory InventoryDiscrepancy.fromJson(Map<String, dynamic> json) {
    final expected = (json['expected'] as num?)?.toDouble() ?? 0;
    final counted =
        (json['counted'] as num?)?.toDouble() ??
        (json['countedQuantity'] as num?)?.toDouble() ??
        0;
    return InventoryDiscrepancy(
      batchId: json['batchId'] as String? ?? '',
      productName: json['productName'] as String?,
      expected: expected,
      counted: counted,
      difference: (json['difference'] as num?)?.toDouble() ?? counted - expected,
    );
  }
}

/// Result of posting an inventory count (`POST /inventory`): the document id plus
/// the discrepancy list the server computed.
class InventoryResult {
  const InventoryResult({required this.id, this.discrepancies = const []});

  final String id;
  final List<InventoryDiscrepancy> discrepancies;

  factory InventoryResult.fromJson(Map<String, dynamic> json) {
    final raw = (json['discrepancies'] as List<dynamic>?) ?? const [];
    return InventoryResult(
      id: json['id'] as String? ?? '',
      discrepancies: raw
          .map((e) => InventoryDiscrepancy.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

/// A persisted inventory document header (`GET /inventory`).
class InventoryDoc {
  const InventoryDoc({
    required this.id,
    this.number,
    this.note,
    required this.createdAt,
    this.lineCount = 0,
  });

  final String id;
  final String? number;
  final String? note;
  final DateTime createdAt;
  final int lineCount;

  factory InventoryDoc.fromJson(Map<String, dynamic> json) {
    return InventoryDoc(
      id: json['id'] as String? ?? '',
      number: json['number'] as String?,
      note: json['note'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      lineCount:
          (json['lineCount'] as num?)?.toInt() ??
          (json['lines'] is List ? (json['lines'] as List).length : 0),
    );
  }
}

/// A supplier-return line in a request: `{ batchId, quantity }`.
class SupplierReturnLineRequest {
  const SupplierReturnLineRequest({
    required this.batchId,
    required this.quantity,
  });

  final String batchId;
  final double quantity;

  Map<String, dynamic> toJson() => {'batchId': batchId, 'quantity': quantity};
}

/// A persisted supplier-return document header (`GET /supplier-returns`).
class SupplierReturn {
  const SupplierReturn({
    required this.id,
    this.number,
    required this.supplierId,
    this.supplierName,
    this.note,
    required this.createdAt,
    this.lineCount = 0,
  });

  final String id;
  final String? number;
  final String supplierId;
  final String? supplierName;
  final String? note;
  final DateTime createdAt;
  final int lineCount;

  factory SupplierReturn.fromJson(Map<String, dynamic> json) {
    return SupplierReturn(
      id: json['id'] as String? ?? '',
      number: json['number'] as String?,
      supplierId: json['supplierId'] as String? ?? '',
      supplierName: json['supplierName'] as String?,
      note: json['note'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      lineCount:
          (json['lineCount'] as num?)?.toInt() ??
          (json['lines'] is List ? (json['lines'] as List).length : 0),
    );
  }
}

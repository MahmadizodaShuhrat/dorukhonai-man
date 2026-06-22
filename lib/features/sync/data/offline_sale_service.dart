import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/cache_dao.dart';
import '../../pos/data/pos_models.dart';
import 'offline_fefo.dart';

/// Outcome of recording an offline sale.
sealed class OfflineSaleResult {
  const OfflineSaleResult();
}

/// Sale queued successfully: receipt lines (local FEFO allocation) + the
/// `clientId` it was enqueued under.
class OfflineSaleQueued extends OfflineSaleResult {
  const OfflineSaleQueued({
    required this.clientId,
    required this.lines,
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  final String clientId;
  final List<FefoAllocation> lines;
  final double subtotal;
  final double discount;
  final double total;
}

/// Cached stock cannot fill the cart (per-product shortfall).
class OfflineSaleShortfall extends OfflineSaleResult {
  const OfflineSaleShortfall({required this.productName, required this.fefo});
  final String productName;
  final FefoShortfall fefo;
}

/// Records sales while offline (TZ_04 §3): runs local FEFO from cached batches,
/// decrements cached stock optimistically, and enqueues the sale in the outbox
/// with a client-generated `clientId`. The server re-runs FEFO authoritatively
/// on PUSH, so the local allocation is provisional (used for the printed
/// receipt + on-hand math only).
class OfflineSaleService {
  OfflineSaleService(this._dao, {this._fefo = const OfflineFefo()});

  final CacheDao _dao;
  final OfflineFefo _fefo;

  /// Allocates [items] via local FEFO and, if every line fills, enqueues the
  /// sale. [clientId] must be a freshly generated Guid (caller-provided so it
  /// can be echoed on the receipt). [createdAt] is the wall-clock sale time.
  Future<OfflineSaleResult> recordSale({
    required String clientId,
    required String branchId,
    required List<CartItem> items,
    required List<Payment> payments,
    required double discount,
    required DateTime createdAt,
  }) async {
    final today = DateTime.now();
    // Reservations accumulate across lines so two cart lines of the same
    // product don't both claim the same batch quantity.
    final reserved = <String, double>{};
    final allocations = <FefoAllocation>[];

    for (final item in items) {
      final candidates = await _dao.fefoCandidates(
        productId: item.productId,
        branchId: branchId,
        today: today,
      );
      final result = _fefo.allocate(
        candidates: candidates,
        requested: item.quantity,
        reserved: reserved,
      );
      switch (result) {
        case FefoShortfall():
          return OfflineSaleShortfall(productName: item.name, fefo: result);
        case FefoFilled(allocations: final lineAllocations):
          for (final a in lineAllocations) {
            reserved[a.batchId] = (reserved[a.batchId] ?? 0) + a.quantity;
            allocations.add(a);
          }
      }
    }

    // Optimistically decrement cached stock so chained offline sales are exact.
    for (final entry in reserved.entries) {
      await _dao.decrementStock(
        branchId: branchId,
        batchId: entry.key,
        delta: entry.value,
      );
    }

    final subtotal = allocations.fold<double>(0, (s, a) => s + a.lineTotal);
    final total = (subtotal - discount).clamp(0, double.infinity).toDouble();

    // Build the exact `POST /sync/sales` per-sale payload (product+quantity,
    // NOT the batch split — the server re-runs FEFO).
    final payload = <String, dynamic>{
      'clientId': clientId,
      'branchId': branchId,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'lines': [
        for (final item in items)
          {
            'productId': item.productId,
            'quantity': item.quantity,
            if (item.lineDiscount > 0) 'lineDiscount': item.lineDiscount,
          },
      ],
      'payments': payments.map((p) => p.toJson()).toList(growable: false),
      if (discount > 0) 'discount': discount,
    };

    await _dao.enqueueSale(
      OutboxSalesCompanion.insert(
        clientId: clientId,
        branchId: branchId,
        payloadJson: jsonEncode(payload),
        createdAt: createdAt,
      ),
    );

    return OfflineSaleQueued(
      clientId: clientId,
      lines: allocations,
      subtotal: subtotal,
      discount: discount,
      total: total,
    );
  }
}

/// Provider exposing the [OfflineSaleService].
final offlineSaleServiceProvider = Provider<OfflineSaleService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return OfflineSaleService(CacheDao(db));
});

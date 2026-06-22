import '../../../core/db/cache_dao.dart';

/// One FEFO allocation: a quantity drawn from a specific batch at the cached
/// per-batch sale price. Mirrors a server `SaleLine` for the printed receipt.
class FefoAllocation {
  const FefoAllocation({
    required this.batchId,
    required this.productId,
    required this.branchId,
    required this.seriesNumber,
    required this.quantity,
    required this.unitPrice,
  });

  final String batchId;
  final String productId;
  final String branchId;
  final String seriesNumber;
  final double quantity;
  final double unitPrice;

  double get lineTotal => quantity * unitPrice;
}

/// Outcome of running offline FEFO for one product.
sealed class FefoResult {
  const FefoResult();
}

/// Enough cached stock: greedy per-batch allocation in FEFO order.
class FefoFilled extends FefoResult {
  const FefoFilled(this.allocations);
  final List<FefoAllocation> allocations;
}

/// Not enough cached effective stock to fill the request.
class FefoShortfall extends FefoResult {
  const FefoShortfall({required this.requested, required this.available});
  final double requested;
  final double available;
}

/// Offline FEFO allocator. Pure function over the cached candidate batches —
/// the SAME constants as `CreateSaleCommandHandler` (TZ_04 §3): expiry filter,
/// `expiryDate ASC, batchId ASC` order, per-batch `salePrice`, shortfall block.
///
/// [candidates] must already be filtered/ordered by [CacheDao.fefoCandidates].
/// [reserved] is the already-queued (not-yet-pushed) quantity per batchId, so
/// the effective on-hand is `candidate.quantity - reserved[batchId]`. This makes
/// chained offline sales decrement correctly.
class OfflineFefo {
  const OfflineFefo();

  FefoResult allocate({
    required List<FefoCandidate> candidates,
    required double requested,
    Map<String, double> reserved = const {},
  }) {
    if (requested <= 0) return const FefoFilled([]);

    var remaining = requested;
    var totalAvailable = 0.0;
    final allocations = <FefoAllocation>[];

    for (final c in candidates) {
      final effective =
          (c.quantity - (reserved[c.batchId] ?? 0)).clamp(0, double.infinity);
      if (effective <= 0) continue;
      totalAvailable += effective;
      if (remaining <= 0) continue;

      final take = remaining < effective ? remaining : effective;
      allocations.add(
        FefoAllocation(
          batchId: c.batchId,
          productId: c.productId,
          branchId: c.branchId,
          seriesNumber: c.seriesNumber,
          quantity: take.toDouble(),
          unitPrice: c.salePrice,
        ),
      );
      remaining -= take;
    }

    if (remaining > 1e-9) {
      return FefoShortfall(requested: requested, available: totalAvailable);
    }
    return FefoFilled(allocations);
  }
}

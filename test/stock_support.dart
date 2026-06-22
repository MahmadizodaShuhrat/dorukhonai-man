/// Stock-feature-scoped test helpers (kept OUT of the shared `support/fakes.dart`
/// so parallel screen tracks do not collide). Re-exports the shared stock fakes
/// for convenience and adds a couple of stock-only builders.
library;

import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/features/stock/data/stock_models.dart';

import 'support/fakes.dart';

export 'support/fakes.dart'
    show
        FakeStockRepository,
        paged,
        sampleStockItem,
        sampleLowItem,
        sampleMovement;

/// A canned [Failure] used to drive the error-state tests.
const Failure kTestFailure = ServerFailure('Хатои сервер (500).', statusCode: 500);

/// An on-hand stock item that expires roughly [daysFromNow] days from now,
/// so expiry-tint thresholds (30 / 90 days) can be asserted deterministically.
StockItem expiringStockItem({
  String productName = 'Дору',
  String productId = 'p1',
  required int daysFromNow,
  double quantity = 5,
}) => sampleStockItem(
  productId: productId,
  productName: productName,
  expiry: DateTime.now().add(Duration(days: daysFromNow)),
  quantity: quantity,
);

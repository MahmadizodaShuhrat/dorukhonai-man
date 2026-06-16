import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/features/stock/data/stock_models.dart';
import 'package:dorukhonai_man/features/stock/data/stock_repository.dart';
import 'package:dorukhonai_man/features/stock/presentation/stock_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  ProviderContainer makeContainer(FakeStockRepository repo) {
    final container = ProviderContainer(
      overrides: [stockRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('StockListController (Бақия)', () {
    test('initial refresh loads stock items', () async {
      final repo = FakeStockRepository(
        listResult: Success(paged([sampleStockItem()], total: 1)),
      );
      final container = makeContainer(repo);
      container.read(stockListControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(stockListControllerProvider);
      expect(state.items, hasLength(1));
      expect(state.total, 1);
      expect(state.failure, isNull);
    });

    test('search trims, resets to page 1, and queries the repo', () async {
      final repo = FakeStockRepository(
        listResult: Success(paged(<StockItem>[], total: 0)),
      );
      final container = makeContainer(repo);
      final controller = container.read(stockListControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      await controller.search('  аспирин  ');

      expect(repo.lastSearch, 'аспирин');
      expect(container.read(stockListControllerProvider).page, 1);
    });

    test('failure surfaces a Failure and empty items', () async {
      final repo = FakeStockRepository(
        listResult: const Error(ServerFailure('boom', statusCode: 500)),
      );
      final container = makeContainer(repo);
      container.read(stockListControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(stockListControllerProvider);
      expect(state.items, isEmpty);
      expect(state.failure, isA<ServerFailure>());
    });
  });

  group('ExpiringStockController (Мӯҳлати наздик)', () {
    test('defaults to a 90-day window', () async {
      final repo = FakeStockRepository(
        expiringResult: Success(paged([sampleStockItem()], total: 1)),
      );
      final container = makeContainer(repo);
      container.read(expiringStockControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      expect(repo.lastExpiringDays, 90);
    });

    test('setDays switches the window and re-fetches', () async {
      final repo = FakeStockRepository(
        expiringResult: Success(paged(<StockItem>[], total: 0)),
      );
      final container = makeContainer(repo);
      final controller =
          container.read(expiringStockControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      await controller.setDays(30);

      expect(controller.days, 30);
      expect(repo.lastExpiringDays, 30);
    });
  });

  group('LowStockController (Камшуда)', () {
    test('initial refresh loads low-stock items', () async {
      final repo = FakeStockRepository(
        lowResult: Success(paged([sampleLowItem()], total: 1)),
      );
      final container = makeContainer(repo);
      container.read(lowStockControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(lowStockControllerProvider);
      expect(state.items, hasLength(1));
      expect(state.items.first.shortfall, 7); // 10 - 3
    });
  });

  group('stockMovementsProvider', () {
    test('returns the movement list for a product', () async {
      final repo = FakeStockRepository(
        movementsResult: Success(paged([sampleMovement()], total: 1)),
      );
      final container = makeContainer(repo);

      final movements =
          await container.read(stockMovementsProvider('p1').future);

      expect(movements, hasLength(1));
      expect(repo.lastMovementsProductId, 'p1');
    });
  });

  group('StockItem.daysUntilExpiry', () {
    test('computes whole days from a reference date', () {
      final item = sampleStockItem(expiry: DateTime(2026, 6, 30));
      expect(item.daysUntilExpiry(DateTime(2026, 6, 16)), 14);
    });

    test('is negative once expired', () {
      final item = sampleStockItem(expiry: DateTime(2026, 6, 10));
      expect(item.daysUntilExpiry(DateTime(2026, 6, 16)), -6);
    });
  });
}

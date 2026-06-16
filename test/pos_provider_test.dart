import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/features/pos/data/pos_models.dart';
import 'package:dorukhonai_man/features/pos/data/pos_repository.dart';
import 'package:dorukhonai_man/features/pos/presentation/pos_providers.dart';
import 'package:dorukhonai_man/features/products/data/product_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  ProviderContainer makeContainer(FakePosRepository repo) {
    final container = ProviderContainer(
      overrides: [posRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('CashShiftController', () {
    test('loadCurrent with a 404 clears the shift without an error', () async {
      final repo = FakePosRepository(
        currentShiftResult:
            const Error(ServerFailure('Смена ёфт нашуд.', statusCode: 404)),
      );
      final container = makeContainer(repo);
      final controller = container.read(cashShiftControllerProvider.notifier);

      await controller.loadCurrent();

      final state = container.read(cashShiftControllerProvider);
      expect(state.shift, isNull);
      expect(state.hasOpenShift, isFalse);
      expect(state.failure, isNull);
    });

    test('loadCurrent adopts the loaded shift branchId (resumed shift)',
        () async {
      // A shift opened in a previous session is resumed via currentShift; the
      // controller must adopt its branchId so POST /sales carries it.
      final repo = FakePosRepository(
        currentShiftResult: Success(sampleShift(branchId: 'br-7')),
      );
      final container = makeContainer(repo);
      final controller = container.read(cashShiftControllerProvider.notifier);

      await controller.loadCurrent();

      expect(container.read(cashShiftControllerProvider).branchId, 'br-7');
    });

    test('loadCurrent surfaces a non-404 failure', () async {
      final repo = FakePosRepository(
        currentShiftResult: const Error(NetworkFailure()),
      );
      final container = makeContainer(repo);
      await container.read(cashShiftControllerProvider.notifier).loadCurrent();

      final state = container.read(cashShiftControllerProvider);
      expect(state.failure, isA<NetworkFailure>());
    });

    test('openShift stores the opened shift and forwards branch/cash',
        () async {
      final repo = FakePosRepository(
        openShiftResult: Success(sampleShift(openingCash: 250)),
      );
      final container = makeContainer(repo);
      final controller = container.read(cashShiftControllerProvider.notifier);
      controller.setBranchId('br-9');

      final failure = await controller.openShift(250);

      expect(failure, isNull);
      expect(repo.openShiftCalls, 1);
      expect(repo.lastBranchId, 'br-9');
      expect(repo.lastOpeningCash, 250);
      expect(container.read(cashShiftControllerProvider).hasOpenShift, isTrue);
    });

    test('openShift conflict (409) surfaces the failure', () async {
      final repo = FakePosRepository(
        openShiftResult: const Error(
          ServerFailure('Смена аллакай кушода аст.', statusCode: 409),
        ),
      );
      final container = makeContainer(repo);
      final controller = container.read(cashShiftControllerProvider.notifier);

      final failure = await controller.openShift(100);

      expect(failure, isA<ServerFailure>());
      expect(container.read(cashShiftControllerProvider).hasOpenShift, isFalse);
    });

    test('closeShift clears the shift and returns the closed shift', () async {
      final repo = FakePosRepository(
        closeShiftResult: Success(
          sampleShift(status: ShiftStatus.closed, closingCash: 300),
        ),
      );
      final container = makeContainer(repo);
      final controller = container.read(cashShiftControllerProvider.notifier);

      final result = await controller.closeShift(300);

      expect(result, isA<CloseShiftSuccess>());
      expect(repo.lastClosingCash, 300);
      expect(container.read(cashShiftControllerProvider).shift, isNull);
    });
  });

  group('PosCartController', () {
    test('addProduct merges quantity for the same product', () {
      final container = makeContainer(FakePosRepository());
      final controller = container.read(posCartControllerProvider.notifier);

      controller.addProduct(const Product(id: 'p1', name: 'Аспирин'));
      controller.addProduct(const Product(id: 'p1', name: 'Аспирин'));

      final state = container.read(posCartControllerProvider);
      expect(state.items, hasLength(1));
      expect(state.items.first.quantity, 2);
    });

    test('changeQuantity below 1 removes the line', () {
      final container = makeContainer(FakePosRepository());
      final controller = container.read(posCartControllerProvider.notifier);
      controller.addProduct(const Product(id: 'p1', name: 'Аспирин'));

      controller.changeQuantity(0, -1);

      expect(container.read(posCartControllerProvider).items, isEmpty);
    });

    test('subtotal/total reflect unit price and discounts', () {
      final container = makeContainer(FakePosRepository());
      final controller = container.read(posCartControllerProvider.notifier);
      controller.addProduct(
        const Product(id: 'p1', name: 'Аспирин'),
        quantity: 3,
        unitPrice: 10,
      );
      controller.setLineDiscount(0, 5);
      controller.setDiscount(2);

      final state = container.read(posCartControllerProvider);
      expect(state.subtotal, 25); // 3*10 - 5
      expect(state.total, 23); // 25 - 2
    });

    test('clear empties the cart and discount', () {
      final container = makeContainer(FakePosRepository());
      final controller = container.read(posCartControllerProvider.notifier);
      controller.addProduct(const Product(id: 'p1', name: 'Аспирин'));
      controller.setDiscount(5);

      controller.clear();

      final state = container.read(posCartControllerProvider);
      expect(state.isEmpty, isTrue);
      expect(state.discount, 0);
    });
  });

  group('SaleSubmitController', () {
    test('submit sends cart lines + branch and returns the server sale',
        () async {
      final repo = FakePosRepository(
        currentShiftResult: Success(sampleShift()),
        createSaleResult: Success(sampleSale(number: 'S-100')),
      );
      final container = makeContainer(repo);
      final shift = container.read(cashShiftControllerProvider.notifier);
      shift.setBranchId('br-1');
      await shift.loadCurrent();
      final cart = container.read(posCartControllerProvider.notifier);
      cart.addProduct(
        const Product(id: 'p1', name: 'Аспирин'),
        quantity: 2,
        unitPrice: 15,
      );
      cart.setDiscount(3);

      final result = await container
          .read(saleSubmitControllerProvider.notifier)
          .submit(
            payments: const [Payment(method: PaymentMethod.cash, amount: 27)],
            discount: 3,
          );

      expect(result, isA<SaleSubmitSuccess>());
      expect((result as SaleSubmitSuccess).sale.number, 'S-100');
      expect(repo.createSaleCalls, 1);
      expect(repo.lastBranchId, 'br-1');
      expect(repo.lastSaleLines, hasLength(1));
      expect(repo.lastSaleLines!.first.productId, 'p1');
      expect(repo.lastSaleLines!.first.quantity, 2);
      expect(repo.lastSaleDiscount, 3);
    });

    test('submit failure surfaces the failure (e.g. not enough stock)',
        () async {
      final repo = FakePosRepository(
        createSaleResult: const Error(
          ServerFailure('Бақия нарасид.', statusCode: 409),
        ),
      );
      final container = makeContainer(repo);

      final result = await container
          .read(saleSubmitControllerProvider.notifier)
          .submit(
            payments: const [Payment(method: PaymentMethod.cash, amount: 10)],
            discount: 0,
          );

      expect(result, isA<SaleSubmitFailure>());
      expect((result as SaleSubmitFailure).failure, isA<ServerFailure>());
    });

    test('returnSale forwards sale id and return lines', () async {
      final repo = FakePosRepository(
        returnSaleResult: Success(sampleSale(number: 'S-001')),
      );
      final container = makeContainer(repo);

      final result = await container
          .read(saleSubmitControllerProvider.notifier)
          .returnSale(
            saleId: 'sale-1',
            lines: const [SaleReturnLine(saleLineId: 'sl-1', quantity: 1)],
          );

      expect(result, isA<SaleSubmitSuccess>());
      expect(repo.returnSaleCalls, 1);
      expect(repo.lastReturnSaleId, 'sale-1');
      expect(repo.lastReturnLines, hasLength(1));
      expect(repo.lastReturnLines!.first.saleLineId, 'sl-1');
    });
  });
}

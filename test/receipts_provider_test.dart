import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/core/api/paged.dart';
import 'package:dorukhonai_man/features/receipts/data/receipt_models.dart';
import 'package:dorukhonai_man/features/receipts/data/receipts_repository.dart';
import 'package:dorukhonai_man/features/receipts/presentation/receipts_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  ProviderContainer makeContainer(FakeReceiptsRepository repo) {
    final container = ProviderContainer(
      overrides: [receiptsRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('ReceiptsListController', () {
    test('initial refresh loads receipt headers from repository', () async {
      final repo = FakeReceiptsRepository(
        listResult: Success(
          paged([sampleReceipt(number: 'PR-001')], total: 1),
        ),
      );
      final container = makeContainer(repo);
      container.read(receiptsListControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(receiptsListControllerProvider);
      expect(state.receipts, hasLength(1));
      expect(state.receipts.first.number, 'PR-001');
      expect(state.total, 1);
      expect(state.isLoading, isFalse);
      expect(state.failure, isNull);
    });

    test('list failure surfaces failure and empty receipts', () async {
      final repo = FakeReceiptsRepository(
        listResult: const Error(NetworkFailure()),
      );
      final container = makeContainer(repo);
      container.read(receiptsListControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(receiptsListControllerProvider);
      expect(state.receipts, isEmpty);
      expect(state.failure, isA<NetworkFailure>());
    });

    test('filterByStatus passes status to repo and resets to page 1', () async {
      final repo = FakeReceiptsRepository(
        listResult: Success(paged(<Receipt>[], total: 0)),
      );
      final container = makeContainer(repo);
      final controller =
          container.read(receiptsListControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      await controller.filterByStatus(ReceiptStatus.posted);

      expect(repo.lastStatusFilter, ReceiptStatus.posted);
      expect(container.read(receiptsListControllerProvider).status,
          ReceiptStatus.posted);
      expect(container.read(receiptsListControllerProvider).page, 1);
    });

    test('filterByStatus is a no-op when status is unchanged', () async {
      final repo = FakeReceiptsRepository(
        listResult: Success(paged(<Receipt>[], total: 0)),
      );
      final container = makeContainer(repo);
      final controller =
          container.read(receiptsListControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);
      final callsBefore = repo.listCalls;

      // status starts null; filtering by null again should not re-fetch.
      await controller.filterByStatus(null);
      expect(repo.listCalls, callsBefore);
    });

    test('filterBySupplier trims and forwards the supplier id', () async {
      final repo = FakeReceiptsRepository(
        listResult: Success(paged(<Receipt>[], total: 0)),
      );
      final container = makeContainer(repo);
      final controller =
          container.read(receiptsListControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      await controller.filterBySupplier('  sup-9  ');

      expect(repo.lastSupplierFilter, 'sup-9');
      expect(container.read(receiptsListControllerProvider).supplierId, 'sup-9');
    });

    test('pagination bounds: pageCount/hasNext/hasPrevious', () async {
      // total 45, size 20 -> 3 pages.
      final repo = FakeReceiptsRepository(
        listResult: Success(
          Paged<Receipt>(
            items: [sampleReceipt(id: 'r1')],
            total: 45,
            page: 1,
            size: 20,
          ),
        ),
      );
      final container = makeContainer(repo);
      final controller =
          container.read(receiptsListControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      var state = container.read(receiptsListControllerProvider);
      expect(state.pageCount, 3);
      expect(state.hasPrevious, isFalse);
      expect(state.hasNext, isTrue);

      repo.listResult = Success(
        Paged<Receipt>(
          items: [sampleReceipt(id: 'r2')],
          total: 45,
          page: 2,
          size: 20,
        ),
      );
      await controller.nextPage();
      state = container.read(receiptsListControllerProvider);
      expect(state.page, 2);
      expect(state.hasPrevious, isTrue);
      expect(state.hasNext, isTrue);
    });
  });

  group('ReceiptEditController', () {
    test('create calls repo.create and refreshes the list', () async {
      final repo = FakeReceiptsRepository(
        listResult: Success(paged(<Receipt>[], total: 0)),
        createResult: Success(sampleReceipt(id: 'new-1')),
      );
      final container = makeContainer(repo);
      container.read(receiptsListControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);
      final listCallsBefore = repo.listCalls;

      final controller = container.read(receiptEditControllerProvider.notifier);
      final result = await controller.create(sampleReceipt(id: ''));
      await Future<void>.delayed(Duration.zero);

      expect(result, isA<ReceiptSaveSuccess>());
      expect(repo.createCalls, 1);
      expect(repo.listCalls, greaterThan(listCallsBefore));
    });

    test('post calls repo.post and refreshes the list', () async {
      final repo = FakeReceiptsRepository(
        listResult: Success(paged(<Receipt>[], total: 0)),
        postResult: Success(sampleReceipt(id: 'r1', status: ReceiptStatus.posted)),
      );
      final container = makeContainer(repo);
      container.read(receiptsListControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);
      final before = repo.listCalls;

      final controller = container.read(receiptEditControllerProvider.notifier);
      final result = await controller.post('r1');
      await Future<void>.delayed(Duration.zero);

      expect(result, isA<ReceiptSaveSuccess>());
      expect((result as ReceiptSaveSuccess).receipt.status,
          ReceiptStatus.posted);
      expect(repo.postCalls, 1);
      expect(repo.lastPostedId, 'r1');
      expect(repo.listCalls, greaterThan(before));
    });

    test('double-post rejection surfaces server message as a failure',
        () async {
      final repo = FakeReceiptsRepository(
        postResult: const Error(
          ServerFailure('Приход аллакай тасдиқ шудааст.', statusCode: 409),
        ),
      );
      final container = makeContainer(repo);
      final controller = container.read(receiptEditControllerProvider.notifier);

      final result = await controller.post('r1');

      expect(result, isA<ReceiptSaveFailure>());
      final failure = (result as ReceiptSaveFailure).failure;
      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'Приход аллакай тасдиқ шудааст.');
    });

    test('cancel calls repo.cancel', () async {
      final repo = FakeReceiptsRepository(
        cancelResult:
            Success(sampleReceipt(id: 'r1', status: ReceiptStatus.cancelled)),
      );
      final container = makeContainer(repo);
      final controller = container.read(receiptEditControllerProvider.notifier);

      final result = await controller.cancel('r1');

      expect(result, isA<ReceiptSaveSuccess>());
      expect(repo.cancelCalls, 1);
      expect(repo.lastCancelledId, 'r1');
    });
  });
}

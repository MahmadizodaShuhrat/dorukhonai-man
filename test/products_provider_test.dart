import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/core/api/paged.dart';
import 'package:dorukhonai_man/features/products/data/product_models.dart';
import 'package:dorukhonai_man/features/products/data/products_repository.dart';
import 'package:dorukhonai_man/features/products/presentation/products_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  ProviderContainer makeContainer(FakeProductsRepository repo) {
    final container = ProviderContainer(
      overrides: [productsRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('ProductsListController', () {
    test('initial refresh loads items from repository', () async {
      final repo = FakeProductsRepository(
        listResult: Success(
          pagedProducts([sampleProduct('1', 'Аспирин')], total: 1),
        ),
      );
      final container = makeContainer(repo);
      // Reading the provider constructs the controller and triggers refresh().
      container.read(productsListControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(productsListControllerProvider);
      expect(state.products, hasLength(1));
      expect(state.products.first.name, 'Аспирин');
      expect(state.total, 1);
      expect(state.isLoading, isFalse);
      expect(state.failure, isNull);
    });

    test('list failure surfaces failure and empty products', () async {
      final repo = FakeProductsRepository(
        listResult: const Error(NetworkFailure()),
      );
      final container = makeContainer(repo);
      container.read(productsListControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(productsListControllerProvider);
      expect(state.products, isEmpty);
      expect(state.failure, isA<NetworkFailure>());
    });

    test('search trims, resets to page 1, and queries repo', () async {
      final repo = FakeProductsRepository(
        listResult: Success(pagedProducts([], total: 0)),
      );
      final container = makeContainer(repo);
      final controller =
          container.read(productsListControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      await controller.search('  парацетамол  ');

      expect(repo.lastSearch, 'парацетамол');
      expect(container.read(productsListControllerProvider).page, 1);
      expect(container.read(productsListControllerProvider).search,
          'парацетамол');
    });

    test('pagination bounds: hasNext/hasPrevious/pageCount', () async {
      // total 45, size 20 -> 3 pages.
      final repo = FakeProductsRepository(
        listResult: Success(
          Paged<Product>(
            items: [sampleProduct('1', 'X')],
            total: 45,
            page: 1,
            size: 20,
          ),
        ),
      );
      final container = makeContainer(repo);
      final controller =
          container.read(productsListControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      var state = container.read(productsListControllerProvider);
      expect(state.pageCount, 3);
      expect(state.hasPrevious, isFalse);
      expect(state.hasNext, isTrue);

      // Move to page 2 (repo echoes page from query via fake; emulate by
      // returning page 2 result).
      repo.listResult = Success(
        Paged<Product>(
          items: [sampleProduct('2', 'Y')],
          total: 45,
          page: 2,
          size: 20,
        ),
      );
      await controller.nextPage();
      state = container.read(productsListControllerProvider);
      expect(state.page, 2);
      expect(state.hasPrevious, isTrue);
      expect(state.hasNext, isTrue);

      // previousPage guard: at page 1 it should not call repo again.
      repo.listResult = Success(
        Paged<Product>(
          items: const [],
          total: 45,
          page: 1,
          size: 20,
        ),
      );
      await controller.previousPage();
      expect(container.read(productsListControllerProvider).page, 1);
    });
  });

  group('ProductFormController', () {
    test('create calls repo.create and refreshes the list', () async {
      final repo = FakeProductsRepository(
        listResult: Success(pagedProducts([], total: 0)),
      );
      final container = makeContainer(repo);
      container.read(productsListControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);
      final listCallsBefore = repo.listCalls;

      final controller = container.read(productFormControllerProvider.notifier);
      final result = await controller.create(sampleProduct('', 'Новый'));
      await Future<void>.delayed(Duration.zero);

      expect(result, isA<ProductSaveSuccess>());
      expect(repo.createCalls, 1);
      expect(repo.lastCreated!.name, 'Новый');
      // List refreshed after the mutation.
      expect(repo.listCalls, greaterThan(listCallsBefore));
    });

    test('create failure yields ProductSaveFailure', () async {
      final repo = FakeProductsRepository(
        createResult: const Error(ServerFailure('boom', statusCode: 500)),
      );
      final container = makeContainer(repo);
      final controller = container.read(productFormControllerProvider.notifier);

      final result = await controller.create(sampleProduct('', 'X'));

      expect(result, isA<ProductSaveFailure>());
      expect((result as ProductSaveFailure).failure, isA<ServerFailure>());
    });

    test('delete calls repo.delete then refreshes', () async {
      final repo = FakeProductsRepository(
        listResult: Success(pagedProducts([], total: 0)),
      );
      final container = makeContainer(repo);
      container.read(productsListControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);
      final before = repo.listCalls;

      final controller = container.read(productFormControllerProvider.notifier);
      final result = await controller.delete('1');
      await Future<void>.delayed(Duration.zero);

      expect(result, isA<ProductSaveSuccess>());
      expect(repo.deleteCalls, 1);
      expect(repo.listCalls, greaterThan(before));
    });
  });
}

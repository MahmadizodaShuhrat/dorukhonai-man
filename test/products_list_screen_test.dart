import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/features/products/data/products_repository.dart';
import 'package:dorukhonai_man/features/products/presentation/products_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

Widget _host(FakeProductsRepository repo) {
  return ProviderScope(
    overrides: [productsRepositoryProvider.overrideWithValue(repo)],
    child: const MaterialApp(home: ProductsListScreen()),
  );
}

void main() {
  testWidgets('renders product rows from a Paged result', (tester) async {
    final repo = FakeProductsRepository(
      listResult: Success(
        pagedProducts(
          [
            sampleProduct('1', 'Аспирин'),
            sampleProduct('2', 'Парацетамол'),
          ],
          total: 2,
        ),
      ),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    expect(find.text('Аспирин'), findsOneWidget);
    expect(find.text('Парацетамол'), findsOneWidget);
    // Total shown in the pagination bar.
    expect(find.textContaining('Ҳамагӣ: 2'), findsOneWidget);
  });

  testWidgets('empty result shows the empty state', (tester) async {
    final repo = FakeProductsRepository(
      listResult: Success(pagedProducts([], total: 0)),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    expect(find.text('Дору ёфт нашуд'), findsOneWidget);
  });

  testWidgets('failure shows an error message and retry', (tester) async {
    final repo = FakeProductsRepository(
      listResult: const Error(NetworkFailure()),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    expect(find.text('Хатои шабака. Пайвастро санҷед.'), findsOneWidget);
    expect(find.text('Аз нав кӯшиш кунед'), findsOneWidget);
  });
}

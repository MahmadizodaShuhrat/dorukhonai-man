import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/features/receipts/data/receipt_models.dart';
import 'package:dorukhonai_man/features/receipts/data/receipts_repository.dart';
import 'package:dorukhonai_man/features/products/data/product_models.dart'
    show Supplier;
import 'package:dorukhonai_man/features/receipts/presentation/receipts_list_screen.dart';
import 'package:dorukhonai_man/features/reference/data/reference_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

Widget _host(FakeReceiptsRepository repo, {FakeReferenceRepository? reference}) {
  return ProviderScope(
    overrides: [
      receiptsRepositoryProvider.overrideWithValue(repo),
      // The supplier filter EntityPicker + column-name lookup read reference.
      referenceRepositoryProvider.overrideWithValue(
        reference ?? FakeReferenceRepository(),
      ),
    ],
    // ReceiptsListScreen renders INSIDE the desktop shell, which provides the
    // Scaffold/Material/ScaffoldMessenger ancestors — mirror that here.
    child: const MaterialApp(home: Scaffold(body: ReceiptsListScreen())),
  );
}

void main() {
  testWidgets('renders receipt rows from a Paged result', (tester) async {
    final repo = FakeReceiptsRepository(
      listResult: Success(
        paged(
          [
            sampleReceipt(id: 'r1', number: 'PR-001', total: 30),
            sampleReceipt(id: 'r2', number: 'PR-002', total: 50),
          ],
          total: 2,
        ),
      ),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    expect(find.text('PR-001'), findsOneWidget);
    expect(find.text('PR-002'), findsOneWidget);
    expect(find.textContaining('Ҳамагӣ: 2'), findsOneWidget);
  });

  testWidgets('empty result shows the empty state', (tester) async {
    final repo = FakeReceiptsRepository(
      listResult: Success(paged(<Receipt>[], total: 0)),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    expect(find.text('Приход ёфт нашуд'), findsOneWidget);
  });

  testWidgets('failure shows an error message and retry', (tester) async {
    final repo = FakeReceiptsRepository(
      listResult: const Error(NetworkFailure()),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    expect(find.text('Хатои шабака. Пайвастро санҷед.'), findsOneWidget);
    expect(find.text('Аз нав'), findsOneWidget);
  });

  testWidgets('tapping the Posted status chip filters via the repository',
      (tester) async {
    final repo = FakeReceiptsRepository(
      listResult: Success(paged([sampleReceipt()], total: 1)),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    // 'Тасдиқшуда' is the Tajik label for the Posted status chip.
    await tester.tap(find.text('Тасдиқшуда'));
    await tester.pumpAndSettle();

    expect(repo.lastStatusFilter, ReceiptStatus.posted);
  });

  testWidgets('supplier column shows the resolved name, not the GUID',
      (tester) async {
    final repo = FakeReceiptsRepository(
      listResult: Success(
        paged(
          [sampleReceipt(id: 'r1', number: 'PR-001', supplierId: 'sup-1')],
          total: 1,
        ),
      ),
    );
    final reference = FakeReferenceRepository(
      supplierList: const [Supplier(id: 'sup-1', name: 'Фармотрейд')],
    );

    await tester.pumpWidget(_host(repo, reference: reference));
    await tester.pumpAndSettle();

    // The name is shown; the raw supplier id is not.
    expect(find.text('Фармотрейд'), findsWidgets);
    expect(find.text('sup-1'), findsNothing);
  });
}

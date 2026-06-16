import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/features/products/data/products_repository.dart';
import 'package:dorukhonai_man/features/receipts/data/receipts_repository.dart';
import 'package:dorukhonai_man/features/receipts/presentation/receipt_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

Widget _host(FakeReceiptsRepository receipts, FakeProductsRepository products) {
  return ProviderScope(
    overrides: [
      receiptsRepositoryProvider.overrideWithValue(receipts),
      productsRepositoryProvider.overrideWithValue(products),
    ],
    child: const MaterialApp(home: ReceiptEditScreen()),
  );
}

void main() {
  testWidgets('validation blocks Save Draft when header/lines are empty',
      (tester) async {
    final receipts = FakeReceiptsRepository();
    final products = FakeProductsRepository();

    await tester.pumpWidget(_host(receipts, products));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Нигоҳ доштан (Лоиҳа)'));
    await tester.pumpAndSettle();

    // Supplier is the first missing field → its message shows.
    expect(find.text('Таъминкунандаро ворид кунед'), findsOneWidget);
    expect(receipts.createCalls, 0);
  });

  testWidgets(
      'adding a line updates the running total and Save Draft calls create',
      (tester) async {
    final receipts = FakeReceiptsRepository();
    final products = FakeProductsRepository(
      listResult: Success(
        pagedProducts([sampleProduct('p1', 'Аспирин')], total: 1),
      ),
    );

    await tester.pumpWidget(_host(receipts, products));
    await tester.pumpAndSettle();

    // Fill the header IDs.
    await tester.enterText(
      find.widgetWithText(TextField, 'Таъминкунанда (ID) *'),
      'sup-1',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Филиал (ID) *'),
      'br-1',
    );
    await tester.pumpAndSettle();

    // Open the product picker, pick the product.
    await tester.tap(find.text('Илова сатр'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Аспирин'));
    await tester.pumpAndSettle();

    // The line dialog opens; fill quantity / series / prices.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Миқдор *'),
      '2',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Серия *'),
      'S-1',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Нархи харид *'),
      '10',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Нархи фурӯш *'),
      '15',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Илова')); // confirm line
    await tester.pumpAndSettle();

    // Running total = 2 * 10 = 20 -> shown in the bottom bar (somoni format).
    expect(find.textContaining('Ҷамъ:'), findsWidgets);
    expect(find.textContaining('20'), findsWidgets);

    // Save Draft now passes validation and creates.
    await tester.tap(find.text('Нигоҳ доштан (Лоиҳа)'));
    await tester.pumpAndSettle();

    expect(receipts.createCalls, 1);
    final created = receipts.lastCreated!;
    expect(created.supplierId, 'sup-1');
    expect(created.branchId, 'br-1');
    expect(created.lines, hasLength(1));
    expect(created.lines.first.productId, 'p1');
    expect(created.lines.first.quantity, 2);
    expect(created.lines.first.seriesNumber, 'S-1');
  });

  testWidgets('line dialog validation rejects empty quantity/series',
      (tester) async {
    final receipts = FakeReceiptsRepository();
    final products = FakeProductsRepository(
      listResult: Success(
        pagedProducts([sampleProduct('p1', 'Аспирин')], total: 1),
      ),
    );

    await tester.pumpWidget(_host(receipts, products));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Илова сатр'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Аспирин'));
    await tester.pumpAndSettle();

    // Submit the empty line dialog → validators fire, dialog stays open.
    await tester.tap(find.text('Илова'));
    await tester.pumpAndSettle();

    expect(find.text('Рақами дуруст ворид кунед'), findsWidgets);
    expect(find.text('Серияро ворид кунед'), findsOneWidget);
  });
}

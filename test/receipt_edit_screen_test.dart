import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/features/products/data/product_models.dart';
import 'package:dorukhonai_man/features/products/data/products_repository.dart';
import 'package:dorukhonai_man/features/receipts/data/receipt_models.dart';
import 'package:dorukhonai_man/features/receipts/data/receipts_repository.dart';
import 'package:dorukhonai_man/features/receipts/presentation/receipt_edit_screen.dart';
import 'package:dorukhonai_man/features/reference/data/reference_repository.dart';
import 'package:dorukhonai_man/shared/entity_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/l10n_harness.dart';

Widget _host(
  FakeReceiptsRepository receipts,
  FakeProductsRepository products, {
  FakeReferenceRepository? reference,
  String? receiptId,
}) {
  return ProviderScope(
    overrides: [
      receiptsRepositoryProvider.overrideWithValue(receipts),
      productsRepositoryProvider.overrideWithValue(products),
      // Supplier EntityPicker reads reference data.
      referenceRepositoryProvider.overrideWithValue(
        reference ?? FakeReferenceRepository(),
      ),
    ],
    child: localizedApp(ReceiptEditScreen(receiptId: receiptId)),
  );
}

/// Returns the nth inline cell TextField. The header contributes one TextField
/// (the branch field, index 0), so line fields start at index 1.
Finder _lineFieldAt(int n) => find.byType(TextField).at(1 + n);

void main() {
  testWidgets('validation blocks Save Draft when header/lines are empty', (
    tester,
  ) async {
    final receipts = FakeReceiptsRepository();
    final products = FakeProductsRepository();

    await tester.pumpWidget(_host(receipts, products));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Нигоҳ доштан (Лоиҳа)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Supplier is the first missing field → its toast message shows.
    expect(find.text('Таъминкунандаро интихоб кунед'), findsOneWidget);
    expect(receipts.createCalls, 0);
  });

  testWidgets(
    'adding an inline line updates the running total and Save Draft creates',
    (tester) async {
      final receipts = FakeReceiptsRepository();
      final products = FakeProductsRepository(
        listResult: Success(
          pagedProducts([sampleProduct('p1', 'Аспирин')], total: 1),
        ),
      );
      final reference = FakeReferenceRepository(
        supplierList: const [Supplier(id: 'sup-1', name: 'Фармотрейд')],
      );

      await tester.pumpWidget(
        _host(receipts, products, reference: reference),
      );
      await tester.pumpAndSettle();

      // Pick the supplier via the EntityPicker dialog (name → id).
      await tester.tap(find.byType(EntityPicker));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Фармотрейд'));
      await tester.pumpAndSettle();

      // Fill the branch id (still a typed field for the single-branch case).
      await tester.enterText(
        find.widgetWithText(TextField, 'Филиал *'),
        'br-1',
      );
      await tester.pumpAndSettle();

      // Open the product picker, pick the product → a new inline row appears.
      await tester.tap(find.text('Илова сатр / скан штрих-код'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Аспирин'));
      await tester.pumpAndSettle();

      // Fill the in-row cells: quantity / series / purchase / sale price.
      await tester.enterText(_lineFieldAt(0), '2'); // quantity
      await tester.enterText(_lineFieldAt(1), 'S-1'); // series
      await tester.enterText(_lineFieldAt(2), '10'); // purchase
      await tester.enterText(_lineFieldAt(3), '15'); // sale
      await tester.pumpAndSettle();

      // Running total = 2 * 10 = 20 -> shown in the bottom bar.
      expect(find.textContaining('Ҷамъи харид:'), findsOneWidget);
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
      expect(created.lines.first.purchasePrice, 10);
      expect(created.lines.first.salePrice, 15);
    },
  );

  testWidgets('Ctrl+Enter opens the product picker to add a new line', (
    tester,
  ) async {
    final receipts = FakeReceiptsRepository();
    final products = FakeProductsRepository(
      listResult: Success(
        pagedProducts([sampleProduct('p1', 'Аспирин')], total: 1),
      ),
    );

    await tester.pumpWidget(_host(receipts, products));
    await tester.pumpAndSettle();

    // No picker yet.
    expect(find.text('Интихоби дору'), findsNothing);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    // The product-picker dialog (title "Интихоби дору") is now open.
    expect(find.text('Интихоби дору'), findsOneWidget);
  });

  testWidgets('line validation rejects an empty quantity/series', (
    tester,
  ) async {
    final receipts = FakeReceiptsRepository();
    final products = FakeProductsRepository(
      listResult: Success(
        pagedProducts([sampleProduct('p1', 'Аспирин')], total: 1),
      ),
    );
    final reference = FakeReferenceRepository(
      supplierList: const [Supplier(id: 'sup-1', name: 'Фармотрейд')],
    );

    await tester.pumpWidget(_host(receipts, products, reference: reference));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(EntityPicker));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Фармотрейд'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Филиал *'), 'br-1');

    // Add a line but leave the cells empty.
    await tester.tap(find.text('Илова сатр / скан штрих-код'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Аспирин'));
    await tester.pumpAndSettle();

    // Try to save → per-line validation fails and create is not called.
    await tester.tap(find.text('Нигоҳ доштан (Лоиҳа)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.textContaining('миқдори дуруст'), findsOneWidget);
    expect(receipts.createCalls, 0);
  });

  testWidgets('Тасдиқ on a loaded draft confirms then calls post', (
    tester,
  ) async {
    final receipts = FakeReceiptsRepository(
      getByIdResult: Success(
        sampleReceipt(
          id: 'r1',
          number: 'PR-001',
          status: ReceiptStatus.draft,
          lines: [sampleLine()],
          total: 20,
        ),
      ),
      postResult: Success(
        sampleReceipt(
          id: 'r1',
          number: 'PR-001',
          status: ReceiptStatus.posted,
          lines: [sampleLine()],
          total: 20,
        ),
      ),
    );
    final products = FakeProductsRepository();

    await tester.pumpWidget(_host(receipts, products, receiptId: 'r1'));
    await tester.pumpAndSettle();

    // Тасдиқ opens a confirm dialog; confirm → repository.post('r1').
    await tester.tap(find.widgetWithText(FilledButton, 'Тасдиқ'));
    await tester.pumpAndSettle();
    // The confirm dialog's button lives inside the AlertDialog.
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Тасдиқ'),
      ),
    );
    await tester.pumpAndSettle();

    expect(receipts.postCalls, 1);
    expect(receipts.lastPostedId, 'r1');
  });

  testWidgets('posted receipt renders read-only (no Save/Post, no add row)', (
    tester,
  ) async {
    final receipts = FakeReceiptsRepository(
      getByIdResult: Success(
        sampleReceipt(
          id: 'r1',
          number: 'PR-001',
          status: ReceiptStatus.posted,
          lines: [sampleLine()],
          total: 20,
        ),
      ),
    );
    final products = FakeProductsRepository();

    await tester.pumpWidget(
      _host(receipts, products, receiptId: 'r1'),
    );
    await tester.pumpAndSettle();

    // Read-only: no editing actions, but a Cancel (Бекор) is still available.
    expect(find.text('Нигоҳ доштан (Лоиҳа)'), findsNothing);
    expect(find.text('Тасдиқ'), findsNothing);
    expect(find.text('Илова сатр / скан штрих-код'), findsNothing);
    expect(find.text('Бекор'), findsOneWidget);
    // The posted line is shown.
    expect(find.text('Аспирин'), findsOneWidget);
  });
}

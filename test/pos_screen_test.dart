import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/features/branch/data/branch_models.dart';
import 'package:dorukhonai_man/features/branch/presentation/branch_provider.dart';
import 'package:dorukhonai_man/features/pos/data/pos_models.dart';
import 'package:dorukhonai_man/features/pos/data/pos_repository.dart';
import 'package:dorukhonai_man/features/pos/presentation/close_shift_dialog.dart';
import 'package:dorukhonai_man/features/pos/presentation/payment_dialog.dart';
import 'package:dorukhonai_man/features/pos/presentation/pos_providers.dart';
import 'package:dorukhonai_man/features/pos/presentation/pos_screen.dart';
import 'package:dorukhonai_man/features/pos/presentation/receipt_view.dart';
import 'package:dorukhonai_man/features/pos/presentation/returns_dialog.dart';
import 'package:dorukhonai_man/features/products/data/product_models.dart';
import 'package:dorukhonai_man/features/products/data/products_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

/// Hosts [PosScreen] with fake POS + products + branch repositories. The fake
/// branch resolves to `br-1` (matching `sampleShift`).
Widget _host(FakePosRepository pos, {FakeProductsRepository? products}) {
  return ProviderScope(
    overrides: [
      posRepositoryProvider.overrideWithValue(pos),
      productsRepositoryProvider.overrideWithValue(
        products ?? FakeProductsRepository(),
      ),
      // Resolve the branch directly to `br-1` (matching `sampleShift`) so POS
      // tests stay free of the auth/dio/prefs chain.
      currentBranchProvider.overrideWith(
        (ref) async =>
            const Branch(id: 'br-1', name: 'Дорухонаи марказӣ', isCentral: true),
      ),
    ],
    child: const MaterialApp(home: PosScreen()),
  );
}

/// POS is a desktop-only two-pane register (TZ_03 §C.2); size the test surface
/// to a desktop window so both panes (and the header actions) lay out on-screen
/// instead of the default 800x600 phone surface.
void _desktop(WidgetTester tester) {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  group('Open-shift gating', () {
    testWidgets('no open shift shows the open-shift panel', (tester) async {
      _desktop(tester);
      // currentShift defaults to a 404 -> no shift.
      await tester.pumpWidget(_host(FakePosRepository()));
      await tester.pumpAndSettle();

      expect(find.text('Смена кушода нашудааст'), findsOneWidget);
      expect(find.text('Кушодани смена'), findsOneWidget);
      // Sale screen chrome is absent.
      expect(find.text('Пардохт (F9)'), findsNothing);
    });

    testWidgets('opening a shift transitions to the sale screen',
        (tester) async {
      _desktop(tester);
      final repo = FakePosRepository(
        openShiftResult: Success(sampleShift()),
      );
      await tester.pumpWidget(_host(repo));
      await tester.pumpAndSettle();

      // No typed "Филиал (ID)" field anymore (single branch implicit, §C.2);
      // tap open, then fill opening cash.
      await tester.tap(find.text('Кушодани смена'));
      await tester.pumpAndSettle();

      // Opening-cash dialog -> confirm (defaults to 0).
      expect(find.text('Нақди ибтидоӣ *'), findsOneWidget);
      await tester.tap(find.text('Кушодан'));
      await tester.pumpAndSettle();

      expect(repo.openShiftCalls, 1);
      // The REAL resolved branch id (from /branches) is sent, not 'default'.
      expect(repo.lastBranchId, 'br-1');
      // Sale screen is now shown.
      expect(find.text('Пардохт (F9)'), findsOneWidget);
    });

    testWidgets('opening with a 409 surfaces the conflict message',
        (tester) async {
      _desktop(tester);
      final repo = FakePosRepository(
        openShiftResult: const Error(
          ServerFailure('Смена аллакай кушода аст.', statusCode: 409),
        ),
      );
      await tester.pumpWidget(_host(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Кушодани смена'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Кушодан'));
      await tester.pumpAndSettle();

      // The 409 message is surfaced (panel state failure + snackbar).
      expect(find.text('Смена аллакай кушода аст.'), findsWidgets);
      // Still on the open-shift panel.
      expect(find.text('Смена кушода нашудааст'), findsOneWidget);
    });
  });

  group('Cart operations', () {
    Future<FakePosRepository> openSale(
      WidgetTester tester, {
      FakeProductsRepository? products,
    }) async {
      _desktop(tester);
      final repo = FakePosRepository(currentShiftResult: Success(sampleShift()));
      await tester.pumpWidget(_host(repo, products: products));
      await tester.pumpAndSettle();
      // currentShift returns an open shift -> sale screen directly.
      expect(find.text('Пардохт (F9)'), findsOneWidget);
      return repo;
    }

    testWidgets('scan exact barcode adds a cart row and running total',
        (tester) async {
      final products = FakeProductsRepository(
        getByBarcodeResult: Success(
          const Product(id: 'p1', name: 'Аспирин'),
        ),
      );
      await openSale(tester, products: products);

      // Type a barcode into the scan field and submit (scanner Enter).
      await tester.enterText(find.byType(TextField).first, '4600000000001');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(products.getByBarcodeCalls, 1);
      expect(products.lastBarcode, '4600000000001');
      expect(find.text('Аспирин'), findsOneWidget);
    });

    testWidgets('qty +/- updates line total and TOTAL; remove clears the cart',
        (tester) async {
      await openSale(tester);

      // Seed the cart directly via the controller (scan path covered above).
      final ctx = tester.element(find.byType(PosScreen));
      final container = ProviderScope.containerOf(ctx);
      container
          .read(posCartControllerProvider.notifier)
          .addProduct(const Product(id: 'p1', name: 'Аспирин'),
              quantity: 1, unitPrice: 10);
      await tester.pumpAndSettle();

      expect(find.text('Аспирин'), findsOneWidget);

      // Increment via the + button.
      await tester.tap(find.byIcon(Icons.add_circle_outline).first);
      await tester.pumpAndSettle();
      expect(container.read(posCartControllerProvider).items.first.quantity, 2);

      // Decrement via the - button.
      await tester.tap(find.byIcon(Icons.remove_circle_outline).first);
      await tester.pumpAndSettle();
      expect(container.read(posCartControllerProvider).items.first.quantity, 1);

      // Remove the row.
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();
      expect(container.read(posCartControllerProvider).items, isEmpty);
      expect(find.textContaining('Сабад холӣ'), findsOneWidget);
    });

    testWidgets('cart discount field recomputes the running total',
        (tester) async {
      await openSale(tester);
      final ctx = tester.element(find.byType(PosScreen));
      final container = ProviderScope.containerOf(ctx);
      container.read(posCartControllerProvider.notifier).addProduct(
            const Product(id: 'p1', name: 'Аспирин'),
            quantity: 2,
            unitPrice: 10,
          );
      await tester.pumpAndSettle();

      // Enter a cart-level discount in the checkout bar field (labelled "Тахфиф").
      final discountField = find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            (w.decoration?.labelText?.startsWith('Тахфиф') ?? false),
      );
      await tester.enterText(discountField, '5');
      await tester.pumpAndSettle();

      expect(container.read(posCartControllerProvider).discount, 5);
      expect(container.read(posCartControllerProvider).total, 15); // 20 - 5
    });
  });

  group('Payment', () {
    testWidgets('cannot pay an empty cart', (tester) async {
      _desktop(tester);
      final repo = FakePosRepository(currentShiftResult: Success(sampleShift()));
      await tester.pumpWidget(_host(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Пардохт (F9)'));
      await tester.pumpAndSettle();

      // No payment dialog opened; an empty-cart snackbar showed instead.
      expect(find.byType(PaymentDialog), findsNothing);
      expect(find.text('Сабад холӣ аст'), findsOneWidget);
      expect(repo.createSaleCalls, 0);
    });

    testWidgets(
        'valid cash payment calls createSale with the contract body and clears',
        (tester) async {
      _desktop(tester);
      final repo = FakePosRepository(
        currentShiftResult: Success(sampleShift()),
        createSaleResult: Success(sampleSale(number: 'S-100')),
      );
      await tester.pumpWidget(_host(repo));
      await tester.pumpAndSettle();

      final ctx = tester.element(find.byType(PosScreen));
      final container = ProviderScope.containerOf(ctx);
      container.read(posCartControllerProvider.notifier).addProduct(
            const Product(id: 'p1', name: 'Аспирин'),
            quantity: 2,
            unitPrice: 15,
          );
      await tester.pumpAndSettle();

      // Open the payment dialog.
      await tester.tap(find.text('Пардохт (F9)'));
      await tester.pumpAndSettle();
      expect(find.byType(PaymentDialog), findsOneWidget);
      // Default cash tender == total (30); change due is 0.
      expect(find.text('Қайтарма:'), findsOneWidget);

      // Over-tender the cash to verify change.
      final amountField = find.widgetWithText(TextField, '30');
      await tester.enterText(amountField, '50');
      await tester.pumpAndSettle();
      // Change = 50 - 30 = 20.00.
      expect(find.textContaining('20'), findsWidgets);

      // Confirm payment.
      await tester.tap(find.text('Тасдиқ'));
      await tester.pumpAndSettle();

      // createSale body shape.
      expect(repo.createSaleCalls, 1);
      expect(repo.lastBranchId, sampleShift().branchId);
      expect(repo.lastSaleLines, hasLength(1));
      expect(repo.lastSaleLines!.first.productId, 'p1');
      expect(repo.lastSaleLines!.first.quantity, 2);
      expect(repo.lastSalePayments, hasLength(1));
      expect(repo.lastSalePayments!.first.method, PaymentMethod.cash);
      // Booked amount == total (over-tender returned as change, not recorded).
      expect(repo.lastSalePayments!.first.amount, 30);

      // Receipt shows; cart cleared.
      expect(find.byType(ReceiptDialog), findsOneWidget);
      expect(find.text('Чек № S-100'), findsOneWidget);
      expect(container.read(posCartControllerProvider).items, isEmpty);
    });

    testWidgets('payment confirm is disabled when tender < total',
        (tester) async {
      // Drive the payment dialog directly for the validation rule.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => PaymentDialog.show(context, 100),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // Under-tender.
      await tester.enterText(find.byType(TextField), '40');
      await tester.pumpAndSettle();

      final confirm = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Тасдиқ'),
      );
      expect(confirm.onPressed, isNull); // disabled
    });
  });

  group('Receipt rendering (server FEFO lines)', () {
    testWidgets('renders both lines of a multi-batch split for one product',
        (tester) async {
      // The server split one requested product across two batches.
      final sale = sampleSale(
        lines: [
          sampleSaleLine(
            id: 'sl-1',
            batchId: 'b1',
            series: 'AAA',
            quantity: 3,
            unitPrice: 10,
            lineTotal: 30,
          ),
          sampleSaleLine(
            id: 'sl-2',
            batchId: 'b2',
            series: 'BBB',
            quantity: 2,
            unitPrice: 12,
            lineTotal: 24,
          ),
        ],
        subtotal: 54,
        total: 54,
        payments: const [Payment(method: PaymentMethod.cash, amount: 54)],
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ReceiptDialog(sale: sale))),
      );
      await tester.pumpAndSettle();

      // Both batches/series render as separate receipt lines.
      expect(find.text('Серия: AAA'), findsOneWidget);
      expect(find.text('Серия: BBB'), findsOneWidget);
      expect(find.text('ҲАМАГӢ'), findsOneWidget);
    });
  });

  group('Close shift', () {
    testWidgets('closing shows the Z-report summary', (tester) async {
      _desktop(tester);
      final repo = FakePosRepository(
        currentShiftResult: Success(sampleShift()),
        closeShiftResult: Success(
          sampleShift(status: ShiftStatus.closed, closingCash: 450),
        ),
        zReportResult: Success(
          ZReport(
            shiftId: 'shift-1',
            branchId: 'br-1',
            openedAt: DateTime(2026, 6, 16, 9),
            closedAt: DateTime(2026, 6, 16, 18),
            openingCash: 100,
            closingCash: 450,
            salesCount: 12,
            totalSales: 400,
            totalReturns: 50,
            netTotal: 350,
            byMethod: const {
              PaymentMethod.cash: 300,
              PaymentMethod.card: 100,
              PaymentMethod.credit: 0,
            },
            expectedCash: 400,
          ),
        ),
      );
      await tester.pumpWidget(_host(repo));
      await tester.pumpAndSettle();

      // Open the close-shift dialog from the app-bar action.
      await tester.tap(find.byIcon(Icons.lock_outline));
      await tester.pumpAndSettle();
      expect(find.byType(CloseShiftDialog), findsOneWidget);

      // Enter counted cash and close.
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Нақди ниҳоӣ (ҳисобшуда) *'),
        '450',
      );
      await tester.tap(find.text('Бастан'));
      await tester.pumpAndSettle();

      expect(repo.closeShiftCalls, 1);
      expect(repo.lastClosingCash, 450);
      // Z-report figures.
      expect(find.text('Z-ҳисобот'), findsOneWidget);
      expect(find.text('Софи фурӯш'), findsOneWidget);
      expect(find.text('Нақди интизорӣ'), findsOneWidget);
      expect(find.text('Фарқият'), findsOneWidget);
    });
  });

  group('Returns', () {
    testWidgets('returning a sale line calls returnSale with {saleLineId,qty}',
        (tester) async {
      _desktop(tester);
      final sale = sampleSale(
        id: 'sale-1',
        number: 'S-001',
        lines: [sampleSaleLine(id: 'sl-1', quantity: 2)],
      );
      final repo = FakePosRepository(
        currentShiftResult: Success(sampleShift()),
        listSalesResult: Success(paged([sale])),
        getSaleResult: Success(sale),
        returnSaleResult: Success(sale),
      );
      await tester.pumpWidget(_host(repo));
      await tester.pumpAndSettle();

      // Open returns from the app bar.
      await tester.tap(find.byIcon(Icons.assignment_return_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(ReturnsDialog), findsOneWidget);

      // Pick the sale.
      await tester.tap(find.text('Чек № S-001'));
      await tester.pumpAndSettle();
      expect(find.text('Сатрҳои бозгашт'), findsOneWidget);

      // Choose to return 1 unit of the line (tap +).
      await tester.tap(find.byIcon(Icons.add_circle_outline).first);
      await tester.pumpAndSettle();

      // Submit the return.
      await tester.tap(find.widgetWithText(FilledButton, 'Бозгашт'));
      await tester.pumpAndSettle();

      expect(repo.returnSaleCalls, 1);
      expect(repo.lastReturnSaleId, 'sale-1');
      expect(repo.lastReturnLines, hasLength(1));
      expect(repo.lastReturnLines!.first.saleLineId, 'sl-1');
      expect(repo.lastReturnLines!.first.quantity, 1);
    });
  });
}

import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/features/branch/data/branch_models.dart';
import 'package:dorukhonai_man/features/branch/presentation/branch_provider.dart';
import 'package:dorukhonai_man/features/pos/data/pos_models.dart';
import 'package:dorukhonai_man/features/pos/data/pos_repository.dart';
import 'package:dorukhonai_man/features/pos/presentation/payment_dialog.dart';
import 'package:dorukhonai_man/features/pos/presentation/pos_providers.dart';
import 'package:dorukhonai_man/features/pos/presentation/pos_screen.dart';
import 'package:dorukhonai_man/features/pos/presentation/receipt_view.dart';
import 'package:dorukhonai_man/features/products/data/products_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pos_support.dart';
import 'support/l10n_harness.dart';

/// Hosts [PosScreen] with fake POS + products + branch repositories (no
/// network). The fake branch resolves to `br-1` (matching `sampleShift`).
Widget _host(FakePosRepository pos, {FakeProductsRepository? products}) {
  return ProviderScope(
    overrides: [
      posRepositoryProvider.overrideWithValue(pos),
      productsRepositoryProvider.overrideWithValue(
        products ?? FakeProductsRepository(),
      ),
      // Resolve the branch directly to `br-1` (matching `sampleShift`).
      currentBranchProvider.overrideWith(
        (ref) async =>
            const Branch(id: 'br-1', name: 'Дорухонаи марказӣ', isCentral: true),
      ),
    ],
    child: localizedApp(const PosScreen()),
  );
}

/// POS is a desktop-only two-pane register (TZ_03 §C.2); size the surface to a
/// desktop window so both panes lay out on-screen.
void _desktop(WidgetTester tester) {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(PosScreen)));

void main() {
  group('Shift gating', () {
    testWidgets('no open shift shows the open-shift panel (no register)',
        (tester) async {
      _desktop(tester);
      await tester.pumpWidget(_host(FakePosRepository()));
      await tester.pumpAndSettle();

      expect(find.text('Смена кушода нашудааст'), findsOneWidget);
      expect(find.text('Кушодани смена'), findsOneWidget);
      // The register checkout button is absent before a shift opens.
      expect(find.text('Пардохт (F9)'), findsNothing);
    });

    testWidgets('opening a shift transitions to the register', (tester) async {
      _desktop(tester);
      final repo = FakePosRepository(openShiftResult: Success(sampleShift()));
      await tester.pumpWidget(_host(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Кушодани смена'));
      await tester.pumpAndSettle();
      // Opening-cash dialog (no typed branch field, §C.2).
      expect(find.text('Нақди ибтидоӣ *'), findsOneWidget);
      await tester.tap(find.text('Кушодан'));
      await tester.pumpAndSettle();

      expect(repo.openShiftCalls, 1);
      // The REAL resolved branch id (from /branches), not a hardcoded 'default'.
      expect(repo.lastBranchId, 'br-1');
      expect(find.text('Пардохт (F9)'), findsOneWidget);
      expect(find.text('Смена кушода'), findsOneWidget);
    });
  });

  group('Cart', () {
    Future<FakePosRepository> openRegister(
      WidgetTester tester, {
      FakeProductsRepository? products,
    }) async {
      _desktop(tester);
      final repo = FakePosRepository(currentShiftResult: Success(sampleShift()));
      await tester.pumpWidget(_host(repo, products: products));
      await tester.pumpAndSettle();
      expect(find.text('Пардохт (F9)'), findsOneWidget);
      return repo;
    }

    testWidgets('scan of an exact barcode adds a cart row', (tester) async {
      final products = FakeProductsRepository(
        getByBarcodeResult: Success(otcProduct(name: 'Аспирин')),
      );
      await openRegister(tester, products: products);

      await tester.enterText(find.byType(TextField).first, '4600000000001');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(products.getByBarcodeCalls, 1);
      expect(products.lastBarcode, '4600000000001');
      expect(find.text('Аспирин'), findsOneWidget);
      expect(_container(tester).read(posCartControllerProvider).items, hasLength(1));
    });

    testWidgets('qty +/- updates the running TOTAL', (tester) async {
      await openRegister(tester);
      final c = _container(tester);
      c.read(posCartControllerProvider.notifier).addProduct(
            otcProduct(),
            quantity: 1,
            unitPrice: 10,
          );
      await tester.pumpAndSettle();
      expect(c.read(posCartControllerProvider).total, 10);

      await tester.tap(find.byIcon(Icons.add_circle_outline).first);
      await tester.pumpAndSettle();
      expect(c.read(posCartControllerProvider).items.first.quantity, 2);
      expect(c.read(posCartControllerProvider).total, 20);

      await tester.tap(find.byIcon(Icons.remove_circle_outline).first);
      await tester.pumpAndSettle();
      expect(c.read(posCartControllerProvider).total, 10);
    });

    testWidgets('discount field reduces the TOTAL', (tester) async {
      await openRegister(tester);
      final c = _container(tester);
      c.read(posCartControllerProvider.notifier).addProduct(
            otcProduct(),
            quantity: 2,
            unitPrice: 10,
          );
      await tester.pumpAndSettle();

      final discountField = find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            (w.decoration?.labelText?.startsWith('Тахфиф') ?? false),
      );
      await tester.enterText(discountField, '5');
      await tester.pumpAndSettle();

      expect(c.read(posCartControllerProvider).discount, 5);
      expect(c.read(posCartControllerProvider).total, 15);
    });

    testWidgets('prescription product requires confirmation and shows ℞ badge',
        (tester) async {
      final products = FakeProductsRepository(
        getByBarcodeResult: Success(rxProduct(name: 'Амоксициллин')),
      );
      await openRegister(tester, products: products);

      await tester.enterText(find.byType(TextField).first, '4600000000099');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      // Confirm dialog blocks the add until accepted.
      expect(find.text('Доруи ретсептӣ'), findsOneWidget);
      expect(_container(tester).read(posCartControllerProvider).items, isEmpty);

      await tester.tap(find.widgetWithText(FilledButton, 'Тасдиқ'));
      await tester.pumpAndSettle();

      final cart = _container(tester).read(posCartControllerProvider);
      expect(cart.items, hasLength(1));
      expect(cart.items.first.rxRequired, isTrue);
      // ℞ badge renders in the cart row.
      expect(find.text('℞'), findsOneWidget);
    });

    testWidgets('declining the rx confirmation does not add the product',
        (tester) async {
      final products = FakeProductsRepository(
        getByBarcodeResult: Success(rxProduct()),
      );
      await openRegister(tester, products: products);

      await tester.enterText(find.byType(TextField).first, '999');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Бекор'));
      await tester.pumpAndSettle();

      expect(_container(tester).read(posCartControllerProvider).items, isEmpty);
    });
  });

  group('Payment', () {
    testWidgets('empty cart pay is blocked (no createSale)', (tester) async {
      _desktop(tester);
      final repo = FakePosRepository(currentShiftResult: Success(sampleShift()));
      await tester.pumpWidget(_host(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Пардохт (F9)'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(PaymentDialog), findsNothing);
      expect(find.text('Сабад холӣ аст'), findsOneWidget);
      expect(repo.createSaleCalls, 0);
    });

    testWidgets(
        'valid cash pay calls createSale with contract body, shows receipt, clears',
        (tester) async {
      _desktop(tester);
      final repo = FakePosRepository(
        currentShiftResult: Success(sampleShift()),
        createSaleResult: Success(sampleSale(number: 'S-200')),
      );
      await tester.pumpWidget(_host(repo));
      await tester.pumpAndSettle();

      final c = _container(tester);
      c.read(posCartControllerProvider.notifier).addProduct(
            otcProduct(),
            quantity: 2,
            unitPrice: 15,
          );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Пардохт (F9)'));
      await tester.pumpAndSettle();
      expect(find.byType(PaymentDialog), findsOneWidget);

      await tester.tap(find.text('Тасдиқ'));
      await tester.pumpAndSettle();

      expect(repo.createSaleCalls, 1);
      expect(repo.lastBranchId, sampleShift().branchId);
      expect(repo.lastSaleLines, hasLength(1));
      expect(repo.lastSaleLines!.first.productId, 'p1');
      expect(repo.lastSaleLines!.first.quantity, 2);
      expect(repo.lastSalePayments!.first.method, PaymentMethod.cash);
      expect(repo.lastSalePayments!.first.amount, 30);

      expect(find.byType(ReceiptDialog), findsOneWidget);
      expect(find.text('Чек № S-200'), findsOneWidget);
      expect(c.read(posCartControllerProvider).items, isEmpty);
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

      await tester.tap(find.byIcon(Icons.lock_outline));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Нақди ниҳоӣ (ҳисобшуда) *'),
        '450',
      );
      await tester.tap(find.text('Бастан'));
      await tester.pumpAndSettle();

      expect(repo.closeShiftCalls, 1);
      expect(repo.lastClosingCash, 450);
      expect(find.text('Z-ҳисобот'), findsOneWidget);
    });
  });
}

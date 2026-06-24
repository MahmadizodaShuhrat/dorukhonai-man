// MODUL 6 (Амалиёти анбор) tests: the draft controller + validation logic, and
// each editor screen posts the correct contract body and renders history.

import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/features/branch/data/branch_models.dart';
import 'package:dorukhonai_man/features/branch/presentation/branch_provider.dart';
import 'package:dorukhonai_man/features/operations/data/operations_models.dart';
import 'package:dorukhonai_man/features/operations/data/operations_repository.dart';
import 'package:dorukhonai_man/features/operations/presentation/inventory_screen.dart';
import 'package:dorukhonai_man/features/operations/presentation/operations_providers.dart';
import 'package:dorukhonai_man/features/operations/presentation/operations_widgets.dart';
import 'package:dorukhonai_man/features/operations/presentation/supplier_return_screen.dart';
import 'package:dorukhonai_man/features/operations/presentation/write_off_screen.dart';
import 'package:dorukhonai_man/features/reference/data/reference_repository.dart';
import 'package:dorukhonai_man/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'operations_support.dart';
import 'support/fakes.dart';
import 'support/l10n_harness.dart';

/// Synchronous Tajik localizations for unit-testing context-free helpers.
final AppLocalizations _l = lookupAppLocalizations(const Locale('tg'));

OperationLine _line({
  String batchId = 'b1',
  String name = 'Парацетамол',
  double onHand = 10,
  double quantity = 2,
}) => OperationLine(
      batchId: batchId,
      productName: name,
      seriesNumber: 'S-1',
      onHand: onHand,
      quantity: quantity,
    );

void _desktop(WidgetTester tester) {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

List<Override> _overrides(FakeOperationsRepository repo) => [
      operationsRepositoryProvider.overrideWithValue(repo),
      referenceRepositoryProvider.overrideWithValue(FakeReferenceRepository()),
      currentBranchProvider.overrideWith(
        (ref) async =>
            const Branch(id: 'br-1', name: 'Марказӣ', isCentral: true),
      ),
    ];

void main() {
  group('OperationDraftController', () {
    test('addOrUpdate merges by batch; setQuantity / removeAt edit', () {
      final c = OperationDraftController();
      c.addOrUpdate(_line(quantity: 1));
      c.addOrUpdate(_line(quantity: 5)); // same batch -> replace
      expect(c.state, hasLength(1));
      expect(c.state.first.quantity, 5);

      c.addOrUpdate(_line(batchId: 'b2', quantity: 3));
      expect(c.state, hasLength(2));
      c.setQuantity(0, 9);
      expect(c.state[0].quantity, 9);
      c.removeAt(0);
      expect(c.state, hasLength(1));
      expect(c.state.first.batchId, 'b2');
    });
  });

  group('validateOperationLines', () {
    test('requires a resolved branch and at least one line', () {
      expect(validateOperationLines(_l, const [], 'br-1'), isNotNull);
      expect(validateOperationLines(_l, [_line()], null), isNotNull);
      expect(validateOperationLines(_l, [_line()], ''), isNotNull);
    });

    test('rejects qty>onhand when enforced, allows it for inventory', () {
      final over = [_line(onHand: 2, quantity: 5)];
      expect(validateOperationLines(_l, over, 'br-1'), isNotNull);
      expect(
        validateOperationLines(
          _l,
          over,
          'br-1',
          enforceMaxOnHand: false,
          requirePositive: false,
        ),
        isNull,
      );
    });

    test('valid write-off draft passes', () {
      expect(
        validateOperationLines(_l, [_line(quantity: 2, onHand: 10)], 'br-1'),
        isNull,
      );
    });
  });

  group('Write-off screen', () {
    testWidgets('posts {branchId, reason, lines} and clears the draft',
        (tester) async {
      _desktop(tester);
      final repo = FakeOperationsRepository();
      late ProviderContainer container;
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(repo),
          child: localizedApp(const Scaffold(body: WriteOffScreen())),
        ),
      );
      await tester.pumpAndSettle();
      container = ProviderScope.containerOf(
        tester.element(find.byType(WriteOffScreen)),
      );

      // Seed a draft line directly (the batch picker needs the stock repo).
      container
          .read(writeOffDraftProvider.notifier)
          .addOrUpdate(_line(quantity: 3, onHand: 10));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Сабт кардан'));
      await tester.pumpAndSettle();

      expect(repo.createWriteOffCalls, 1);
      expect(repo.lastBranchId, 'br-1');
      expect(repo.lastReason, WriteOffReason.expired);
      expect(repo.lastWriteOffLines, hasLength(1));
      expect(repo.lastWriteOffLines!.first.batchId, 'b1');
      expect(repo.lastWriteOffLines!.first.quantity, 3);
      // Draft cleared after success.
      expect(container.read(writeOffDraftProvider), isEmpty);
    });

    testWidgets('blocks a qty>onhand draft (no POST)', (tester) async {
      _desktop(tester);
      final repo = FakeOperationsRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(repo),
          child: localizedApp(const Scaffold(body: WriteOffScreen())),
        ),
      );
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(WriteOffScreen)),
      );
      container
          .read(writeOffDraftProvider.notifier)
          .addOrUpdate(_line(onHand: 2, quantity: 9));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Сабт кардан'));
      await tester.pumpAndSettle();

      expect(repo.createWriteOffCalls, 0);
    });
  });

  group('Inventory screen', () {
    testWidgets('posts {branchId, countedQuantity} and shows discrepancies',
        (tester) async {
      _desktop(tester);
      final repo = FakeOperationsRepository(
        inventoryResult: const Success(
          InventoryResult(
            id: 'inv-1',
            discrepancies: [
              InventoryDiscrepancy(
                batchId: 'b1',
                productName: 'Парацетамол',
                expected: 10,
                counted: 8,
                difference: -2,
              ),
            ],
          ),
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(repo),
          child: localizedApp(const Scaffold(body: InventoryScreen())),
        ),
      );
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(InventoryScreen)),
      );
      container
          .read(inventoryDraftProvider.notifier)
          .addOrUpdate(_line(onHand: 10, quantity: 8));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Сабт кардан'));
      await tester.pumpAndSettle();

      expect(repo.createInventoryCalls, 1);
      expect(repo.lastInventoryLines!.first.countedQuantity, 8);
      // Discrepancy dialog rendered.
      expect(find.text('Фарқиятҳои инвентаризатсия'), findsOneWidget);
    });
  });

  group('Supplier-return screen', () {
    testWidgets('requires a supplier before posting', (tester) async {
      _desktop(tester);
      final repo = FakeOperationsRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(repo),
          child:
              localizedApp(const Scaffold(body: SupplierReturnScreen())),
        ),
      );
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(SupplierReturnScreen)),
      );
      container
          .read(supplierReturnDraftProvider.notifier)
          .addOrUpdate(_line(quantity: 1, onHand: 5));
      await tester.pumpAndSettle();

      // No supplier chosen yet → submit blocked.
      await tester.tap(find.widgetWithText(FilledButton, 'Сабт кардан'));
      await tester.pumpAndSettle();
      expect(repo.createSupplierReturnCalls, 0);
    });
  });
}

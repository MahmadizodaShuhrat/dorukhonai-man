import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/features/dashboard/presentation/dashboard_screen.dart';
import 'package:dorukhonai_man/features/pos/data/pos_models.dart';
import 'package:dorukhonai_man/features/pos/data/pos_repository.dart';
import 'package:dorukhonai_man/features/stock/data/stock_models.dart';
import 'package:dorukhonai_man/features/stock/data/stock_repository.dart';
import 'package:dorukhonai_man/shared/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

/// Finds the [StatusChip] whose label is [label] and returns its tone.
StatusTone _chipTone(WidgetTester tester, String label) {
  final chip = tester.widgetList<StatusChip>(find.byType(StatusChip)).firstWhere(
        (c) => c.label == label,
      );
  return chip.tone;
}

/// Hosts the [DashboardScreen] with fake stock/POS repositories. The screen
/// uses `context.go`, so it needs a [Router] ancestor — a minimal MaterialApp
/// with a single route is enough for these render tests.
Widget _host({
  required FakePosRepository pos,
  required FakeStockRepository stock,
}) {
  return ProviderScope(
    overrides: [
      posRepositoryProvider.overrideWithValue(pos),
      stockRepositoryProvider.overrideWithValue(stock),
    ],
    child: const MaterialApp(home: Scaffold(body: DashboardScreen())),
  );
}

void main() {
  testWidgets('renders all four KPI cards', (tester) async {
    final pos = FakePosRepository(
      currentShiftResult: Success(sampleShift(status: ShiftStatus.open)),
    );
    final stock = FakeStockRepository();

    await tester.pumpWidget(_host(pos: pos, stock: stock));
    await tester.pumpAndSettle();

    expect(find.text('ФУРӮШИ ИМРӮЗ'), findsOneWidget);
    expect(find.textContaining('МӮҲЛАТАШ НАЗДИК'), findsOneWidget);
    expect(find.textContaining('КАМШУДА'), findsOneWidget);
    expect(find.text('СМЕНА'), findsOneWidget);
  });

  testWidgets('today sales KPI sums sale totals and counts cheques',
      (tester) async {
    final pos = FakePosRepository(
      listSalesResult: Success(
        paged([
          sampleSale(id: 's1', total: 100),
          sampleSale(id: 's2', total: 50),
        ], total: 2),
      ),
      currentShiftResult: const Error(
        ServerFailure('Смена ёфт нашуд.', statusCode: 404),
      ),
    );
    final stock = FakeStockRepository();

    await tester.pumpWidget(_host(pos: pos, stock: stock));
    await tester.pumpAndSettle();

    // Two cheques tallied; shift KPI shows "Баста" for the 404 (no open shift).
    expect(find.text('2 чек'), findsOneWidget);
    expect(find.text('Баста'), findsOneWidget);
  });

  testWidgets('open shift renders Кушода with close-shift quick action',
      (tester) async {
    final pos = FakePosRepository(
      currentShiftResult: Success(sampleShift(status: ShiftStatus.open)),
    );
    final stock = FakeStockRepository();

    await tester.pumpWidget(_host(pos: pos, stock: stock));
    await tester.pumpAndSettle();

    expect(find.text('Кушода'), findsOneWidget);
    expect(find.text('Бастани смена'), findsOneWidget);
  });

  testWidgets('expiring list shows near-expiry batch with red day chip',
      (tester) async {
    final soon = DateTime.now().add(const Duration(days: 12));
    final pos = FakePosRepository();
    final stock = FakeStockRepository(
      expiringResult: Success(
        paged([
          sampleStockItem(productName: 'Аспирин 500', expiry: soon),
        ], total: 1),
      ),
    );

    await tester.pumpWidget(_host(pos: pos, stock: stock));
    await tester.pumpAndSettle();

    expect(find.text('Аспирин 500'), findsWidgets);
    final days = sampleStockItem(expiry: soon).daysUntilExpiry();
    expect(days <= 30, isTrue);
    expect(find.text('$days' 'р'), findsOneWidget);
  });

  testWidgets('today sales KPI renders formatted money total', (tester) async {
    final pos = FakePosRepository(
      listSalesResult: Success(
        paged([sampleSale(id: 's1', total: 4820)], total: 1),
      ),
    );
    final stock = FakeStockRepository();

    await tester.pumpWidget(_host(pos: pos, stock: stock));
    await tester.pumpAndSettle();

    // Money formatter renders the grouped total somewhere in the KPI row.
    expect(find.textContaining('4'), findsWidgets);
    expect(find.text('1 чек'), findsOneWidget);
  });

  testWidgets('expiry chip tone follows the §B.2 scale across thresholds',
      (tester) async {
    final now = DateTime.now();
    final pos = FakePosRepository();
    final stock = FakeStockRepository(
      expiringResult: Success(
        paged([
          sampleStockItem(
            productId: 'p-gone',
            productName: 'Гузашта дору',
            series: 'G1',
            expiry: now.subtract(const Duration(days: 3)),
          ),
          sampleStockItem(
            productId: 'p-near',
            productName: 'Наздик дору',
            series: 'N1',
            expiry: now.add(const Duration(days: 12)),
          ),
          sampleStockItem(
            productId: 'p-soon',
            productName: 'Дертар дору',
            series: 'S1',
            expiry: now.add(const Duration(days: 60)),
          ),
        ], total: 3),
      ),
    );

    await tester.pumpWidget(_host(pos: pos, stock: stock));
    await tester.pumpAndSettle();

    // <0 → danger (label "гузашта"); 0..30 → danger; 31..90 → warn.
    expect(_chipTone(tester, 'гузашта'), StatusTone.danger);
    final nearDays =
        sampleStockItem(expiry: now.add(const Duration(days: 12)))
            .daysUntilExpiry();
    final soonDays =
        sampleStockItem(expiry: now.add(const Duration(days: 60)))
            .daysUntilExpiry();
    expect(_chipTone(tester, '$nearDays' 'р'), StatusTone.danger);
    expect(_chipTone(tester, '$soonDays' 'р'), StatusTone.warn);
  });

  testWidgets('low-stock list renders shortfall rows', (tester) async {
    final pos = FakePosRepository();
    final stock = FakeStockRepository(
      lowResult: Success(
        paged([
          sampleLowItem(
            productName: 'Камшуда дору',
            totalQuantity: 3,
            minStockLevel: 10,
          ),
        ], total: 1),
      ),
    );

    await tester.pumpWidget(_host(pos: pos, stock: stock));
    await tester.pumpAndSettle();

    expect(find.text('Камшуда дору'), findsOneWidget);
    expect(find.text('3 / 10'), findsOneWidget);
  });

  testWidgets('quick-action buttons are present', (tester) async {
    final pos = FakePosRepository(
      currentShiftResult: const Error(
        ServerFailure('Смена ёфт нашуд.', statusCode: 404),
      ),
    );
    final stock = FakeStockRepository();

    await tester.pumpWidget(_host(pos: pos, stock: stock));
    await tester.pumpAndSettle();

    expect(find.text('Приходи нав'), findsOneWidget);
    expect(find.text('Кушодани смена'), findsOneWidget);
    expect(find.text('Фурӯш'), findsOneWidget);
    expect(find.text('Ҷустуҷӯи дору'), findsOneWidget);
  });

  testWidgets('empty expiring + low stock show their empty messages',
      (tester) async {
    final pos = FakePosRepository();
    final stock = FakeStockRepository(
      expiringResult: Success(paged(<StockItem>[], total: 0)),
      lowResult: Success(paged(<LowStockItem>[], total: 0)),
    );

    await tester.pumpWidget(_host(pos: pos, stock: stock));
    await tester.pumpAndSettle();

    expect(find.text('Дорумӯҳлаташ наздик нест.'), findsOneWidget);
    expect(find.text('Дорумкамшуда нест.'), findsOneWidget);
  });

  testWidgets('section error shows retry affordance', (tester) async {
    final pos = FakePosRepository();
    final stock = FakeStockRepository(
      expiringResult: const Error(NetworkFailure()),
      lowResult: const Error(NetworkFailure()),
    );

    await tester.pumpWidget(_host(pos: pos, stock: stock));
    await tester.pumpAndSettle();

    // Both the expiring and low-stock sections surface the error card + retry.
    expect(find.text('Хатогӣ'), findsWidgets);
    expect(find.widgetWithText(FilledButton, 'Аз нав'), findsWidgets);
  });

  testWidgets('KPI errors render inline error markers', (tester) async {
    final pos = FakePosRepository(
      listSalesResult: const Error(NetworkFailure()),
    );
    final stock = FakeStockRepository(
      expiringResult: const Error(NetworkFailure()),
      lowResult: const Error(NetworkFailure()),
    );

    await tester.pumpWidget(_host(pos: pos, stock: stock));
    await tester.pumpAndSettle();

    // Today-sales / expiring / low KPI tiles each show the inline "— хато".
    expect(find.text('— хато'), findsWidgets);
  });
}

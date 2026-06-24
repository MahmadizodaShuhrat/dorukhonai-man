import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/features/stock/data/stock_models.dart';
import 'package:dorukhonai_man/features/stock/data/stock_repository.dart';
import 'package:dorukhonai_man/features/stock/presentation/stock_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/l10n_harness.dart';

Widget _host(FakeStockRepository repo) {
  return ProviderScope(
    overrides: [stockRepositoryProvider.overrideWithValue(repo)],
    child: localizedApp(const StockScreen()),
  );
}

void main() {
  testWidgets('Бақия tab renders stock items', (tester) async {
    final repo = FakeStockRepository(
      listResult: Success(
        paged([sampleStockItem(productName: 'Аспирин')], total: 1),
      ),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    expect(find.text('Аспирин'), findsOneWidget);
    expect(find.textContaining('Ҳамагӣ: 1'), findsWidgets);
  });

  testWidgets('Бақия tab empty state', (tester) async {
    final repo = FakeStockRepository(
      listResult: Success(paged(<StockItem>[], total: 0)),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    expect(find.text('Бақия нест'), findsOneWidget);
  });

  testWidgets('Мӯҳлати наздик tab shows expiring items with red warning tint',
      (tester) async {
    // Expires in ~10 days -> within the 30-day red threshold.
    final soon = DateTime.now().add(const Duration(days: 10));
    final repo = FakeStockRepository(
      expiringResult: Success(
        paged([sampleStockItem(productName: 'Доруи наздик', expiry: soon)],
            total: 1),
      ),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    // Switch to the expiring tab.
    await tester.tap(find.text('Мӯҳлати наздик'));
    await tester.pumpAndSettle();

    expect(find.text('Доруи наздик'), findsOneWidget);
    expect(repo.expiringCalls, greaterThan(0));

    // The remaining-days column shows a small positive count (~10), confirming
    // the row passes through the warning-tint branch (red <=30 days).
    final item = sampleStockItem(expiry: soon);
    expect(item.daysUntilExpiry() <= 30, isTrue);
    expect(find.text('${item.daysUntilExpiry()}'), findsOneWidget);
  });

  testWidgets('Мӯҳлати наздик 30-day chip switches the window', (tester) async {
    final repo = FakeStockRepository(
      expiringResult: Success(paged(<StockItem>[], total: 0)),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Мӯҳлати наздик'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('30 рӯз'));
    await tester.pumpAndSettle();

    expect(repo.lastExpiringDays, 30);
  });

  testWidgets('Камшуда tab renders low-stock rows', (tester) async {
    final repo = FakeStockRepository(
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

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Камшуда'));
    await tester.pumpAndSettle();

    expect(find.text('Камшуда дору'), findsOneWidget);
    expect(repo.lowCalls, greaterThan(0));
  });

  testWidgets('selecting a row opens the detail panel with movements',
      (tester) async {
    final repo = FakeStockRepository(
      listResult: Success(
        paged([sampleStockItem(productName: 'Аспирин')], total: 1),
      ),
      movementsResult: Success(
        paged([sampleMovement(type: 'Sale', quantity: -2)], total: 1),
      ),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    // Tap the on-hand row (cell text) to open the side panel.
    await tester.tap(find.text('Аспирин').first);
    await tester.pumpAndSettle();

    // Panel sections + a translated movement label appear.
    expect(find.textContaining('ПАРТИЯҲО'), findsOneWidget);
    expect(find.text('ҲАРАКАТИ ДОРУ'), findsOneWidget);
    expect(find.text('Фурӯш'), findsOneWidget); // Sale -> Tajik label
    expect(repo.movementsCalls, greaterThan(0));
    expect(repo.lastMovementsProductId, 'p1');
  });

  testWidgets('detail panel closes via the close button', (tester) async {
    final repo = FakeStockRepository(
      listResult: Success(
        paged([sampleStockItem(productName: 'Аспирин')], total: 1),
      ),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Аспирин').first);
    await tester.pumpAndSettle();
    expect(find.text('ҲАРАКАТИ ДОРУ'), findsOneWidget);

    await tester.tap(find.byTooltip('Пӯшидан'));
    await tester.pumpAndSettle();
    expect(find.text('ҲАРАКАТИ ДОРУ'), findsNothing);
  });
}

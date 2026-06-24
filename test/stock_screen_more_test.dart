import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/features/stock/data/stock_models.dart';
import 'package:dorukhonai_man/features/stock/data/stock_repository.dart';
import 'package:dorukhonai_man/features/stock/presentation/stock_detail_panel.dart';
import 'package:dorukhonai_man/features/stock/presentation/stock_screen.dart';
import 'package:dorukhonai_man/l10n/app_localizations.dart';
import 'package:dorukhonai_man/shared/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'stock_support.dart';
import 'support/l10n_harness.dart';

/// Synchronous Tajik localizations for unit-testing context-free helpers.
final AppLocalizations _l = lookupAppLocalizations(const Locale('tg'));

Widget _host(FakeStockRepository repo) {
  return ProviderScope(
    overrides: [stockRepositoryProvider.overrideWithValue(repo)],
    child: localizedApp(const StockScreen()),
  );
}

void main() {
  group('expiry tone scale (TZ_03 §B.2)', () {
    test('expired (<0) and <=30 days are danger and tinted', () {
      expect(expiryTone(-1), (StatusTone.danger, true));
      expect(expiryTone(0), (StatusTone.danger, true));
      expect(expiryTone(30), (StatusTone.danger, true));
    });

    test('31..90 days is warn and tinted', () {
      expect(expiryTone(31), (StatusTone.warn, true));
      expect(expiryTone(90), (StatusTone.warn, true));
    });

    test('>90 days is ok and NOT tinted', () {
      expect(expiryTone(91), (StatusTone.ok, false));
      expect(expiryTone(400), (StatusTone.ok, false));
    });

    test('expired rows label as Гузашта', () {
      expect(expiryLabel(_l, -3), 'Гузашта');
      expect(expiryLabel(_l, 12), '12 р');
    });
  });

  testWidgets('Бақия error state shows retry', (tester) async {
    final repo = FakeStockRepository(listResult: const Error(kTestFailure));

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    expect(find.text('Хатогӣ'), findsOneWidget);
    expect(find.text('Аз нав'), findsWidgets);
  });

  testWidgets('Мӯҳлати наздик warn-tints a 90-day item (warn chip)',
      (tester) async {
    final repo = FakeStockRepository(
      expiringResult: Success(
        paged([expiringStockItem(productName: 'Зард дору', daysFromNow: 75)],
            total: 1),
      ),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Мӯҳлати наздик'));
    await tester.pumpAndSettle();

    expect(find.text('Зард дору'), findsOneWidget);
    // 75 days -> warn tone, tinted (31..90 band).
    final tone = expiryTone(
      expiringStockItem(daysFromNow: 75).daysUntilExpiry(),
    );
    expect(tone, (StatusTone.warn, true));
  });

  testWidgets('Мӯҳлати наздик error state', (tester) async {
    final repo = FakeStockRepository(expiringResult: const Error(kTestFailure));

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Мӯҳлати наздик'));
    await tester.pumpAndSettle();

    expect(find.text('Хатогӣ'), findsOneWidget);
  });

  testWidgets('Камшуда renders shortfall bar + signed deficit', (tester) async {
    final repo = FakeStockRepository(
      lowResult: Success(
        paged([
          sampleLowItem(
            productName: 'Кам дору',
            totalQuantity: 2,
            minStockLevel: 10,
          ),
        ], total: 1),
      ),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Камшуда'));
    await tester.pumpAndSettle();

    expect(find.text('Кам дору'), findsOneWidget);
    // shortfall = 10 - 2 = 8, rendered signed-negative.
    expect(find.text('−8'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('Камшуда empty state', (tester) async {
    final repo = FakeStockRepository(
      lowResult: Success(paged(<LowStockItem>[], total: 0)),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Камшуда'));
    await tester.pumpAndSettle();

    expect(find.text('Доруи камшуда нест'), findsOneWidget);
  });

  testWidgets('detail panel shows movements error with retry', (tester) async {
    final repo = FakeStockRepository(
      listResult: Success(
        paged([sampleStockItem(productName: 'Аспирин')], total: 1),
      ),
      movementsResult: const Error(kTestFailure),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Аспирин').first);
    await tester.pumpAndSettle();

    expect(find.text('ҲАРАКАТИ ДОРУ'), findsOneWidget);
    // Failure.message surfaces inside the ledger section.
    expect(find.text('Хатои сервер (500).'), findsOneWidget);
  });

  testWidgets('detail panel shows empty ledger message', (tester) async {
    final repo = FakeStockRepository(
      listResult: Success(
        paged([sampleStockItem(productName: 'Аспирин')], total: 1),
      ),
      movementsResult: Success(paged(<StockMovement>[], total: 0)),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Аспирин').first);
    await tester.pumpAndSettle();

    expect(find.text('Ҳаракат нест'), findsOneWidget);
  });

  testWidgets('movement labels: inbound +, sale -, writeoff translated',
      (tester) async {
    final repo = FakeStockRepository(
      listResult: Success(
        paged([sampleStockItem(productName: 'Аспирин')], total: 1),
      ),
      movementsResult: Success(
        paged([
          sampleMovement(id: 'm1', type: 'Receipt', quantity: 50),
          sampleMovement(id: 'm2', type: 'WriteOff', quantity: -5),
        ], total: 2),
      ),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Аспирин').first);
    await tester.pumpAndSettle();

    expect(find.text('Приход'), findsOneWidget);
    expect(find.text('Списание'), findsOneWidget);
    expect(find.text('+50'), findsOneWidget);
    // Movement quantities use a plain ASCII minus (via formatQuantity).
    expect(find.text('-5'), findsOneWidget);
  });

  test('movementTypeLabel maps all known wire values', () {
    expect(movementTypeLabel(_l, 'Sale'), 'Фурӯш');
    expect(movementTypeLabel(_l, 'Return'), 'Бозгашт');
    expect(movementTypeLabel(_l, 'Adjustment'), 'Тасҳеҳ');
    expect(movementTypeLabel(_l, 'Transfer'), 'Интиқол');
    expect(movementTypeLabel(_l, 'Unknown'), 'Unknown');
  });
}

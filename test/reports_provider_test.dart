import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/features/pos/data/pos_models.dart';
import 'package:dorukhonai_man/features/reports/data/report_models.dart';
import 'package:dorukhonai_man/features/reports/data/reports_repository.dart';
import 'package:dorukhonai_man/features/reports/presentation/reports_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'reports_settings_support.dart';

void main() {
  ProviderContainer makeContainer(FakeReportsRepository repo) {
    final container = ProviderContainer(
      overrides: [reportsRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('ReportsFilterController', () {
    test('defaults to sales + 7-day window + groupBy day', () {
      final container = makeContainer(FakeReportsRepository());
      final filter = container.read(reportsFilterProvider);
      expect(filter.kind, ReportKind.sales);
      expect(filter.groupBy, SalesGroupBy.day);
      expect(filter.range.to.difference(filter.range.from).inDays, 6);
    });

    test('setKind / setGroupBy / setShiftId mutate state', () {
      final container = makeContainer(FakeReportsRepository());
      final c = container.read(reportsFilterProvider.notifier);
      c.setKind(ReportKind.profit);
      c.setGroupBy(SalesGroupBy.product);
      c.setShiftId('shift-9');
      final f = container.read(reportsFilterProvider);
      expect(f.kind, ReportKind.profit);
      expect(f.groupBy, SalesGroupBy.product);
      expect(f.shiftId, 'shift-9');
    });

    test('setShiftId with empty clears it', () {
      final container = makeContainer(FakeReportsRepository());
      final c = container.read(reportsFilterProvider.notifier);
      c.setShiftId('x');
      c.setShiftId('');
      expect(container.read(reportsFilterProvider).shiftId, isNull);
    });
  });

  group('salesReportProvider', () {
    test('returns rows and forwards groupBy to the repo', () async {
      final repo = FakeReportsRepository(
        salesResult: Success([sampleSalesRow()]),
      );
      final container = makeContainer(repo);
      container.read(reportsFilterProvider.notifier).setGroupBy(
            SalesGroupBy.seller,
          );

      final rows = await container.read(salesReportProvider.future);

      expect(rows, hasLength(1));
      expect(repo.lastGroupBy, SalesGroupBy.seller);
    });

    test('throws the Failure on error', () async {
      final repo = FakeReportsRepository(
        salesResult: const Error(ServerFailure('boom', statusCode: 500)),
      );
      final container = makeContainer(repo);
      await expectLater(
        container.read(salesReportProvider.future),
        throwsA(isA<ServerFailure>()),
      );
    });
  });

  group('profitReportProvider', () {
    test('returns the aggregate', () async {
      final repo = FakeReportsRepository(
        profitResult: const Success(
          ProfitReport(revenue: 100, cost: 60, profit: 40, margin: 0.4),
        ),
      );
      final container = makeContainer(repo);
      final p = await container.read(profitReportProvider.future);
      expect(p.profit, 40);
    });
  });

  group('zReportProvider', () {
    test('is null until a shift id is set', () async {
      final repo = FakeReportsRepository(
        zReportResult: Success(_sampleZ()),
      );
      final container = makeContainer(repo);
      expect(await container.read(zReportProvider.future), isNull);
      expect(repo.zReportCalls, 0);
    });

    test('fetches once a shift id is set', () async {
      final repo = FakeReportsRepository(
        zReportResult: Success(_sampleZ()),
      );
      final container = makeContainer(repo);
      container.read(reportsFilterProvider.notifier).setShiftId('shift-1');

      final z = await container.read(zReportProvider.future);

      expect(z, isNotNull);
      expect(repo.lastShiftId, 'shift-1');
    });
  });
}

ZReport _sampleZ() => ZReport(
  shiftId: 'shift-1',
  branchId: 'br-1',
  openedAt: DateTime(2026, 6, 20, 9),
  closedAt: DateTime(2026, 6, 20, 18),
  openingCash: 100,
  closingCash: 540,
  salesCount: 12,
  totalSales: 500,
  totalReturns: 20,
  netTotal: 480,
  byMethod: const {
    PaymentMethod.cash: 300,
    PaymentMethod.card: 180,
    PaymentMethod.credit: 0,
  },
  expectedCash: 400,
);

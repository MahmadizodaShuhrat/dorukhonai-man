import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/features/reports/data/reports_repository.dart';
import 'package:dorukhonai_man/features/reports/presentation/reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'reports_settings_support.dart';
import 'support/l10n_harness.dart';

Widget _host(FakeReportsRepository repo) {
  return ProviderScope(
    overrides: [reportsRepositoryProvider.overrideWithValue(repo)],
    child: localizedApp(const Scaffold(body: ReportsScreen())),
  );
}

void main() {
  void desktopWindow(WidgetTester tester) {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('renders the report rail and sales table', (tester) async {
    desktopWindow(tester);
    final repo = FakeReportsRepository(
      salesResult: Success([sampleSalesRow(label: '2026-06-20')]),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    // Rail entries (TZ_03 §C.6).
    expect(find.text('Фурӯш'), findsWidgets);
    expect(find.text('Фоида'), findsOneWidget);
    expect(find.text('Арзиши анбор'), findsOneWidget);
    expect(find.text('Мӯҳлаташ наздик'), findsOneWidget);
    expect(find.text('Z-ҳисобот'), findsOneWidget);

    // Sales row rendered.
    expect(find.text('2026-06-20'), findsWidgets);
    expect(repo.salesCalls, greaterThan(0));
  });

  testWidgets('switching to Фоида loads the profit view', (tester) async {
    desktopWindow(tester);
    final repo = FakeReportsRepository();

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Фоида'));
    await tester.pumpAndSettle();

    expect(find.text('Даромад'), findsOneWidget);
    expect(find.text('Маржа'), findsOneWidget);
    expect(repo.profitCalls, greaterThan(0));
  });

  testWidgets('Z-ҳисобот prompts for a shift id', (tester) async {
    desktopWindow(tester);
    final repo = FakeReportsRepository();

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Z-ҳисобот'));
    await tester.pumpAndSettle();

    expect(find.text('ID-и смена ворид кунед.'), findsOneWidget);
    expect(repo.zReportCalls, 0);
  });
}

import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/features/receipts/data/receipt_models.dart';
import 'package:dorukhonai_man/features/receipts/data/receipts_repository.dart';
import 'package:dorukhonai_man/features/receipts/presentation/receipts_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

Widget _host(FakeReceiptsRepository repo) {
  return ProviderScope(
    overrides: [receiptsRepositoryProvider.overrideWithValue(repo)],
    child: const MaterialApp(home: ReceiptsListScreen()),
  );
}

void main() {
  testWidgets('renders receipt rows from a Paged result', (tester) async {
    final repo = FakeReceiptsRepository(
      listResult: Success(
        paged(
          [
            sampleReceipt(id: 'r1', number: 'PR-001', total: 30),
            sampleReceipt(id: 'r2', number: 'PR-002', total: 50),
          ],
          total: 2,
        ),
      ),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    expect(find.text('PR-001'), findsOneWidget);
    expect(find.text('PR-002'), findsOneWidget);
    expect(find.textContaining('Ҳамагӣ: 2'), findsOneWidget);
  });

  testWidgets('empty result shows the empty state', (tester) async {
    final repo = FakeReceiptsRepository(
      listResult: Success(paged(<Receipt>[], total: 0)),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    expect(find.text('Приход ёфт нашуд'), findsOneWidget);
  });

  testWidgets('failure shows an error message and retry', (tester) async {
    final repo = FakeReceiptsRepository(
      listResult: const Error(NetworkFailure()),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    expect(find.text('Хатои шабака. Пайвастро санҷед.'), findsOneWidget);
    expect(find.text('Аз нав кӯшиш кунед'), findsOneWidget);
  });

  testWidgets('tapping the Posted status chip filters via the repository',
      (tester) async {
    final repo = FakeReceiptsRepository(
      listResult: Success(paged([sampleReceipt()], total: 1)),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    // 'Тасдиқшуда' is the Tajik label for the Posted status chip.
    await tester.tap(find.text('Тасдиқшуда'));
    await tester.pumpAndSettle();

    expect(repo.lastStatusFilter, ReceiptStatus.posted);
  });
}

import 'package:dorukhonai_man/features/products/data/products_repository.dart';
import 'package:dorukhonai_man/features/products/presentation/product_form_screen.dart';
import 'package:dorukhonai_man/features/reference/data/reference_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

Widget _host(FakeProductsRepository repo) {
  return ProviderScope(
    overrides: [
      productsRepositoryProvider.overrideWithValue(repo),
      // The form's EntityPickers (group/manufacturer/unit) read reference data.
      referenceRepositoryProvider.overrideWithValue(FakeReferenceRepository()),
    ],
    child: const MaterialApp(home: ProductFormScreen()),
  );
}

void main() {
  testWidgets('name-required validation blocks submit', (tester) async {
    final repo = FakeProductsRepository();

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    // Tap "Сохтан" (create) with an empty name (scroll it into view first).
    final submit = find.widgetWithText(FilledButton, 'Сохтан');
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.text('Номи доруро ворид кунед'), findsOneWidget);
    expect(repo.createCalls, 0);
  });

  testWidgets('valid form calls repository.create', (tester) async {
    final repo = FakeProductsRepository();

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Аспирин');
    final submit = find.widgetWithText(FilledButton, 'Сохтан');
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(repo.createCalls, 1);
    expect(repo.lastCreated!.name, 'Аспирин');
  });
}

// EntityPicker (TZ_03 §C.5/P2): shows the selected entity's NAME (not its
// GUID), and selecting an option from the search dialog yields its id via
// onChanged.

import 'package:dorukhonai_man/features/products/data/product_models.dart';
import 'package:dorukhonai_man/features/reference/data/reference_repository.dart';
import 'package:dorukhonai_man/features/reference/presentation/reference_providers.dart';
import 'package:dorukhonai_man/shared/entity_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

const _groups = [
  DrugGroup(id: 'g-1', name: 'Анальгетикҳо'),
  DrugGroup(id: 'g-2', name: 'Антибиотикҳо'),
];

Widget _host({String? selectedId, required ValueChanged<String?> onChanged}) {
  return ProviderScope(
    overrides: [
      referenceRepositoryProvider.overrideWithValue(
        FakeReferenceRepository(drugGroupList: _groups),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: EntityPicker(
          label: 'Гурӯҳ',
          optionsProvider: drugGroupOptionsProvider.call,
          selectedId: selectedId,
          onChanged: onChanged,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders the selected entity name, not its id', (tester) async {
    await tester.pumpWidget(_host(selectedId: 'g-2', onChanged: (_) {}));
    await tester.pumpAndSettle();

    expect(find.text('Антибиотикҳо'), findsOneWidget);
    expect(find.text('g-2'), findsNothing);
  });

  testWidgets('picking an option yields its id', (tester) async {
    String? picked;
    // Stateful host so the chosen id flows back into selectedId (as a real
    // form does), letting the field re-render with the picked name.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          referenceRepositoryProvider.overrideWithValue(
            FakeReferenceRepository(drugGroupList: _groups),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => EntityPicker(
                label: 'Гурӯҳ',
                optionsProvider: drugGroupOptionsProvider.call,
                selectedId: picked,
                onChanged: (id) => setState(() => picked = id),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open the search dialog.
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    // Choose the first option from the list.
    await tester.tap(find.text('Анальгетикҳо').last);
    await tester.pumpAndSettle();

    expect(picked, 'g-1');
    // The field now displays the chosen name.
    expect(find.text('Анальгетикҳо'), findsOneWidget);
  });
}

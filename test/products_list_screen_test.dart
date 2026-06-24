import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/features/products/data/product_models.dart';
import 'package:dorukhonai_man/features/products/data/products_repository.dart';
import 'package:dorukhonai_man/features/products/presentation/products_list_screen.dart';
import 'package:dorukhonai_man/features/reference/data/reference_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/l10n_harness.dart';

Widget _host(FakeProductsRepository repo, {FakeReferenceRepository? refRepo}) {
  return ProviderScope(
    overrides: [
      productsRepositoryProvider.overrideWithValue(repo),
      // The reworked screen resolves group/unit NAMES via the reference repo.
      referenceRepositoryProvider.overrideWithValue(
        refRepo ?? FakeReferenceRepository(),
      ),
    ],
    // AppScaffold renders inside the shell (a Column), so host it in a Scaffold.
    child: localizedApp(const Scaffold(body: ProductsListScreen())),
  );
}

void main() {
  // Products is a desktop master-detail page; use a realistic window so the
  // header + table + 380px side panel lay out without overflowing.
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher
        .views
        .first;
    view.physicalSize = const Size(1440, 900);
    view.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher
        .views
        .first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('renders product rows with resolved group/unit names',
      (tester) async {
    final repo = FakeProductsRepository(
      listResult: Success(
        pagedProducts(
          const [
            Product(
              id: '1',
              name: 'Аспирин',
              barcode: '4870',
              drugGroupId: 'g1',
              unitId: 'u1',
            ),
            Product(id: '2', name: 'Парацетамол'),
          ],
          total: 2,
        ),
      ),
    );
    final refRepo = FakeReferenceRepository(
      drugGroupList: const [DrugGroup(id: 'g1', name: 'Анальгетикҳо')],
      unitList: const [Unit(id: 'u1', name: 'дона')],
    );

    await tester.pumpWidget(_host(repo, refRepo: refRepo));
    await tester.pumpAndSettle();

    expect(find.text('Аспирин'), findsOneWidget);
    expect(find.text('Парацетамол'), findsOneWidget);
    // FK shown as a NAME, never a GUID (TZ_03 §C.5).
    expect(find.text('Анальгетикҳо'), findsOneWidget);
    expect(find.text('дона'), findsOneWidget);
    // Total surfaced in header subtitle + pagination bar.
    expect(find.textContaining('Ҳамагӣ: 2'), findsWidgets);
  });

  testWidgets('empty result shows the empty state', (tester) async {
    final repo = FakeProductsRepository(
      listResult: Success(pagedProducts([], total: 0)),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    expect(find.text('Дору ёфт нашуд'), findsOneWidget);
  });

  testWidgets('failure shows an error message and retry', (tester) async {
    final repo = FakeProductsRepository(
      listResult: const Error(NetworkFailure()),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    expect(find.text('Хатои шабака. Пайвастро санҷед.'), findsOneWidget);
    // AppDataTable's built-in retry button.
    expect(find.text('Аз нав'), findsOneWidget);
  });

  testWidgets('"+ Дору нав" opens the side-panel editor and creates',
      (tester) async {
    final repo = FakeProductsRepository();
    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Дору нав'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Сохтан'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Ибупрофен');
    await tester.tap(find.widgetWithText(FilledButton, 'Сохтан'));
    await tester.pumpAndSettle();

    expect(repo.createCalls, 1);
    expect(repo.lastCreated!.name, 'Ибупрофен');
  });

  testWidgets('typing in the search field forwards the term to the repository '
      '(debounced)', (tester) async {
    final repo = FakeProductsRepository(
      listResult: Success(pagedProducts([], total: 0)),
    );
    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'аспир');
    // Debounce is 350ms; let it elapse + the refresh complete.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(repo.lastSearch, 'аспир');
  });

  testWidgets('editor shows FK group as a NAME (never a GUID) and saves with '
      'the contract body', (tester) async {
    final repo = FakeProductsRepository(
      listResult: Success(
        pagedProducts(
          const [
            Product(
              id: '1',
              name: 'Аспирин',
              drugGroupId: 'g1',
              unitId: 'u1',
              rxRequired: true,
              minStockLevel: 10,
            ),
          ],
          total: 1,
        ),
      ),
    );
    final refRepo = FakeReferenceRepository(
      drugGroupList: const [DrugGroup(id: 'g1', name: 'Анальгетикҳо')],
      unitList: const [Unit(id: 'u1', name: 'дона')],
    );

    await tester.pumpWidget(_host(repo, refRepo: refRepo));
    await tester.pumpAndSettle();

    // Open the row in edit mode.
    await tester.tap(find.text('Аспирин'));
    await tester.pumpAndSettle();

    // The EntityPicker resolves the GUID 'g1' to its name in the editor.
    // (Both the table cell and the picker show the name → at least 2 instances,
    // and crucially the raw GUID is nowhere on screen.)
    expect(find.text('Анальгетикҳо'), findsWidgets);
    expect(find.text('g1'), findsNothing);
    expect(find.text('u1'), findsNothing);

    // Save → update is called with the FK ids preserved (contract body).
    await tester.tap(find.widgetWithText(FilledButton, 'Нигоҳ доштан'));
    await tester.pumpAndSettle();

    expect(repo.updateCalls, 1);
    final sent = repo.lastUpdated!;
    expect(sent.id, '1');
    expect(sent.name, 'Аспирин');
    expect(sent.drugGroupId, 'g1');
    expect(sent.unitId, 'u1');
    expect(sent.rxRequired, isTrue);
    expect(sent.minStockLevel, 10);
    // toJson uses exact contract field names.
    final json = sent.toJson();
    expect(json.containsKey('drugGroupId'), isTrue);
    expect(json.containsKey('manufacturerId'), isTrue);
    expect(json.containsKey('unitId'), isTrue);
    expect(json.containsKey('rxRequired'), isTrue);
    expect(json.containsKey('isActive'), isTrue);
    expect(json.containsKey('minStockLevel'), isTrue);
  });

  testWidgets('create surfaces a failure as an error toast (no panel close)',
      (tester) async {
    final repo = FakeProductsRepository(
      createResult: const Error(ServerFailure('Ин ном аллакай мавҷуд аст.')),
    );
    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Дору нав'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Такрорӣ');
    await tester.tap(find.widgetWithText(FilledButton, 'Сохтан'));
    await tester.pumpAndSettle();

    expect(repo.createCalls, 1);
    expect(find.text('Ин ном аллакай мавҷуд аст.'), findsOneWidget);
    // Panel stays open on failure (Save button still present).
    expect(find.widgetWithText(FilledButton, 'Сохтан'), findsOneWidget);
  });
}

import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/core/api/paged.dart';
import 'package:dorukhonai_man/features/products/data/product_models.dart';
import 'package:dorukhonai_man/features/reference/data/reference_crud_repository.dart';
import 'package:dorukhonai_man/features/reference/data/reference_repository.dart';
import 'package:dorukhonai_man/features/reference/presentation/drug_groups_screen.dart';
import 'package:dorukhonai_man/features/reference/presentation/manufacturers_screen.dart';
import 'package:dorukhonai_man/features/reference/presentation/units_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'reference_support.dart';
import 'support/fakes.dart';
import 'support/l10n_harness.dart';

/// A read-repo whose `manufacturers` query fails, to exercise the error state.
class _FailingReferenceRepository extends FakeReferenceRepository {
  @override
  Future<ApiResult<Paged<Manufacturer>>> manufacturers({
    String? search,
    int page = 1,
    int size = 50,
  }) async => const Error(NetworkFailure());
}

Widget _host({
  required Widget screen,
  required FakeReferenceRepository read,
  required FakeReferenceCrudRepository crud,
}) {
  return ProviderScope(
    overrides: [
      referenceRepositoryProvider.overrideWithValue(read),
      referenceCrudRepositoryProvider.overrideWithValue(crud),
    ],
    // A Material host so AppScaffold/AppDataTable/SidePanel render.
    child: localizedApp(Scaffold(body: screen)),
  );
}

void main() {
  // Reference screens are desktop pages; use a realistic window so the
  // 64px page header (icon + long title + "+ Нав" button) lays out without
  // overflowing the default 800px test surface.
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

  testWidgets('drug-groups list renders rows from the repository',
      (tester) async {
    final read = FakeReferenceRepository(
      drugGroupList: const [
        DrugGroup(id: 'g1', name: 'Анальгетикҳо'),
        DrugGroup(id: 'g2', name: 'Антибиотикҳо'),
      ],
    );
    await tester.pumpWidget(
      _host(
        screen: const DrugGroupsScreen(),
        read: read,
        crud: FakeReferenceCrudRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Анальгетикҳо'), findsOneWidget);
    expect(find.text('Антибиотикҳо'), findsOneWidget);
  });

  testWidgets('"+ Гурӯҳи нав" opens the side panel and creates a group',
      (tester) async {
    final crud = FakeReferenceCrudRepository();
    await tester.pumpWidget(
      _host(
        screen: const DrugGroupsScreen(),
        read: FakeReferenceRepository(),
        crud: crud,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Гурӯҳи нав'));
    await tester.pumpAndSettle();

    // Side panel header is visible.
    expect(find.text('гурӯҳ нав'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Витаминҳо');
    await tester.tap(find.widgetWithText(FilledButton, 'Сохтан'));
    await tester.pumpAndSettle();

    expect(crud.createDrugGroupCalls, 1);
    expect(crud.lastDrugGroup!.name, 'Витаминҳо');
  });

  testWidgets('empty name blocks create', (tester) async {
    final crud = FakeReferenceCrudRepository();
    await tester.pumpWidget(
      _host(
        screen: const UnitsScreen(),
        read: FakeReferenceRepository(),
        crud: crud,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Воҳиди нав'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Сохтан'));
    await tester.pumpAndSettle();

    expect(find.text('Номи воҳидро ворид кунед'), findsOneWidget);
    expect(crud.createUnitCalls, 0);
  });

  testWidgets('row tap opens editor pre-filled and updates', (tester) async {
    final read = FakeReferenceRepository(
      manufacturerList: const [
        Manufacturer(id: 'm1', name: 'Bayer', country: 'Олмон'),
      ],
    );
    final crud = FakeReferenceCrudRepository();
    await tester.pumpWidget(
      _host(
        screen: const ManufacturersScreen(),
        read: read,
        crud: crud,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bayer'));
    await tester.pumpAndSettle();

    // Editor opened in edit mode (Save label = "Нигоҳ доштан").
    final save = find.widgetWithText(FilledButton, 'Нигоҳ доштан');
    expect(save, findsOneWidget);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(crud.updateManufacturerCalls, 1);
    expect(crud.lastManufacturer!.id, 'm1');
  });

  testWidgets('a failed list load shows the error state + retry',
      (tester) async {
    await tester.pumpWidget(
      _host(
        screen: const ManufacturersScreen(),
        read: _FailingReferenceRepository(),
        crud: FakeReferenceCrudRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Хатои шабака. Пайвастро санҷед.'), findsOneWidget);
    expect(find.text('Аз нав'), findsOneWidget);
  });

  testWidgets('editing then deleting confirms and calls delete', (tester) async {
    final read = FakeReferenceRepository(
      manufacturerList: const [Manufacturer(id: 'm9', name: 'Pfizer')],
    );
    final crud = FakeReferenceCrudRepository();
    await tester.pumpWidget(
      _host(screen: const ManufacturersScreen(), read: read, crud: crud),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pfizer'));
    await tester.pumpAndSettle();

    // Open the side-panel delete → confirm dialog → confirm.
    await tester.tap(find.widgetWithText(OutlinedButton, 'Ҳазф'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Ҳазф'));
    await tester.pumpAndSettle();

    expect(crud.deleteManufacturerCalls, 1);
    expect(crud.lastDeletedId, 'm9');
  });
}

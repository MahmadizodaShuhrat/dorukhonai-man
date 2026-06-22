// Desktop shell tests (TZ_03 §A): the fixed sidebar renders every section, the
// top bar shows the branch/shift/online chips + Ctrl+K search + user menu, and
// tapping a sidebar item navigates between routes. Confirms the responsive
// bottom-navigation is gone (no NavigationBar anywhere in the tree).

import 'package:dorukhonai_man/app/app.dart';
import 'package:dorukhonai_man/core/storage/app_preferences.dart';
import 'package:dorukhonai_man/features/auth/data/auth_repository.dart';
import 'package:dorukhonai_man/features/auth/presentation/auth_provider.dart';
import 'package:dorukhonai_man/features/branch/data/branch_repository.dart';
import 'package:dorukhonai_man/features/pos/data/pos_repository.dart';
import 'package:dorukhonai_man/features/products/data/products_repository.dart';
import 'package:dorukhonai_man/features/receipts/data/receipts_repository.dart';
import 'package:dorukhonai_man/features/reference/data/reference_repository.dart';
import 'package:dorukhonai_man/features/stock/data/stock_repository.dart';
import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/core/db/app_database.dart';
import 'package:dorukhonai_man/core/storage/token_storage.dart';
import 'package:dorukhonai_man/features/sync/data/sync_models.dart';
import 'package:dorukhonai_man/features/sync/data/sync_repository.dart';
import 'package:dorukhonai_man/features/sync/presentation/sync_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fakes.dart';

/// Offline sync repo so the shell's connectivity probe resolves deterministically
/// (offline) without hitting a real Dio/server in tests.
class _OfflineSyncRepository implements SyncRepository {
  @override
  Future<bool> ping() async => false;
  @override
  Future<ApiResult<CatalogSyncResponse>> pullCatalog({String? since}) async =>
      const Error(NetworkFailure());
  @override
  Future<ApiResult<List<SalePushResult>>> pushSales(
    List<Map<String, dynamic>> sales,
  ) async => const Error(NetworkFailure());
}

/// Token storage stub that reports a stored session so the router redirect
/// lands inside the authenticated shell.
class _LoggedInTokenStorage implements TokenStorage {
  @override
  Future<String?> readAccessToken() async => 'access-token';
  @override
  Future<String?> readRefreshToken() async => 'refresh-token';
  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {}
  @override
  Future<void> clear() async {}
}

Future<ProviderContainer> _bootAuthenticated(WidgetTester tester) async {
  // Desktop-only layout: give the test a real desktop-sized window (min 1100w)
  // so the fixed shell lays out without horizontal overflow.
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final authRepo = FakeAuthRepository(
    meResult: Success(sampleLoginResponse().user),
  );

  final container = ProviderContainer(
    overrides: [
      appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
      authRepositoryProvider.overrideWithValue(authRepo),
      tokenStorageProvider.overrideWithValue(_LoggedInTokenStorage()),
      // The default landing screens may touch these repos; keep them offline.
      productsRepositoryProvider.overrideWithValue(FakeProductsRepository()),
      receiptsRepositoryProvider.overrideWithValue(FakeReceiptsRepository()),
      stockRepositoryProvider.overrideWithValue(FakeStockRepository()),
      referenceRepositoryProvider.overrideWithValue(FakeReferenceRepository()),
      posRepositoryProvider.overrideWithValue(FakePosRepository()),
      // Real branch chip resolves the central branch name from this fake.
      branchRepositoryProvider.overrideWithValue(FakeBranchRepository()),
      // Offline subsystem: in-memory DB + offline sync repo so the shell's
      // SyncCoordinator/connectivity probe stays deterministic in tests.
      appDatabaseProvider.overrideWith((ref) {
        final db = AppDatabase.memory();
        ref.onDispose(db.close);
        return db;
      }),
      syncRepositoryProvider.overrideWithValue(_OfflineSyncRepository()),
      // No periodic connectivity poll in tests (would leak a Timer); the
      // initial sync still runs once against the offline fake.
      syncCoordinatorProvider.overrideWith(
        (ref) => SyncCoordinator(ref, enablePolling: false),
      ),
    ],
  );
  // Dispose the container at teardown so the connectivity poll Timer is
  // cancelled and the test framework sees no pending timers.
  addTearDown(container.dispose);

  // Rehydrate the session so the redirect resolves to /dashboard (authed).
  await container.read(authControllerProvider.notifier).loadSession();

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('sidebar renders all sections and the top bar', (tester) async {
    await _bootAuthenticated(tester);

    // Every primary + reference section label is present in the sidebar.
    for (final label in const [
      'Дашборд',
      'Касса',
      'Анбор',
      'Приход',
      'Доруҳо',
      'Гурӯҳҳо',
      'Таъминкунандагон',
      'Истеҳсолкунандагон',
      'Воҳидҳо',
      'Ҳисоботҳо',
      'Танзимот',
    ]) {
      expect(find.text(label), findsWidgets, reason: 'missing $label');
    }

    // Reference group header.
    expect(find.text('МАЪЛУМОТНОМАҲО'), findsOneWidget);

    // Top bar chips + command search. Polling is disabled in tests, so the
    // real connectivity indicator shows its initial "Онлайн" state.
    expect(find.text('Дорухонаи марказӣ'), findsOneWidget);
    expect(find.text('Онлайн'), findsOneWidget);
    expect(find.text('Ctrl+K'), findsWidgets);

    // No responsive bottom navigation in the desktop shell.
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(BottomNavigationBar), findsNothing);
  });

  testWidgets('tapping a sidebar item navigates to that section', (
    tester,
  ) async {
    await _bootAuthenticated(tester);

    // Default landing is the dashboard — assert a stable dashboard-content
    // marker (the quick-actions panel title, not present in the sidebar).
    expect(find.text('Амалҳои зуд'), findsOneWidget);

    // Navigate to Анбор (Stock) — its repo is faked above, so it settles.
    await tester.tap(find.text('Анбор'));
    await tester.pumpAndSettle();

    // The dashboard content is gone; we navigated to another section.
    expect(find.text('Амалҳои зуд'), findsNothing);
  });
}

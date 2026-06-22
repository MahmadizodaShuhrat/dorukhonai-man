// Branch resolution (TZ_05 FW1) + Ctrl+K command palette (FW5) tests.

import 'package:dorukhonai_man/app/command_palette.dart';
import 'package:dorukhonai_man/app/router.dart';
import 'package:dorukhonai_man/features/auth/data/auth_models.dart';
import 'package:dorukhonai_man/features/auth/data/auth_repository.dart';
import 'package:dorukhonai_man/features/auth/presentation/auth_provider.dart';
import 'package:dorukhonai_man/features/branch/data/branch_models.dart';
import 'package:dorukhonai_man/features/branch/data/branch_repository.dart';
import 'package:dorukhonai_man/features/branch/presentation/branch_provider.dart';
import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/core/storage/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'support/fakes.dart';

class _NoTokenStorage implements TokenStorage {
  @override
  Future<String?> readAccessToken() async => null;
  @override
  Future<String?> readRefreshToken() async => null;
  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {}
  @override
  Future<void> clear() async {}
}

void main() {
  group('currentBranchProvider', () {
    test('prefers the central branch when the user has no branchId', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          tokenStorageProvider.overrideWithValue(_NoTokenStorage()),
          branchRepositoryProvider.overrideWithValue(
            FakeBranchRepository(
              branches: const [
                Branch(id: 'b-a', name: 'Филиал A'),
                Branch(id: 'b-c', name: 'Марказӣ', isCentral: true),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final branch = await container.read(currentBranchProvider.future);
      expect(branch?.id, 'b-c');
    });

    test('prefers the session user branchId over the central branch', () async {
      final auth = FakeAuthRepository(
        loginResult: const Success(
          LoginResponse(
            token: 'a',
            refreshToken: 'r',
            user: User(
              id: 'u1',
              fullName: 'Корбар',
              userName: 'u',
              role: UserRole.manager,
              branchId: 'b-a',
            ),
          ),
        ),
      );
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          tokenStorageProvider.overrideWithValue(_NoTokenStorage()),
          branchRepositoryProvider.overrideWithValue(
            FakeBranchRepository(
              branches: const [
                Branch(id: 'b-a', name: 'Филиал A'),
                Branch(id: 'b-c', name: 'Марказӣ', isCentral: true),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      // Seed the auth user with a branchId.
      await container.read(authControllerProvider.notifier).login('u', 'pw');

      final branch = await container.read(currentBranchProvider.future);
      expect(branch?.id, 'b-a');
    });
  });

  group('CommandPalette', () {
    testWidgets('searches and navigates on tap', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final router = GoRouter(
        initialLocation: '/start',
        routes: [
          GoRoute(
            path: '/start',
            builder: (context, _) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => CommandPalette.show(context),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.writeOffs,
            builder: (_, _) => const Scaffold(body: Text('WriteOffPage')),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // Palette lists sections; filter to Списание and open it.
      expect(find.text('Дашборд'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Списан');
      await tester.pumpAndSettle();
      expect(find.text('Списание'), findsOneWidget);
      expect(find.text('Дашборд'), findsNothing);

      await tester.tap(find.text('Списание'));
      await tester.pumpAndSettle();
      expect(find.text('WriteOffPage'), findsOneWidget);
    });
  });
}

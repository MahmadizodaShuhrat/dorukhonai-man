import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/core/constants/app_constants.dart';
import 'package:dorukhonai_man/features/auth/data/auth_models.dart';
import 'package:dorukhonai_man/features/auth/data/auth_repository.dart';
import 'package:dorukhonai_man/features/auth/presentation/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, String> secureData;

  setUp(() {
    // Back the real TokenStorage with an in-memory secure-storage platform so
    // the production AuthController/AuthRepository run unmodified, no channel.
    secureData = <String, String>{};
    FlutterSecureStoragePlatform.instance =
        TestFlutterSecureStoragePlatform(secureData);
  });

  /// Builds a container with the fake auth repository injected. The real
  /// TokenStorage (backed by the in-memory platform above) is used as-is.
  ProviderContainer makeContainer(FakeAuthRepository repo) {
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('AuthController.login', () {
    test('success sets user + authenticated and persists tokens', () async {
      final repo = FakeAuthRepository(
        loginResult: Success(sampleLoginResponse()),
      );
      final container = makeContainer(repo);
      final controller = container.read(authControllerProvider.notifier);

      final ok = await controller.login('admin', 'Admin123!');

      expect(ok, isTrue);
      final state = container.read(authControllerProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.user, isNotNull);
      expect(state.user!.userName, 'admin');
      expect(state.user!.role, UserRole.admin);
      expect(state.errorMessage, isNull);
      // Contract field names forwarded to the repository.
      expect(repo.lastUserName, 'admin');
      expect(repo.lastPassword, 'Admin123!');
      // (Token persistence is the repository's job; verified end-to-end in
      // auth_repository_test.dart against a scripted Dio adapter.)
    });

    test('failure sets error state and does NOT authenticate', () async {
      final repo = FakeAuthRepository(
        loginResult: const Error(AuthFailure('Логин ё парол нодуруст аст.')),
      );
      final container = makeContainer(repo);
      final controller = container.read(authControllerProvider.notifier);

      final ok = await controller.login('admin', 'wrong');

      expect(ok, isFalse);
      final state = container.read(authControllerProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.user, isNull);
      expect(state.errorMessage, 'Логин ё парол нодуруст аст.');
      expect(secureData[AppConstants.accessTokenKey], isNull);
    });

    test('network failure surfaces a NetworkFailure message', () async {
      final repo = FakeAuthRepository(
        loginResult: const Error(NetworkFailure()),
      );
      final container = makeContainer(repo);
      final controller = container.read(authControllerProvider.notifier);

      final ok = await controller.login('admin', 'x');

      expect(ok, isFalse);
      final state = container.read(authControllerProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.errorMessage, isNotNull);
    });
  });

  group('AuthController.loadSession', () {
    test('no token leaves session unauthenticated', () async {
      final repo = FakeAuthRepository();
      final container = makeContainer(repo);
      final controller = container.read(authControllerProvider.notifier);

      await controller.loadSession();

      expect(container.read(authControllerProvider).isAuthenticated, isFalse);
      expect(repo.meCalls, 0);
    });

    test('persisted token rehydrates and fetches /auth/me', () async {
      secureData[AppConstants.accessTokenKey] = 'access-123';
      final user = User(
        id: 'u1',
        fullName: 'Админ',
        userName: 'admin',
        role: UserRole.admin,
      );
      final repo = FakeAuthRepository(meResult: Success(user));
      final container = makeContainer(repo);
      final controller = container.read(authControllerProvider.notifier);

      await controller.loadSession();

      final state = container.read(authControllerProvider);
      expect(state.isAuthenticated, isTrue);
      expect(repo.meCalls, 1);
      expect(state.user!.userName, 'admin');
    });
  });

  group('AuthController.logout', () {
    test('resets state and calls repository logout', () async {
      final repo = FakeAuthRepository(
        loginResult: Success(sampleLoginResponse()),
      );
      final container = makeContainer(repo);
      final controller = container.read(authControllerProvider.notifier);
      await controller.login('admin', 'Admin123!');
      expect(container.read(authControllerProvider).isAuthenticated, isTrue);

      await controller.logout();

      final state = container.read(authControllerProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.user, isNull);
      expect(repo.logoutCalls, 1);
    });
  });
}

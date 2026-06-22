import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/core/storage/app_preferences.dart';
import 'package:dorukhonai_man/features/auth/data/auth_models.dart';
import 'package:dorukhonai_man/features/settings/data/settings_repository.dart';
import 'package:dorukhonai_man/features/settings/data/users_repository.dart';
import 'package:dorukhonai_man/features/settings/presentation/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'reports_settings_support.dart';

void main() {
  group('SettingsController', () {
    test('falls back to defaults when prefs not loaded', () {
      // No SharedPreferences override → the async provider stays loading and
      // the controller uses its defaults.
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final settings = container.read(settingsControllerProvider);
      expect(settings.alertDays, 30);
      expect(settings.markupPercent, 0);
    });

    test('setAlertDays / setMarkupPercent update state', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((_) async => prefs),
        ],
      );
      addTearDown(container.dispose);
      // Let the async prefs provider resolve so the controller is built atop
      // the real (mock) prefs and won't be rebuilt mid-test.
      await container.read(sharedPreferencesProvider.future);

      final c = container.read(settingsControllerProvider.notifier);
      await c.setAlertDays(90);
      await c.setMarkupPercent(25);
      final s = container.read(settingsControllerProvider);
      expect(s.alertDays, 90);
      expect(s.markupPercent, 25);
    });

    test('loads authoritative values from the server on init (GET)', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final settingsRepo = FakeSettingsRepository(
        getResult: const Success(
          ServerSettings(markupPercent: 42, expiryAlertDays: 90),
        ),
      );
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((_) async => prefs),
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
        ],
      );
      addTearDown(container.dispose);
      await container.read(sharedPreferencesProvider.future);

      // Build the controller and let the async server load settle.
      container.read(settingsControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      final s = container.read(settingsControllerProvider);
      expect(settingsRepo.getCalls, 1);
      expect(s.markupPercent, 42);
      expect(s.alertDays, 90);
    });

    test('PUTs markup / alert-days to the server on change', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final settingsRepo = FakeSettingsRepository();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((_) async => prefs),
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
        ],
      );
      addTearDown(container.dispose);
      await container.read(sharedPreferencesProvider.future);

      final c = container.read(settingsControllerProvider.notifier);
      await c.setMarkupPercent(33);
      await c.setAlertDays(90);

      expect(settingsRepo.updateCalls, 2);
      expect(settingsRepo.lastMarkup, isNull); // last call set alert-days only
      expect(settingsRepo.lastAlertDays, 90);
    });
  });

  group('usersListProvider', () {
    test('returns the user list', () async {
      final repo = FakeUsersRepository(
        listResult: Success([
          const User(
            id: 'u1',
            fullName: 'Админ',
            userName: 'admin',
            role: UserRole.admin,
          ),
        ]),
      );
      final container = ProviderContainer(
        overrides: [usersRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final users = await container.read(usersListProvider.future);

      expect(users, hasLength(1));
      expect(users.first.role, UserRole.admin);
      expect(repo.listCalls, 1);
    });

    test('throws the Failure on error', () async {
      final repo = FakeUsersRepository(
        listResult: const Error(AuthFailure()),
      );
      final container = ProviderContainer(
        overrides: [usersRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(usersListProvider.future),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('deactivate calls the repo with the user id', () async {
      final repo = FakeUsersRepository();
      final result = await repo.deactivate('u1');
      expect(result, isA<Success<void>>());
      expect(repo.deactivateCalls, 1);
      expect(repo.lastDeactivatedId, 'u1');
    });

    test('create posts the new user fields', () async {
      final repo = FakeUsersRepository();
      await repo.create(
        fullName: 'Нав Корбар',
        userName: 'seller3',
        password: 'pw123456',
        role: UserRole.seller,
      );
      expect(repo.createCalls, 1);
      expect(repo.lastCreatedUserName, 'seller3');
    });
  });
}

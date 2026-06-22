import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/core/config/api_config.dart';
import 'package:dorukhonai_man/core/storage/app_preferences.dart';
import 'package:dorukhonai_man/features/auth/data/auth_models.dart';
import 'package:dorukhonai_man/features/auth/data/auth_repository.dart';
import 'package:dorukhonai_man/features/auth/presentation/auth_provider.dart';
import 'package:dorukhonai_man/features/settings/data/settings_repository.dart';
import 'package:dorukhonai_man/features/settings/data/users_repository.dart';
import 'package:dorukhonai_man/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'reports_settings_support.dart';
import 'support/fakes.dart';

late AppPreferences _prefs;

List<Override> _overrides({
  required FakeAuthRepository auth,
  FakeUsersRepository? users,
}) => [
  appPreferencesProvider.overrideWithValue(_prefs),
  authRepositoryProvider.overrideWithValue(auth),
  usersRepositoryProvider.overrideWithValue(users ?? FakeUsersRepository()),
  settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
];

Widget _host({required FakeAuthRepository auth, FakeUsersRepository? users}) {
  return ProviderScope(
    overrides: _overrides(auth: auth, users: users),
    child: const MaterialApp(home: Scaffold(body: SettingsScreen())),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    _prefs = AppPreferences(await SharedPreferences.getInstance());
  });

  void desktopWindow(WidgetTester tester) {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('renders the core settings sections', (tester) async {
    desktopWindow(tester);
    await tester.pumpWidget(_host(auth: FakeAuthRepository()));
    await tester.pumpAndSettle();

    expect(find.text('СЕРВЕР'), findsOneWidget);
    expect(find.text('ОГОҲӢ'), findsOneWidget);
    expect(find.text('НАРХ'), findsOneWidget);
    expect(find.text('ПРИНТЕР'), findsOneWidget);
    expect(find.text('КОРБАР'), findsOneWidget);
    // Logout action present.
    expect(find.text('Баромадан'), findsOneWidget);
  });

  testWidgets('non-admin does not see the user list section', (tester) async {
    desktopWindow(tester);
    await tester.pumpWidget(_host(auth: FakeAuthRepository()));
    await tester.pumpAndSettle();

    // No user loaded → not admin → Корбарон section hidden.
    expect(find.text('КОРБАРОН'), findsNothing);
  });

  testWidgets('admin sees the Корбарон user list', (tester) async {
    desktopWindow(tester);
    final auth = FakeAuthRepository(
      loginResult: const Success(
        LoginResponse(
          token: 'a',
          refreshToken: 'r',
          user: User(
            id: 'u1',
            fullName: 'Админ Админ',
            userName: 'admin',
            role: UserRole.admin,
          ),
        ),
      ),
    );
    final container = ProviderContainer(
      overrides: _overrides(
        auth: auth,
        users: FakeUsersRepository(
          listResult: Success([
            const User(
              id: 'u2',
              fullName: 'Фурӯшанда Як',
              userName: 'seller1',
              role: UserRole.seller,
            ),
          ]),
        ),
      ),
    );
    addTearDown(container.dispose);
    // Drive auth state to an Admin user (login sets state.user directly).
    await container
        .read(authControllerProvider.notifier)
        .login('admin', 'pw');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: SettingsScreen())),
      ),
    );
    await tester.pumpAndSettle();

    // The Корбарон card is below the fold; scroll it into view.
    await tester.scrollUntilVisible(
      find.text('КОРБАРОН'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('КОРБАРОН'), findsOneWidget);
    expect(find.text('Фурӯшанда Як'), findsOneWidget);
    // CRUD affordances present: create button + per-row edit/deactivate.
    expect(find.text('Корбари нав'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsWidgets);
    expect(find.byIcon(Icons.person_off_outlined), findsWidgets);
  });

  testWidgets('admin can create a user (POST /users)', (tester) async {
    desktopWindow(tester);
    final auth = FakeAuthRepository(
      loginResult: const Success(
        LoginResponse(
          token: 'a',
          refreshToken: 'r',
          user: User(
            id: 'u1',
            fullName: 'Админ Админ',
            userName: 'admin',
            role: UserRole.admin,
          ),
        ),
      ),
    );
    final users = FakeUsersRepository(listResult: const Success([]));
    final container = ProviderContainer(
      overrides: _overrides(auth: auth, users: users),
    );
    addTearDown(container.dispose);
    await container.read(authControllerProvider.notifier).login('admin', 'pw');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: SettingsScreen())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Корбари нав'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Корбари нав'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ному насаб *'),
      'Фурӯшанда Нав',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Номи корбар (login) *'),
      'seller2',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Парол *'),
      'pass1234',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Илова'));
    await tester.pumpAndSettle();

    expect(users.createCalls, 1);
    expect(users.lastCreatedUserName, 'seller2');
  });

  testWidgets('server section reads + writes serverConfigProvider', (
    tester,
  ) async {
    desktopWindow(tester);
    final container = ProviderContainer(
      overrides: _overrides(auth: FakeAuthRepository()),
    );
    addTearDown(container.dispose);

    // Reads the current (default) base URL into the field.
    expect(
      container.read(serverConfigProvider).baseUrl,
      ServerConfig.defaultBaseUrl,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: SettingsScreen())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(ServerConfig.defaultBaseUrl), findsWidgets);

    // Enter a new URL and save → provider + prefs updated.
    final field = find.widgetWithText(
      TextField,
      'Суроғаи сервер (scheme://host:port/api/v1)',
    );
    expect(field, findsOneWidget);
    await tester.enterText(field, 'http://192.168.1.50:5000/api/v1');
    // The server card's Save is the first "Нигоҳ доштан" (markup also has one).
    await tester.tap(find.widgetWithText(FilledButton, 'Нигоҳ доштан').first);
    await tester.pumpAndSettle();

    expect(
      container.read(serverConfigProvider).baseUrl,
      'http://192.168.1.50:5000/api/v1',
    );
    expect(_prefs.serverBaseUrl, 'http://192.168.1.50:5000/api/v1');
  });

  testWidgets('logout clears auth state and calls the repo', (tester) async {
    desktopWindow(tester);
    final auth = FakeAuthRepository(
      loginResult: const Success(
        LoginResponse(
          token: 'a',
          refreshToken: 'r',
          user: User(
            id: 'u1',
            fullName: 'Корбар Як',
            userName: 'user1',
            role: UserRole.seller,
          ),
        ),
      ),
    );
    final container = ProviderContainer(overrides: _overrides(auth: auth));
    addTearDown(container.dispose);
    await container.read(authControllerProvider.notifier).login('user1', 'pw');
    expect(container.read(authControllerProvider).user, isNotNull);

    // Minimal router so the post-logout `context.go('/login')` resolves.
    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (_, _) => const Scaffold(body: SettingsScreen()),
        ),
        GoRoute(
          path: '/login',
          builder: (_, _) => const Scaffold(body: Text('Воридшавӣ')),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // The logout button is below the fold; scroll it into view first.
    final logout = find.widgetWithText(OutlinedButton, 'Баромадан');
    await tester.scrollUntilVisible(
      logout,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(logout);
    await tester.pumpAndSettle();

    expect(auth.logoutCalls, 1);
    expect(container.read(authControllerProvider).user, isNull);
    // Navigated to the login route.
    expect(find.text('Воридшавӣ'), findsOneWidget);
  });
}

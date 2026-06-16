import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/features/auth/data/auth_repository.dart';
import 'package:dorukhonai_man/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'support/fakes.dart';

Widget _host(FakeAuthRepository repo) {
  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/pos',
        builder: (context, state) =>
            const Scaffold(body: Text('POS_SCREEN')),
      ),
    ],
  );
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repo)],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStoragePlatform.instance =
        TestFlutterSecureStoragePlatform(<String, String>{});
  });

  testWidgets('empty fields show validation errors and do not log in',
      (tester) async {
    final repo = FakeAuthRepository(
      loginResult: Success(sampleLoginResponse()),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Воридшавӣ'));
    await tester.pumpAndSettle();

    expect(find.text('Логинро ворид кунед'), findsOneWidget);
    expect(find.text('Паролро ворид кунед'), findsOneWidget);
    expect(repo.loginCalls, 0);
    // Still on the login screen.
    expect(find.text('POS_SCREEN'), findsNothing);
  });

  testWidgets('valid credentials authenticate and navigate to /pos',
      (tester) async {
    final repo = FakeAuthRepository(
      loginResult: Success(sampleLoginResponse()),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'Admin123!');
    await tester.tap(find.text('Воридшавӣ'));
    await tester.pumpAndSettle();

    expect(repo.loginCalls, 1);
    expect(repo.lastUserName, 'admin');
    // Navigated to POS.
    expect(find.text('POS_SCREEN'), findsOneWidget);
  });

  testWidgets('login failure shows the error and stays on login',
      (tester) async {
    final repo = FakeAuthRepository(
      loginResult: const Error(AuthFailure('Логин ё парол нодуруст аст.')),
    );

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong');
    await tester.tap(find.text('Воридшавӣ'));
    await tester.pumpAndSettle();

    expect(find.text('Логин ё парол нодуруст аст.'), findsOneWidget);
    expect(find.text('POS_SCREEN'), findsNothing);
  });
}

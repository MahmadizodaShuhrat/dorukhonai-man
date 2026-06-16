import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_provider.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/pos/presentation/pos_screen.dart';
import '../features/products/presentation/products_list_screen.dart';
import '../features/receipts/presentation/receipts_list_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/stock/presentation/stock_screen.dart';
import 'app_shell.dart';

/// Application route paths.
class AppRoutes {
  AppRoutes._();
  static const login = '/login';
  static const pos = '/pos';
  static const products = '/products';
  static const receipts = '/receipts';
  static const stock = '/stock';
  static const reports = '/reports';
  static const settings = '/settings';
}

/// go_router configuration with an auth redirect: unauthenticated users are
/// sent to `/login`; authenticated users on `/login` are sent to `/pos`
/// (TZ §1, Roadmap step 0).
final routerProvider = Provider<GoRouter>((ref) {
  // Shell navigator key keeps the drawer/scaffold around route changes.
  final shellKey = GlobalKey<NavigatorState>();

  return GoRouter(
    initialLocation: AppRoutes.pos,
    refreshListenable: _AuthRefresh(ref),
    redirect: (context, state) {
      final isAuthenticated = ref.read(authControllerProvider).isAuthenticated;
      final loggingIn = state.matchedLocation == AppRoutes.login;

      if (!isAuthenticated) {
        return loggingIn ? null : AppRoutes.login;
      }
      if (loggingIn) return AppRoutes.pos;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      // Authenticated area wrapped in the app shell (nav rail/drawer).
      ShellRoute(
        navigatorKey: shellKey,
        builder: (context, state, child) =>
            AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.pos,
            builder: (context, state) => const PosScreen(),
          ),
          GoRoute(
            path: AppRoutes.products,
            builder: (context, state) => const ProductsListScreen(),
          ),
          GoRoute(
            path: AppRoutes.receipts,
            builder: (context, state) => const ReceiptsListScreen(),
          ),
          GoRoute(
            path: AppRoutes.stock,
            builder: (context, state) => const StockScreen(),
          ),
          GoRoute(
            path: AppRoutes.reports,
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

/// Bridges the Riverpod auth state to go_router's [Listenable]-based refresh.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}

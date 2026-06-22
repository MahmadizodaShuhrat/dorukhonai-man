import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_provider.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/operations/presentation/inventory_screen.dart';
import '../features/operations/presentation/supplier_return_screen.dart';
import '../features/operations/presentation/write_off_screen.dart';
import '../features/pos/presentation/pos_screen.dart';
import '../features/products/presentation/products_list_screen.dart';
import '../features/receipts/presentation/receipts_list_screen.dart';
import '../features/reference/presentation/drug_groups_screen.dart';
import '../features/reference/presentation/manufacturers_screen.dart';
import '../features/reference/presentation/suppliers_screen.dart';
import '../features/reference/presentation/units_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/stock/presentation/stock_screen.dart';
import 'app_shell.dart';

/// Application route paths.
class AppRoutes {
  AppRoutes._();
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const pos = '/pos';
  static const stock = '/stock';
  static const receipts = '/receipts';

  // Амалиёти анбор (MODUL 6) group.
  static const writeOffs = '/write-offs';
  static const inventory = '/inventory';
  static const supplierReturns = '/supplier-returns';

  // Маълумотномаҳо (reference data) group.
  static const products = '/products';
  static const drugGroups = '/drug-groups';
  static const suppliers = '/suppliers';
  static const manufacturers = '/manufacturers';
  static const units = '/units';

  static const reports = '/reports';
  static const settings = '/settings';
}

/// go_router configuration. Auth redirect: unauthenticated → `/login`;
/// authenticated users on `/login` → `/dashboard`. All sidebar destinations
/// are real routes inside the fixed desktop [AppShell] (TZ_03 §A).
final routerProvider = Provider<GoRouter>((ref) {
  final shellKey = GlobalKey<NavigatorState>();

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    refreshListenable: _AuthRefresh(ref),
    redirect: (context, state) {
      final isAuthenticated = ref.read(authControllerProvider).isAuthenticated;
      final loggingIn = state.matchedLocation == AppRoutes.login;

      if (!isAuthenticated) {
        return loggingIn ? null : AppRoutes.login;
      }
      if (loggingIn) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      // Authenticated area wrapped in the fixed desktop shell.
      ShellRoute(
        navigatorKey: shellKey,
        builder: (context, state, child) =>
            AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.pos,
            builder: (context, state) => const PosScreen(),
          ),
          GoRoute(
            path: AppRoutes.stock,
            builder: (context, state) => const StockScreen(),
          ),
          GoRoute(
            path: AppRoutes.receipts,
            builder: (context, state) => const ReceiptsListScreen(),
          ),
          GoRoute(
            path: AppRoutes.writeOffs,
            builder: (context, state) => const WriteOffScreen(),
          ),
          GoRoute(
            path: AppRoutes.inventory,
            builder: (context, state) => const InventoryScreen(),
          ),
          GoRoute(
            path: AppRoutes.supplierReturns,
            builder: (context, state) => const SupplierReturnScreen(),
          ),
          GoRoute(
            path: AppRoutes.products,
            builder: (context, state) => const ProductsListScreen(),
          ),
          GoRoute(
            path: AppRoutes.drugGroups,
            builder: (context, state) => const DrugGroupsScreen(),
          ),
          GoRoute(
            path: AppRoutes.suppliers,
            builder: (context, state) => const SuppliersScreen(),
          ),
          GoRoute(
            path: AppRoutes.manufacturers,
            builder: (context, state) => const ManufacturersScreen(),
          ),
          GoRoute(
            path: AppRoutes.units,
            builder: (context, state) => const UnitsScreen(),
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

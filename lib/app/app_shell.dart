import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';

/// Navigation shell for the authenticated area.
///
/// Responsive: a [NavigationRail] on the side for wide layouts
/// (tablets/desktop, width >= [_wideBreakpoint]) and a bottom Material 3
/// [NavigationBar] on narrow layouts (phones). Both expose the same
/// destinations and stay in sync with go_router.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  /// Layouts at least this wide use the side rail; narrower use the bottom bar.
  static const double _wideBreakpoint = 800;

  static const _destinations = <_NavDestination>[
    _NavDestination(AppRoutes.pos, Icons.point_of_sale, 'Касса'),
    _NavDestination(AppRoutes.products, Icons.medication, 'Доруҳо'),
    _NavDestination(AppRoutes.receipts, Icons.inventory_2, 'Приход'),
    _NavDestination(AppRoutes.stock, Icons.warehouse, 'Анбор'),
    _NavDestination(AppRoutes.reports, Icons.bar_chart, 'Ҳисобот'),
    _NavDestination(AppRoutes.settings, Icons.settings, 'Танзимот'),
  ];

  int get _selectedIndex {
    final index = _destinations.indexWhere((d) => location.startsWith(d.route));
    return index < 0 ? 0 : index;
  }

  void _onSelected(BuildContext context, int index) =>
      context.go(_destinations[index].route);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _wideBreakpoint;
        return isWide ? _buildWide(context) : _buildNarrow(context);
      },
    );
  }

  Widget _buildWide(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: (i) => _onSelected(context, i),
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildNarrow(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => _onSelected(context, i),
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination(this.route, this.icon, this.label);
  final String route;
  final IconData icon;
  final String label;
}

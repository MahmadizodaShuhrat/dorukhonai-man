import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_provider.dart';
import '../features/branch/presentation/branch_provider.dart';
import '../features/pos/presentation/pos_providers.dart';
import '../features/sync/presentation/connectivity_provider.dart';
import '../features/sync/presentation/sync_panel.dart';
import '../features/sync/presentation/sync_providers.dart';
import '../shared/status_chip.dart';
import 'command_palette.dart';
import 'router.dart';

/// Fixed professional desktop shell (TZ_03 §A): a persistent left sidebar, a
/// top bar (branch · shift · online/offline · Ctrl+K search · user menu), and
/// the routed content area. No responsive breakpoint, no bottom navigation.
///
/// App-level keyboard navigation: Ctrl+1..6 jump between primary sections.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    // Start connectivity polling + initial sync once inside the authed shell
    // (TZ_04 §4: pull on start, drain outbox, poll for reconnect).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncCoordinatorProvider).start();
    });
    // Resolve the REAL branch and load the current shift session-wide so the
    // top-bar shift chip is accurate from any screen (TZ_05 FW1/FW2), not only
    // after visiting POS.
    ref.listenManual<String?>(currentBranchIdProvider, (previous, next) {
      if (next == null || next.isEmpty) return;
      if (ref.read(cashShiftControllerProvider).branchId == next) return;
      ref.read(cashShiftControllerProvider.notifier)
        ..setBranchId(next)
        ..loadCurrent();
    }, fireImmediately: true);
  }

  /// Ctrl+1..6 → primary sections (TZ_03 §D keyboard map).
  static const _numberShortcuts = <String>[
    AppRoutes.dashboard, // Ctrl+1
    AppRoutes.pos, // Ctrl+2
    AppRoutes.stock, // Ctrl+3
    AppRoutes.receipts, // Ctrl+4
    AppRoutes.reports, // Ctrl+5
    AppRoutes.settings, // Ctrl+6
  ];

  static const _digitKeys = <LogicalKeyboardKey>[
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
    LogicalKeyboardKey.digit5,
    LogicalKeyboardKey.digit6,
  ];

  void _go(String route) {
    if (!widget.location.startsWith(route)) context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        for (var i = 0; i < _numberShortcuts.length; i++)
          SingleActivator(_digitKeys[i], control: true): _GoSectionIntent(
            _numberShortcuts[i],
          ),
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            const _CommandPaletteIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _GoSectionIntent: CallbackAction<_GoSectionIntent>(
            onInvoke: (intent) {
              _go(intent.route);
              return null;
            },
          ),
          _CommandPaletteIntent: CallbackAction<_CommandPaletteIntent>(
            onInvoke: (_) {
              CommandPalette.show(context);
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: theme.colorScheme.surface,
            body: Row(
              children: [
                _Sidebar(
                  location: widget.location,
                  collapsed: _collapsed,
                  onToggle: () => setState(() => _collapsed = !_collapsed),
                  onSelect: _go,
                ),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: theme.colorScheme.outlineVariant,
                ),
                Expanded(
                  child: Column(
                    children: [
                      const _TopBar(),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: theme.colorScheme.outlineVariant,
                      ),
                      Expanded(child: widget.child),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Intent: navigate to a primary section.
class _GoSectionIntent extends Intent {
  const _GoSectionIntent(this.route);
  final String route;
}

/// Intent: open the Ctrl+K command palette.
class _CommandPaletteIntent extends Intent {
  const _CommandPaletteIntent();
}

// ---------------------------------------------------------------------------
// Sidebar
// ---------------------------------------------------------------------------

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.location,
    required this.collapsed,
    required this.onToggle,
    required this.onSelect,
  });

  final String location;
  final bool collapsed;
  final VoidCallback onToggle;
  final ValueChanged<String> onSelect;

  static const double _expandedWidth = 240;
  static const double _collapsedWidth = 64;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: collapsed ? _collapsedWidth : _expandedWidth,
      color: theme.colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Brand(collapsed: collapsed),
          const SizedBox(height: 4),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              children: [
                _NavItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Дашборд',
                  route: AppRoutes.dashboard,
                  shortcut: 'Ctrl+1',
                  location: location,
                  collapsed: collapsed,
                  onSelect: onSelect,
                ),
                _NavItem(
                  icon: Icons.point_of_sale_outlined,
                  label: 'Касса',
                  route: AppRoutes.pos,
                  shortcut: 'Ctrl+2',
                  location: location,
                  collapsed: collapsed,
                  onSelect: onSelect,
                ),
                _NavItem(
                  icon: Icons.warehouse_outlined,
                  label: 'Анбор',
                  route: AppRoutes.stock,
                  shortcut: 'Ctrl+3',
                  location: location,
                  collapsed: collapsed,
                  onSelect: onSelect,
                ),
                _NavItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Приход',
                  route: AppRoutes.receipts,
                  shortcut: 'Ctrl+4',
                  location: location,
                  collapsed: collapsed,
                  onSelect: onSelect,
                ),
                const SizedBox(height: 8),
                if (!collapsed)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: Text(
                      'АМАЛИЁТИ АНБОР',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 0.6,
                      ),
                    ),
                  )
                else
                  Divider(
                    height: 12,
                    color: theme.colorScheme.outlineVariant,
                    indent: 12,
                    endIndent: 12,
                  ),
                _NavItem(
                  icon: Icons.delete_sweep_outlined,
                  label: 'Списание',
                  route: AppRoutes.writeOffs,
                  location: location,
                  collapsed: collapsed,
                  onSelect: onSelect,
                ),
                _NavItem(
                  icon: Icons.fact_check_outlined,
                  label: 'Инвентаризатсия',
                  route: AppRoutes.inventory,
                  location: location,
                  collapsed: collapsed,
                  onSelect: onSelect,
                ),
                _NavItem(
                  icon: Icons.assignment_return_outlined,
                  label: 'Бозгашт',
                  route: AppRoutes.supplierReturns,
                  location: location,
                  collapsed: collapsed,
                  onSelect: onSelect,
                ),
                const SizedBox(height: 8),
                if (!collapsed)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: Text(
                      'МАЪЛУМОТНОМАҲО',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 0.6,
                      ),
                    ),
                  )
                else
                  Divider(
                    height: 12,
                    color: theme.colorScheme.outlineVariant,
                    indent: 12,
                    endIndent: 12,
                  ),
                _NavItem(
                  icon: Icons.medication_outlined,
                  label: 'Доруҳо',
                  route: AppRoutes.products,
                  location: location,
                  collapsed: collapsed,
                  onSelect: onSelect,
                ),
                _NavItem(
                  icon: Icons.category_outlined,
                  label: 'Гурӯҳҳо',
                  route: AppRoutes.drugGroups,
                  location: location,
                  collapsed: collapsed,
                  onSelect: onSelect,
                ),
                _NavItem(
                  icon: Icons.local_shipping_outlined,
                  label: 'Таъминкунандагон',
                  route: AppRoutes.suppliers,
                  location: location,
                  collapsed: collapsed,
                  onSelect: onSelect,
                ),
                _NavItem(
                  icon: Icons.factory_outlined,
                  label: 'Истеҳсолкунандагон',
                  route: AppRoutes.manufacturers,
                  location: location,
                  collapsed: collapsed,
                  onSelect: onSelect,
                ),
                _NavItem(
                  icon: Icons.straighten_outlined,
                  label: 'Воҳидҳо',
                  route: AppRoutes.units,
                  location: location,
                  collapsed: collapsed,
                  onSelect: onSelect,
                ),
                const SizedBox(height: 8),
                if (collapsed)
                  Divider(
                    height: 12,
                    color: theme.colorScheme.outlineVariant,
                    indent: 12,
                    endIndent: 12,
                  ),
                _NavItem(
                  icon: Icons.bar_chart_outlined,
                  label: 'Ҳисоботҳо',
                  route: AppRoutes.reports,
                  shortcut: 'Ctrl+5',
                  location: location,
                  collapsed: collapsed,
                  onSelect: onSelect,
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  label: 'Танзимот',
                  route: AppRoutes.settings,
                  shortcut: 'Ctrl+6',
                  location: location,
                  collapsed: collapsed,
                  onSelect: onSelect,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          // Collapse toggle + version footer.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: collapsed ? 'Васеъ кардан' : 'Печондан',
                  icon: Icon(
                    collapsed ? Icons.chevron_right : Icons.chevron_left,
                  ),
                  onPressed: onToggle,
                ),
                if (!collapsed)
                  Text(
                    'v1.0',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.collapsed});
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: collapsed ? Alignment.center : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_pharmacy,
            color: theme.colorScheme.primary,
            size: 26,
          ),
          if (!collapsed) ...[
            const SizedBox(width: 10),
            Text(
              'DOROHONA',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.location,
    required this.collapsed,
    required this.onSelect,
    this.shortcut,
  });

  final IconData icon;
  final String label;
  final String route;
  final String location;
  final bool collapsed;
  final ValueChanged<String> onSelect;
  final String? shortcut;

  bool get _selected => location.startsWith(route);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = _selected;
    final fg = selected
        ? theme.colorScheme.onSecondaryContainer
        : theme.colorScheme.onSurfaceVariant;

    final tile = Material(
      color: selected
          ? theme.colorScheme.secondaryContainer
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onSelect(route),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 0 : 12,
            vertical: 10,
          ),
          child: Row(
            mainAxisAlignment: collapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: fg),
              if (!collapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: fg,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
                if (shortcut != null)
                  Text(
                    shortcut!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: collapsed ? Tooltip(message: label, child: tile) : tile,
    );
  }
}

// ---------------------------------------------------------------------------
// Top bar
// ---------------------------------------------------------------------------

class _TopBar extends ConsumerWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider.select((s) => s.user));

    return Container(
      height: 56,
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Branch name from the resolved session/`/branches` (TZ_05 FW2).
          const _BranchChip(),
          const SizedBox(width: 12),
          // Open-shift indicator bound to the cash-shift controller (FW2).
          const _ShiftChip(),
          const SizedBox(width: 12),
          // Online/offline status + pending-sync count (TZ_04 §6). Click opens
          // the sync queue / reconciliation panel.
          const _ConnectivityIndicator(),
          const Spacer(),
          // Command search (Ctrl+K) — opens the real command palette.
          _SearchButton(onTap: () => CommandPalette.show(context)),
          const SizedBox(width: 12),
          _UserMenu(userName: user?.fullName, role: user?.role.wire),
        ],
      ),
    );
  }
}

/// Top-bar branch chip: the resolved branch name (FW2). Falls back to a neutral
/// "Филиал" label while the branch is still resolving / unavailable offline.
class _BranchChip extends ConsumerWidget {
  const _BranchChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branch = ref.watch(currentBranchProvider);
    final name = branch.maybeWhen(
      data: (b) => (b == null || b.name.isEmpty) ? 'Филиал' : b.name,
      orElse: () => 'Филиал',
    );
    return StatusChip(
      label: name,
      tone: StatusTone.info,
      icon: Icons.storefront_outlined,
    );
  }
}

/// Top-bar shift chip bound to [cashShiftControllerProvider] (FW2): green
/// "Кушода · HH:mm" when a shift is open, neutral "Смена баста" otherwise.
/// Tapping jumps to the POS register.
class _ShiftChip extends ConsumerWidget {
  const _ShiftChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shift = ref.watch(
      cashShiftControllerProvider.select((s) => s.hasOpenShift ? s.shift : null),
    );
    final open = shift != null;
    final label = open
        ? 'Кушода · ${_hhmm(shift.openedAt)}'
        : 'Смена баста';
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => context.go(AppRoutes.pos),
      child: StatusChip(
        label: label,
        tone: open ? StatusTone.ok : StatusTone.info,
        icon: open ? Icons.lock_clock_outlined : Icons.schedule_outlined,
      ),
    );
  }

  static String _hhmm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

/// Real online/offline chip + pending-sync count (TZ_04 §6 / TZ_03 §A.3).
/// Green "Онлайн" when reachable, amber "Офлайн" otherwise; appends "· N навбат"
/// when sales await sync. Tapping opens the sync queue / reconciliation panel.
class _ConnectivityIndicator extends ConsumerWidget {
  const _ConnectivityIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conn = ref.watch(connectivityControllerProvider);
    final pending = ref.watch(pendingSyncCountProvider).valueOrNull ?? 0;

    final online = conn.isOnline;
    final tone = online ? StatusTone.ok : StatusTone.warn;
    final base = online ? 'Онлайн' : 'Офлайн';
    final label = pending > 0 ? '$base · $pending навбат' : base;
    final tooltip = StringBuffer(online ? 'Сервер дастрас' : 'Сервер дастнорас');
    if (conn.lastOnlineAt != null) {
      tooltip.write('\nОхирин: ${_hhmm(conn.lastOnlineAt!)}');
    }
    if (pending > 0) {
      tooltip.write('\n$pending фурӯш дар навбати синхрон');
    }

    return Tooltip(
      message: tooltip.toString(),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => SyncPanel.show(context),
        child: StatusChip(
          label: label,
          tone: tone,
          icon: online
              ? Icons.cloud_done_outlined
              : Icons.cloud_off_outlined,
        ),
      ),
    );
  }

  static String _hhmm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class _SearchButton extends StatelessWidget {
  const _SearchButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 280,
      height: 36,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ҷустуҷӯ ё фармон…',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Ctrl+K',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserMenu extends ConsumerWidget {
  const _UserMenu({this.userName, this.role});
  final String? userName;
  final String? role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final name = (userName == null || userName!.isEmpty) ? 'Корбар' : userName!;
    return MenuAnchor(
      builder: (context, controller, _) {
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () =>
              controller.isOpen ? controller.close() : controller.open(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    name.characters.first.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(name, style: theme.textTheme.bodyMedium),
                    if (role != null)
                      Text(
                        role!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        );
      },
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.logout, size: 18),
          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          child: const Text('Баромад'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import 'router.dart';

/// One entry in the [CommandPalette]: a label, an icon, an optional keyboard
/// hint, and the action to run when chosen.
class _Command {
  const _Command({
    required this.label,
    required this.icon,
    required this.onRun,
    this.hint,
    this.keywords = '',
  });

  final String label;
  final IconData icon;
  final void Function(BuildContext context) onRun;
  final String? hint;

  /// Extra (latin) search terms so e.g. "pos"/"kassa" also match "Касса".
  final String keywords;

  bool matches(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return label.toLowerCase().contains(q) || keywords.toLowerCase().contains(q);
  }
}

/// Real Ctrl+K command palette (TZ_05 FW5), replacing the old placeholder
/// toast. Lists primary sections + quick actions in a searchable overlay with
/// arrow/enter keyboard navigation. Reuses the search-dialog pattern of
/// [EntityPicker] but is navigation-only (no async data).
class CommandPalette extends StatefulWidget {
  const CommandPalette._();

  /// Opens the palette as a centred modal.
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => const CommandPalette._(),
    );
  }

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final _queryController = TextEditingController();
  final _searchFocus = FocusNode();
  final _scrollController = ScrollController();

  String _query = '';
  int _selected = 0;

  /// All available commands (sections + quick actions). Each `go`s to a route.
  /// Labels are localized; the latin [keywords] keep search working across
  /// languages (e.g. "pos"/"kassa" still match Касса/Касса).
  static List<_Command> _commands(AppLocalizations l) => [
    _Command(
      label: l.navDashboard,
      icon: Icons.dashboard_outlined,
      hint: 'Ctrl+1',
      keywords: 'dashboard glavnaya dashbord',
      onRun: (c) => c.go(AppRoutes.dashboard),
    ),
    _Command(
      label: l.navPos,
      icon: Icons.point_of_sale_outlined,
      hint: 'Ctrl+2',
      keywords: 'pos kassa sale furush prodaja',
      onRun: (c) => c.go(AppRoutes.pos),
    ),
    _Command(
      label: l.navStock,
      icon: Icons.warehouse_outlined,
      hint: 'Ctrl+3',
      keywords: 'stock anbor sklad',
      onRun: (c) => c.go(AppRoutes.stock),
    ),
    _Command(
      label: l.navReceipts,
      icon: Icons.inventory_2_outlined,
      hint: 'Ctrl+4',
      keywords: 'receipt prihod prikhod',
      onRun: (c) => c.go(AppRoutes.receipts),
    ),
    _Command(
      label: l.navWriteOffs,
      icon: Icons.delete_sweep_outlined,
      keywords: 'writeoff spisanie',
      onRun: (c) => c.go(AppRoutes.writeOffs),
    ),
    _Command(
      label: l.navInventory,
      icon: Icons.fact_check_outlined,
      keywords: 'inventory inventarizatsiya inventarizatsiya',
      onRun: (c) => c.go(AppRoutes.inventory),
    ),
    _Command(
      label: l.navSupplierReturnsLong,
      icon: Icons.assignment_return_outlined,
      keywords: 'supplier return bozgasht vozvrat postavshik',
      onRun: (c) => c.go(AppRoutes.supplierReturns),
    ),
    _Command(
      label: l.navProducts,
      icon: Icons.medication_outlined,
      keywords: 'products doru tovary preparaty',
      onRun: (c) => c.go(AppRoutes.products),
    ),
    _Command(
      label: l.navDrugGroups,
      icon: Icons.category_outlined,
      keywords: 'groups guruh gruppy',
      onRun: (c) => c.go(AppRoutes.drugGroups),
    ),
    _Command(
      label: l.navSuppliers,
      icon: Icons.local_shipping_outlined,
      keywords: 'suppliers taminkunanda postavshiki',
      onRun: (c) => c.go(AppRoutes.suppliers),
    ),
    _Command(
      label: l.navManufacturers,
      icon: Icons.factory_outlined,
      keywords: 'manufacturers istehsol proizvoditeli',
      onRun: (c) => c.go(AppRoutes.manufacturers),
    ),
    _Command(
      label: l.navUnits,
      icon: Icons.straighten_outlined,
      keywords: 'units vohid edinitsy',
      onRun: (c) => c.go(AppRoutes.units),
    ),
    _Command(
      label: l.navReports,
      icon: Icons.bar_chart_outlined,
      hint: 'Ctrl+5',
      keywords: 'reports hisobot otchety',
      onRun: (c) => c.go(AppRoutes.reports),
    ),
    _Command(
      label: l.navSettings,
      icon: Icons.settings_outlined,
      hint: 'Ctrl+6',
      keywords: 'settings tanzimot nastroyki',
      onRun: (c) => c.go(AppRoutes.settings),
    ),
  ];

  List<_Command> _filteredFor(AppLocalizations l) =>
      _commands(l).where((c) => c.matches(_query)).toList(growable: false);

  @override
  void dispose() {
    _queryController.dispose();
    _searchFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() {
      _query = value;
      _selected = 0;
    });
  }

  void _move(int delta) {
    final results = _filteredFor(AppLocalizations.of(context));
    if (results.isEmpty) return;
    setState(() {
      _selected = (_selected + delta).clamp(0, results.length - 1);
    });
  }

  void _runSelected() {
    final results = _filteredFor(AppLocalizations.of(context));
    if (results.isEmpty || _selected < 0 || _selected >= results.length) return;
    final command = results[_selected];
    Navigator.of(context).pop();
    command.onRun(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final results = _filteredFor(l);

    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 96),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 480),
        child: FocusScope(
          child: CallbackShortcuts(
            bindings: <ShortcutActivator, VoidCallback>{
              const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                  _move(1),
              const SingleActivator(LogicalKeyboardKey.arrowUp): () => _move(-1),
              const SingleActivator(LogicalKeyboardKey.enter): _runSelected,
              const SingleActivator(LogicalKeyboardKey.numpadEnter):
                  _runSelected,
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _queryController,
                    focusNode: _searchFocus,
                    autofocus: true,
                    onChanged: _onQueryChanged,
                    onSubmitted: (_) => _runSelected(),
                    decoration: InputDecoration(
                      hintText: l.commandSearchHint,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: results.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              l.commandNothingFound,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          shrinkWrap: true,
                          itemCount: results.length,
                          itemBuilder: (context, i) {
                            final command = results[i];
                            final selected = i == _selected;
                            return ListTile(
                              dense: true,
                              selected: selected,
                              selectedTileColor:
                                  theme.colorScheme.secondaryContainer,
                              selectedColor:
                                  theme.colorScheme.onSecondaryContainer,
                              leading: Icon(command.icon, size: 20),
                              title: Text(command.label),
                              trailing: command.hint == null
                                  ? null
                                  : Text(
                                      command.hint!,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                              onTap: () {
                                setState(() => _selected = i);
                                _runSelected();
                              },
                            );
                          },
                        ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    l.commandFooterHint,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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

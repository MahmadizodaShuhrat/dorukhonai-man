import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

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
  static final List<_Command> _all = [
    _Command(
      label: 'Дашборд',
      icon: Icons.dashboard_outlined,
      hint: 'Ctrl+1',
      keywords: 'dashboard glavnaya',
      onRun: (c) => c.go(AppRoutes.dashboard),
    ),
    _Command(
      label: 'Касса',
      icon: Icons.point_of_sale_outlined,
      hint: 'Ctrl+2',
      keywords: 'pos kassa sale furush',
      onRun: (c) => c.go(AppRoutes.pos),
    ),
    _Command(
      label: 'Анбор',
      icon: Icons.warehouse_outlined,
      hint: 'Ctrl+3',
      keywords: 'stock anbor sklad',
      onRun: (c) => c.go(AppRoutes.stock),
    ),
    _Command(
      label: 'Приход',
      icon: Icons.inventory_2_outlined,
      hint: 'Ctrl+4',
      keywords: 'receipt prihod',
      onRun: (c) => c.go(AppRoutes.receipts),
    ),
    _Command(
      label: 'Списание',
      icon: Icons.delete_sweep_outlined,
      keywords: 'writeoff spisanie',
      onRun: (c) => c.go(AppRoutes.writeOffs),
    ),
    _Command(
      label: 'Инвентаризатсия',
      icon: Icons.fact_check_outlined,
      keywords: 'inventory inventarizatsiya',
      onRun: (c) => c.go(AppRoutes.inventory),
    ),
    _Command(
      label: 'Бозгашт ба таъминкунанда',
      icon: Icons.assignment_return_outlined,
      keywords: 'supplier return bozgasht vozvrat',
      onRun: (c) => c.go(AppRoutes.supplierReturns),
    ),
    _Command(
      label: 'Доруҳо',
      icon: Icons.medication_outlined,
      keywords: 'products doru',
      onRun: (c) => c.go(AppRoutes.products),
    ),
    _Command(
      label: 'Гурӯҳҳо',
      icon: Icons.category_outlined,
      keywords: 'groups guruh',
      onRun: (c) => c.go(AppRoutes.drugGroups),
    ),
    _Command(
      label: 'Таъминкунандагон',
      icon: Icons.local_shipping_outlined,
      keywords: 'suppliers taminkunanda',
      onRun: (c) => c.go(AppRoutes.suppliers),
    ),
    _Command(
      label: 'Истеҳсолкунандагон',
      icon: Icons.factory_outlined,
      keywords: 'manufacturers istehsol',
      onRun: (c) => c.go(AppRoutes.manufacturers),
    ),
    _Command(
      label: 'Воҳидҳо',
      icon: Icons.straighten_outlined,
      keywords: 'units vohid',
      onRun: (c) => c.go(AppRoutes.units),
    ),
    _Command(
      label: 'Ҳисоботҳо',
      icon: Icons.bar_chart_outlined,
      hint: 'Ctrl+5',
      keywords: 'reports hisobot',
      onRun: (c) => c.go(AppRoutes.reports),
    ),
    _Command(
      label: 'Танзимот',
      icon: Icons.settings_outlined,
      hint: 'Ctrl+6',
      keywords: 'settings tanzimot',
      onRun: (c) => c.go(AppRoutes.settings),
    ),
  ];

  List<_Command> get _filtered =>
      _all.where((c) => c.matches(_query)).toList(growable: false);

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
    final results = _filtered;
    if (results.isEmpty) return;
    setState(() {
      _selected = (_selected + delta).clamp(0, results.length - 1);
    });
  }

  void _runSelected() {
    final results = _filtered;
    if (results.isEmpty || _selected < 0 || _selected >= results.length) return;
    final command = results[_selected];
    Navigator.of(context).pop();
    command.onRun(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = _filtered;

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
                    decoration: const InputDecoration(
                      hintText: 'Фармон ё бахшро ҷустуҷӯ кунед…',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
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
                              'Чизе ёфт нашуд',
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
                    '↑↓ интихоб · Enter кушодан · Esc пӯшидан',
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

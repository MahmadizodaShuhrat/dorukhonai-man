import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/app_data_table.dart';
import '../../../shared/app_scaffold.dart';
import '../../../shared/primary_button.dart';
import '../../../shared/status_chip.dart';
import '../../reference/presentation/reference_providers.dart';
import '../data/product_models.dart';
import 'product_editor_panel.dart';
import 'products_provider.dart';

/// Products / drug-catalog screen (TZ_03 §C.5): an [AppScaffold] page with a
/// search field, an [AppDataTable] of products (Ном · Штрих-код · Гурӯҳ ·
/// Воҳид · Ретсептӣ · Фаъол) and a 380px side-panel editor on the right —
/// opened via "+ Дору нав" (create) or a row tap (edit). No typed GUIDs: the
/// editor uses [EntityPicker]s for group/manufacturer/unit.
///
/// Нарх (sale price) is intentionally NOT a column here: per the backend
/// contract price lives on `Batch` (per partia), not on `Product` — it is shown
/// in the Анбор/Stock screen, not the catalog.
class ProductsListScreen extends ConsumerStatefulWidget {
  const ProductsListScreen({super.key});

  @override
  ConsumerState<ProductsListScreen> createState() =>
      _ProductsListScreenState();
}

class _ProductsListScreenState extends ConsumerState<ProductsListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  bool _editorOpen = false;
  Product? _editing;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(productsListControllerProvider.notifier).search(value);
    });
  }

  void _openCreate() => setState(() {
    _editing = null;
    _editorOpen = true;
  });

  void _openEdit(Product product) => setState(() {
    _editing = product;
    _editorOpen = true;
  });

  void _closePanel() => setState(() => _editorOpen = false);

  /// Builds an id→name lookup from a reference options provider so the table
  /// can show group/unit NAMES instead of GUIDs.
  Map<String, String> _lookup(
    AsyncValue<List<EntityOption>> async,
  ) {
    return async.maybeWhen(
      data: (options) => {for (final o in options) o.id: o.label},
      orElse: () => const {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productsListControllerProvider);
    final controller = ref.read(productsListControllerProvider.notifier);

    final groupNames = _lookup(ref.watch(drugGroupOptionsProvider('')));
    final unitNames = _lookup(ref.watch(unitOptionsProvider('')));

    return AppScaffold(
      title: 'Доруҳо',
      icon: Icons.medication_outlined,
      subtitle: 'Ҳамагӣ: ${state.total}',
      actions: [
        PrimaryButton(
          label: 'Дору нав',
          icon: Icons.add,
          expand: false,
          onPressed: _openCreate,
        ),
      ],
      padBody: false,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Ҷустуҷӯ (ном ё штрих-код)…',
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Stack(
                      children: [
                        AppDataTable(
                          minWidth: 760,
                          fixedLeftColumns: 1,
                          isLoading: state.isLoading,
                          emptyMessage: 'Дору ёфт нашуд',
                          emptyIcon: Icons.medication_outlined,
                          errorMessage:
                              state.failure != null && state.products.isEmpty
                              ? state.failure!.message
                              : null,
                          onRetry: controller.refresh,
                          columns: const [
                            DataColumn2(label: Text('Ном'), size: ColumnSize.L),
                            DataColumn2(label: Text('Штрих-код')),
                            DataColumn2(label: Text('Гурӯҳ')),
                            DataColumn2(
                              label: Text('Воҳид'),
                              size: ColumnSize.S,
                            ),
                            DataColumn2(
                              label: Text('Ретсептӣ'),
                              size: ColumnSize.S,
                            ),
                            DataColumn2(
                              label: Text('Фаъол'),
                              size: ColumnSize.S,
                            ),
                          ],
                          rows: [
                            for (final product in state.products)
                              DataRow2(
                                selected: _editorOpen &&
                                    _editing?.id == product.id,
                                onTap: () => _openEdit(product),
                                cells: [
                                  DataCell(Text(product.name)),
                                  DataCell(Text(product.barcode ?? '—')),
                                  DataCell(
                                    Text(
                                      product.drugGroupId == null
                                          ? '—'
                                          : (groupNames[product.drugGroupId] ??
                                                '—'),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      product.unitId == null
                                          ? '—'
                                          : (unitNames[product.unitId] ?? '—'),
                                    ),
                                  ),
                                  DataCell(
                                    product.rxRequired
                                        ? const StatusChip(
                                            label: '℞',
                                            tone: StatusTone.warn,
                                            dense: true,
                                          )
                                        : const Text('—'),
                                  ),
                                  DataCell(
                                    product.isActive
                                        ? const StatusChip(
                                            label: 'Фаъол',
                                            tone: StatusTone.ok,
                                            dense: true,
                                          )
                                        : const StatusChip(
                                            label: 'Ғайрифаъол',
                                            tone: StatusTone.info,
                                            dense: true,
                                          ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        if (state.isLoading && state.products.isNotEmpty)
                          const Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: LinearProgressIndicator(minHeight: 2),
                          ),
                      ],
                    ),
                  ),
                  _PaginationBar(state: state, controller: controller),
                ],
              ),
            ),
          ),
          if (_editorOpen)
            ProductEditorPanel(
              // Re-key so the form rebuilds its controllers when switching rows.
              key: ValueKey(_editing?.id ?? '__new__'),
              product: _editing,
              onDone: _closePanel,
            ),
        ],
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({required this.state, required this.controller});

  final ProductsListState state;
  final ProductsListController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Text('Ҳамагӣ: ${state.total}'),
          const Spacer(),
          IconButton(
            tooltip: 'Қаблӣ',
            icon: const Icon(Icons.chevron_left),
            onPressed: state.hasPrevious && !state.isLoading
                ? controller.previousPage
                : null,
          ),
          Text('${state.page} / ${state.pageCount}'),
          IconButton(
            tooltip: 'Баъдӣ',
            icon: const Icon(Icons.chevron_right),
            onPressed: state.hasNext && !state.isLoading
                ? controller.nextPage
                : null,
          ),
        ],
      ),
    );
  }
}

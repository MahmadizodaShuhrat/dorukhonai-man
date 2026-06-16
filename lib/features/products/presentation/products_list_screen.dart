import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/product_models.dart';
import 'product_form_screen.dart';
import 'products_provider.dart';

/// Products / drug-catalog list (TZ §3.3): a search field on top and a
/// paginated [DataTable2] of products. Tapping a row opens the edit form; the
/// FAB opens the create form.
class ProductsListScreen extends ConsumerStatefulWidget {
  const ProductsListScreen({super.key});

  @override
  ConsumerState<ProductsListScreen> createState() =>
      _ProductsListScreenState();
}

class _ProductsListScreenState extends ConsumerState<ProductsListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

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

  Future<void> _openForm({Product? product}) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(product: product),
      ),
    );
    // The form controller already refreshes the list on success; nothing to
    // do here.
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productsListControllerProvider);
    final controller = ref.read(productsListControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Справочники дору'),
        actions: [
          IconButton(
            tooltip: 'Навсозӣ',
            icon: const Icon(Icons.refresh),
            onPressed: state.isLoading ? null : controller.refresh,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Дору нав'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Ҷустуҷӯ (ном ё штрих-код)…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          Expanded(child: _buildBody(context, state, controller)),
          _buildPaginationBar(context, state, controller),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ProductsListState state,
    ProductsListController controller,
  ) {
    if (state.failure != null && state.products.isEmpty) {
      return _ErrorView(
        message: state.failure!.message,
        onRetry: controller.refresh,
      );
    }
    if (!state.isLoading && state.products.isEmpty) {
      return const _EmptyView();
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DataTable2(
            columnSpacing: 16,
            horizontalMargin: 12,
            minWidth: 720,
            columns: const [
              DataColumn2(label: Text('Ном'), size: ColumnSize.L),
              DataColumn2(label: Text('Штрих-код')),
              DataColumn2(label: Text('Ретсептӣ'), size: ColumnSize.S),
              DataColumn2(label: Text('Фаъол'), size: ColumnSize.S),
            ],
            rows: [
              for (final product in state.products)
                DataRow2(
                  onTap: () => _openForm(product: product),
                  cells: [
                    DataCell(Text(product.name)),
                    DataCell(Text(product.barcode ?? '—')),
                    DataCell(
                      product.rxRequired
                          ? const Icon(Icons.check, size: 18)
                          : const Text('—'),
                    ),
                    DataCell(
                      Icon(
                        product.isActive
                            ? Icons.check_circle
                            : Icons.cancel_outlined,
                        size: 18,
                        color: product.isActive
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (state.isLoading)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }

  Widget _buildPaginationBar(
    BuildContext context,
    ProductsListState state,
    ProductsListController controller,
  ) {
    return Material(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.medication_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          const Text('Дору ёфт нашуд'),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Аз нав кӯшиш кунед'),
          ),
        ],
      ),
    );
  }
}

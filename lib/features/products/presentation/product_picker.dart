import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../l10n/app_localizations.dart';
import '../data/product_models.dart';
import '../data/products_repository.dart';
import 'quick_create_product_dialog.dart';

/// A reusable modal product lookup (search by name OR scan a 1D barcode into
/// the focused field) backed by [ProductsRepository]. Returns the chosen
/// [Product] via `Navigator.pop`, or `null` if cancelled.
///
/// Scanner behaviour (TZ_00 / §2): a USB 1D scanner types the barcode then
/// sends Enter. Submitting the field triggers an exact `by-barcode` lookup; if
/// that misses, it falls back to a name/barcode `search`.
class ProductPickerDialog extends ConsumerStatefulWidget {
  const ProductPickerDialog({super.key});

  /// Opens the picker and resolves to the selected product (or `null`).
  static Future<Product?> show(BuildContext context) {
    return showDialog<Product>(
      context: context,
      builder: (_) => const ProductPickerDialog(),
    );
  }

  @override
  ConsumerState<ProductPickerDialog> createState() =>
      _ProductPickerDialogState();
}

class _ProductPickerDialogState extends ConsumerState<ProductPickerDialog> {
  final _queryController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  List<Product> _results = const [];
  bool _isLoading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    // Keep focus on the field so a scanner's keystrokes land here.
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
    _runSearch('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _runSearch(value),
    );
  }

  Future<void> _runSearch(String term) async {
    final repo = ref.read(productsRepositoryProvider);
    setState(() {
      _isLoading = true;
      _message = null;
    });
    final result = await repo.list(search: term, page: 1, size: 25);
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    switch (result) {
      case Success(:final data):
        setState(() {
          _results = data.items;
          _isLoading = false;
          _message = data.items.isEmpty ? l.productsEmpty : null;
        });
      case Error(:final failure):
        setState(() {
          _results = const [];
          _isLoading = false;
          _message = failure.message;
        });
    }
  }

  /// On Enter (scanner end-of-code or manual): try an exact barcode hit first,
  /// then fall back to a regular search.
  Future<void> _onSubmitted(String value) async {
    final code = value.trim();
    if (code.isEmpty) return;
    final repo = ref.read(productsRepositoryProvider);
    setState(() {
      _isLoading = true;
      _message = null;
    });
    final byBarcode = await repo.getByBarcode(code);
    if (!mounted) return;
    switch (byBarcode) {
      case Success(:final data):
        Navigator.of(context).pop(data);
      case Error():
        // Not an exact barcode → fall back to a name/barcode search.
        await _runSearch(code);
        _focusNode.requestFocus();
    }
  }

  /// Open the quick-create dialog (barcode/name pre-filled from the current
  /// query) so an unknown scanned drug can be added to the catalog on the spot.
  /// On success the picker closes returning the new product.
  Future<void> _createNew() async {
    final q = _queryController.text.trim();
    final isBarcode = q.isNotEmpty && RegExp(r'^\d{6,}$').hasMatch(q);
    final created = await QuickCreateProductDialog.show(
      context,
      barcode: isBarcode ? q : null,
      initialName: isBarcode || q.isEmpty ? null : q,
    );
    if (created != null && mounted) {
      Navigator.of(context).pop(created);
    } else if (mounted) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.productPickerTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _createNew,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l.productsNew),
                  ),
                  IconButton(
                    tooltip: l.commonClose,
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _queryController,
                focusNode: _focusNode,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: _onChanged,
                onSubmitted: _onSubmitted,
                decoration: InputDecoration(
                  hintText: l.productPickerSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              if (_isLoading) const LinearProgressIndicator(minHeight: 2),
              Expanded(child: _buildList(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_message != null && _results.isEmpty) {
      // Nothing matched — offer to create the (likely just-scanned) drug now,
      // so receiving never gets stuck on an unknown barcode.
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_message!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _createNew,
              icon: const Icon(Icons.add),
              label: Text(l.productPickerCreateNew),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final product = _results[index];
        return ListTile(
          dense: true,
          title: Text(product.name),
          subtitle: product.barcode == null ? null : Text(product.barcode!),
          trailing: product.rxRequired
              ? const Icon(Icons.medical_information_outlined, size: 18)
              : null,
          onTap: () => Navigator.of(context).pop(product),
        );
      },
    );
  }
}

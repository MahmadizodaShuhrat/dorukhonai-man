import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/entity_picker.dart';
import '../../reference/presentation/reference_providers.dart';
import '../data/product_models.dart';
import '../data/products_repository.dart';

/// Fast "create a drug on the fly" dialog used by the scanner flow: when a
/// scanned barcode is not yet in the catalog, the user can create the product
/// card right here (barcode pre-filled) instead of leaving to the Products
/// screen. On success it returns the created [Product] (with its server id).
///
/// Only the name is required; group/manufacturer/unit are optional and can be
/// refined later in the Products screen — the point is fast receiving.
class QuickCreateProductDialog extends ConsumerStatefulWidget {
  const QuickCreateProductDialog({super.key, this.barcode, this.initialName});

  /// Barcode to pre-fill (typically the just-scanned code).
  final String? barcode;

  /// Optional pre-filled name (e.g. a search term that found nothing).
  final String? initialName;

  /// Opens the dialog; resolves to the created [Product] or `null` if cancelled.
  static Future<Product?> show(
    BuildContext context, {
    String? barcode,
    String? initialName,
  }) {
    return showDialog<Product>(
      context: context,
      builder: (_) =>
          QuickCreateProductDialog(barcode: barcode, initialName: initialName),
    );
  }

  @override
  ConsumerState<QuickCreateProductDialog> createState() =>
      _QuickCreateProductDialogState();
}

class _QuickCreateProductDialogState
    extends ConsumerState<QuickCreateProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _barcodeController;
  final _minStockController = TextEditingController();

  String? _groupId;
  String? _manufacturerId;
  String? _unitId;
  bool _rxRequired = false;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _barcodeController = TextEditingController(text: widget.barcode ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final barcode = _barcodeController.text.trim();
    final minStock = double.tryParse(
      _minStockController.text.trim().replaceAll(',', '.'),
    );
    final product = Product(
      id: '',
      name: _nameController.text.trim(),
      barcode: barcode.isEmpty ? null : barcode,
      drugGroupId: _groupId,
      manufacturerId: _manufacturerId,
      unitId: _unitId,
      rxRequired: _rxRequired,
      isActive: true,
      minStockLevel: minStock,
    );
    final result = await ref.read(productsRepositoryProvider).create(product);
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        Navigator.of(context).pop(data);
      case Error(:final failure):
        setState(() {
          _saving = false;
          _error = failure.message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.quickCreateTitle),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l.quickCreateName,
                    hintText: l.quickCreateNameHint,
                    prefixIcon: const Icon(Icons.medication_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l.quickCreateNameRequired
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _barcodeController,
                  decoration: InputDecoration(
                    labelText: l.productBarcode,
                    prefixIcon: const Icon(Icons.qr_code_2),
                  ),
                ),
                const SizedBox(height: 12),
                EntityPicker(
                  label: l.quickCreateGroup,
                  icon: Icons.category_outlined,
                  optionsProvider: (s) => drugGroupOptionsProvider(s),
                  selectedId: _groupId,
                  onChanged: (id) => setState(() => _groupId = id),
                ),
                const SizedBox(height: 12),
                EntityPicker(
                  label: l.productManufacturer,
                  icon: Icons.factory_outlined,
                  optionsProvider: (s) => manufacturerOptionsProvider(s),
                  selectedId: _manufacturerId,
                  onChanged: (id) => setState(() => _manufacturerId = id),
                ),
                const SizedBox(height: 12),
                EntityPicker(
                  label: l.quickCreateUnit,
                  icon: Icons.straighten,
                  optionsProvider: (s) => unitOptionsProvider(s),
                  selectedId: _unitId,
                  onChanged: (id) => setState(() => _unitId = id),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _minStockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l.quickCreateMinStock,
                    prefixIcon: const Icon(Icons.inventory_2_outlined),
                  ),
                ),
                const SizedBox(height: 4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.quickCreateRx),
                  value: _rxRequired,
                  onChanged: (v) => setState(() => _rxRequired = v),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(l.commonCancel),
        ),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: Text(l.quickCreateSubmit),
        ),
      ],
    );
  }
}

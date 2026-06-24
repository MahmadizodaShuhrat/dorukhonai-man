import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/entity_picker.dart';
import '../../reference/presentation/reference_providers.dart';
import '../data/product_models.dart';
import 'products_provider.dart';

/// Create/edit form for a single [Product] (TZ §3.3). Validation: `name` is
/// required; `rxRequired` is a toggle. The FK fields (group/manufacturer/unit)
/// use an [EntityPicker] dropdown (name → id), replacing the old typed-GUID
/// `TextField`s (TZ_03 §C.5/P2).
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.product});

  /// `null` → create mode; non-null → edit mode.
  final Product? product;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _barcode;

  // FK selections (ids) — populated via EntityPicker, not typed.
  String? _drugGroupId;
  String? _manufacturerId;
  String? _unitId;

  late bool _rxRequired;
  late bool _isActive;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _barcode = TextEditingController(text: p?.barcode ?? '');
    _drugGroupId = p?.drugGroupId;
    _manufacturerId = p?.manufacturerId;
    _unitId = p?.unitId;
    _rxRequired = p?.rxRequired ?? false;
    _isActive = p?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _barcode.dispose();
    super.dispose();
  }

  /// Returns trimmed text or `null` when empty (for nullable contract fields).
  String? _nullIfEmpty(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Product _buildProduct() {
    return Product(
      id: widget.product?.id ?? '',
      name: _name.text.trim(),
      barcode: _nullIfEmpty(_barcode.text),
      drugGroupId: _drugGroupId,
      manufacturerId: _manufacturerId,
      unitId: _unitId,
      rxRequired: _rxRequired,
      isActive: _isActive,
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final controller = ref.read(productFormControllerProvider.notifier);
    final product = _buildProduct();
    final result = _isEditing
        ? await controller.update(product)
        : await controller.create(product);

    if (!mounted) return;
    final l = AppLocalizations.of(context);
    switch (result) {
      case ProductSaveSuccess():
        _showSnack(_isEditing ? l.productUpdated : l.productCreated);
        Navigator.of(context).pop();
      case ProductSaveFailure(:final failure):
        _showSnack(failure.message, isError: true);
    }
  }

  Future<void> _confirmDelete() async {
    final product = widget.product;
    if (product == null) return;

    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.productDeleteTitle),
        content: Text(l.productDeleteBody(product.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result =
        await ref.read(productFormControllerProvider.notifier).delete(product.id);
    if (!mounted) return;
    final l2 = AppLocalizations.of(context);
    switch (result) {
      case ProductSaveSuccess():
        _showSnack(l2.productDeleted);
        Navigator.of(context).pop();
      case ProductSaveFailure(:final failure):
        _showSnack(failure.message, isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isSaving = ref.watch(productFormControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l.productEditTitle : l.productNewTitle),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: l.commonDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: isSaving ? null : _confirmDelete,
            ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: isSaving,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _name,
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l.productName,
                        prefixIcon: const Icon(Icons.medication),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l.productValName
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _barcode,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l.productBarcode,
                        prefixIcon: const Icon(Icons.qr_code),
                      ),
                    ),
                    const SizedBox(height: 16),
                    EntityPicker(
                      label: l.productGroup,
                      icon: Icons.category_outlined,
                      optionsProvider: (s) => drugGroupOptionsProvider(s),
                      selectedId: _drugGroupId,
                      onChanged: (id) => setState(() => _drugGroupId = id),
                    ),
                    const SizedBox(height: 16),
                    EntityPicker(
                      label: l.productManufacturer,
                      icon: Icons.factory_outlined,
                      optionsProvider: (s) => manufacturerOptionsProvider(s),
                      selectedId: _manufacturerId,
                      onChanged: (id) => setState(() => _manufacturerId = id),
                    ),
                    const SizedBox(height: 16),
                    EntityPicker(
                      label: l.productUnit,
                      icon: Icons.straighten,
                      optionsProvider: (s) => unitOptionsProvider(s),
                      selectedId: _unitId,
                      onChanged: (id) => setState(() => _unitId = id),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: Text(l.productRx),
                      subtitle: Text(l.productRxSubtitle),
                      value: _rxRequired,
                      onChanged: (v) => setState(() => _rxRequired = v),
                    ),
                    SwitchListTile(
                      title: Text(l.productActiveLabel),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: isSaving ? null : _save,
                      icon: isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isEditing ? l.commonSave : l.productCreate),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

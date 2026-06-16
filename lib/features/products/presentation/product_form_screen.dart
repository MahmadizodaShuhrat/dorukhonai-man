import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/product_models.dart';
import 'products_provider.dart';

/// Create/edit form for a single [Product] (TZ §3.3). Validation: `name` is
/// required; `rxRequired` is a toggle; `barcode` and the FK ids
/// (group/manufacturer/unit) are optional free-text for now (selectors land
/// once those reference lists exist in the UI).
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
  late final TextEditingController _drugGroupId;
  late final TextEditingController _manufacturerId;
  late final TextEditingController _unitId;

  late bool _rxRequired;
  late bool _isActive;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _barcode = TextEditingController(text: p?.barcode ?? '');
    _drugGroupId = TextEditingController(text: p?.drugGroupId ?? '');
    _manufacturerId = TextEditingController(text: p?.manufacturerId ?? '');
    _unitId = TextEditingController(text: p?.unitId ?? '');
    _rxRequired = p?.rxRequired ?? false;
    _isActive = p?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _barcode.dispose();
    _drugGroupId.dispose();
    _manufacturerId.dispose();
    _unitId.dispose();
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
      drugGroupId: _nullIfEmpty(_drugGroupId.text),
      manufacturerId: _nullIfEmpty(_manufacturerId.text),
      unitId: _nullIfEmpty(_unitId.text),
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
    switch (result) {
      case ProductSaveSuccess():
        _showSnack(_isEditing ? 'Дору навсозӣ шуд' : 'Дору сохта шуд');
        Navigator.of(context).pop();
      case ProductSaveFailure(:final failure):
        _showSnack(failure.message, isError: true);
    }
  }

  Future<void> _confirmDelete() async {
    final product = widget.product;
    if (product == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ҳазфи дору'),
        content: Text('«${product.name}» ҳазф карда шавад?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Бекор'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Ҳазф'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result =
        await ref.read(productFormControllerProvider.notifier).delete(product.id);
    if (!mounted) return;
    switch (result) {
      case ProductSaveSuccess():
        _showSnack('Дору ҳазф шуд');
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
    final isSaving = ref.watch(productFormControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Таҳрири дору' : 'Дору нав'),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Ҳазф',
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
                      decoration: const InputDecoration(
                        labelText: 'Ном *',
                        prefixIcon: Icon(Icons.medication),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Номи доруро ворид кунед'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _barcode,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Штрих-код',
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _drugGroupId,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Гурӯҳи дору (ID)',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _manufacturerId,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Истеҳсолкунанда (ID)',
                        prefixIcon: Icon(Icons.factory_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _unitId,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Воҳиди ченак (ID)',
                        prefixIcon: Icon(Icons.straighten),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Доруи ретсептӣ'),
                      subtitle: const Text('Фурӯш бо ретсепт'),
                      value: _rxRequired,
                      onChanged: (v) => setState(() => _rxRequired = v),
                    ),
                    SwitchListTile(
                      title: const Text('Фаъол'),
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
                      label: Text(_isEditing ? 'Нигоҳ доштан' : 'Сохтан'),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/app_toast.dart';
import '../../../shared/entity_picker.dart';
import '../../../shared/primary_button.dart';
import '../../reference/presentation/reference_providers.dart';
import '../../reference/presentation/widgets/side_panel.dart';
import '../data/product_models.dart';
import 'products_provider.dart';

/// Side-panel create/edit editor for a single [Product] (TZ_03 §C.5). Docked at
/// 380px to the right of the products table (NOT a bare dialog). FK fields
/// (group / manufacturer / unit) use [EntityPicker] (name → id); plus barcode,
/// rxRequired / isActive toggles and minStockLevel.
class ProductEditorPanel extends ConsumerStatefulWidget {
  const ProductEditorPanel({
    super.key,
    required this.product,
    required this.onDone,
  });

  /// `null` → create mode; non-null → edit mode.
  final Product? product;

  /// Called after a successful save/delete to close the panel.
  final VoidCallback onDone;

  @override
  ConsumerState<ProductEditorPanel> createState() =>
      _ProductEditorPanelState();
}

class _ProductEditorPanelState extends ConsumerState<ProductEditorPanel> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _barcode;
  late final TextEditingController _minStock;

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
    _minStock = TextEditingController(
      text: p?.minStockLevel == null ? '' : _trimZeros(p!.minStockLevel!),
    );
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
    _minStock.dispose();
    super.dispose();
  }

  static String _trimZeros(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }

  String? _nullIfEmpty(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  double? _parseMinStock() {
    final t = _minStock.text.trim().replaceAll(',', '.');
    if (t.isEmpty) return null;
    return double.tryParse(t);
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
      minStockLevel: _parseMinStock(),
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
        AppToast.success(
          context,
          _isEditing ? 'Дору навсозӣ шуд' : 'Дору сохта шуд',
        );
        widget.onDone();
      case ProductSaveFailure(:final failure):
        AppToast.error(context, failure.message);
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
        AppToast.success(context, 'Дору ҳазф шуд');
        widget.onDone();
      case ProductSaveFailure(:final failure):
        AppToast.error(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(productFormControllerProvider);

    return SidePanel(
      title: _isEditing ? 'Таҳрири дору' : 'Дору нав',
      subtitle: _isEditing ? widget.product!.name : null,
      onClose: widget.onDone,
      child: AbsorbPointer(
        absorbing: isSaving,
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
                  prefixIcon: Icon(Icons.medication_outlined),
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
              EntityPicker(
                label: 'Гурӯҳи дору',
                icon: Icons.category_outlined,
                optionsProvider: (s) => drugGroupOptionsProvider(s),
                selectedId: _drugGroupId,
                onChanged: (id) => setState(() => _drugGroupId = id),
              ),
              const SizedBox(height: 16),
              EntityPicker(
                label: 'Истеҳсолкунанда',
                icon: Icons.factory_outlined,
                optionsProvider: (s) => manufacturerOptionsProvider(s),
                selectedId: _manufacturerId,
                onChanged: (id) => setState(() => _manufacturerId = id),
              ),
              const SizedBox(height: 16),
              EntityPicker(
                label: 'Воҳиди ченак',
                icon: Icons.straighten_outlined,
                optionsProvider: (s) => unitOptionsProvider(s),
                selectedId: _unitId,
                onChanged: (id) => setState(() => _unitId = id),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _minStock,
                textInputAction: TextInputAction.done,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Минималии бақия',
                  helperText: 'Зери ин — «камшуда»',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                onFieldSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Доруи ретсептӣ'),
                subtitle: const Text('Фурӯш бо ретсепт'),
                value: _rxRequired,
                onChanged: (v) => setState(() => _rxRequired = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Фаъол'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: _isEditing ? 'Нигоҳ доштан' : 'Сохтан',
                icon: Icons.save_outlined,
                isLoading: isSaving,
                onPressed: _save,
              ),
              if (_isEditing) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: isSaving ? null : _confirmDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Ғайрифаъол кардан / Ҳазф'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

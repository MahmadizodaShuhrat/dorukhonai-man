import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../products/data/product_models.dart';
import 'reference_list_provider.dart';
import 'widgets/reference_list_view.dart';

/// Suppliers reference screen (TZ_03 §C.5): list + side-panel editor.
class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ReferenceListView<Supplier>(
      title: l.refSuppliersTitle,
      icon: Icons.local_shipping_outlined,
      newButtonLabel: l.refSupplierNew,
      searchHint: l.refSupplierSearchHint,
      emptyMessage: l.refSupplierEmpty,
      entityName: l.refSupplierEntity,
      provider: suppliersListControllerProvider,
      columns: [
        DataColumn2(label: Text(l.refColName), size: ColumnSize.L),
        DataColumn2(label: Text(l.refColInn)),
        DataColumn2(label: Text(l.refColPhone)),
      ],
      cells: (context, s) => [
        DataCell(Text(s.name)),
        DataCell(Text(s.inn ?? '—')),
        DataCell(Text(s.phone ?? '—')),
      ],
      editorBuilder: (context, item, onDone) =>
          _SupplierEditor(item: item, onDone: onDone),
    );
  }
}

class _SupplierEditor extends ConsumerStatefulWidget {
  const _SupplierEditor({required this.item, required this.onDone});

  final Supplier? item;
  final VoidCallback onDone;

  @override
  ConsumerState<_SupplierEditor> createState() => _SupplierEditorState();
}

class _SupplierEditorState extends ConsumerState<_SupplierEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _inn;
  late final TextEditingController _phone;
  late final TextEditingController _address;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.item?.name ?? '');
    _inn = TextEditingController(text: widget.item?.inn ?? '');
    _phone = TextEditingController(text: widget.item?.phone ?? '');
    _address = TextEditingController(text: widget.item?.address ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _inn.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  String? _nullIfEmpty(String v) {
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  ReferenceListController<Supplier> get _controller =>
      ref.read(suppliersListControllerProvider.notifier);

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final value = Supplier(
      id: widget.item?.id ?? '',
      name: _name.text.trim(),
      inn: _nullIfEmpty(_inn.text),
      phone: _nullIfEmpty(_phone.text),
      address: _nullIfEmpty(_address.text),
    );
    final result = _isEditing
        ? await _controller.update(value)
        : await _controller.create(value);
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    handleReferenceSave(
      context,
      result,
      successMessage: _isEditing ? l.refSupplierUpdated : l.refSupplierCreated,
      onSuccess: widget.onDone,
    );
  }

  Future<void> _delete() async {
    final item = widget.item;
    if (item == null) return;
    if (!await confirmReferenceDelete(context, item.name)) return;
    final result = await _controller.delete(item.id);
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    handleReferenceSave(
      context,
      result,
      successMessage: l.refSupplierDeleted,
      onSuccess: widget.onDone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isSaving = ref.watch(
      suppliersListControllerProvider.select((s) => s.isSaving),
    );
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _name,
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l.refFieldName,
              prefixIcon: const Icon(Icons.local_shipping_outlined),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.refSupplierValName : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _inn,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l.refColInn,
              prefixIcon: const Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phone,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l.refColPhone,
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _address,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l.refFieldAddress,
              prefixIcon: const Icon(Icons.location_on_outlined),
            ),
            onFieldSubmitted: (_) => _save(),
          ),
          ReferenceEditorActions(
            isSaving: isSaving,
            isEditing: _isEditing,
            onSave: _save,
            onDelete: _delete,
          ),
        ],
      ),
    );
  }
}

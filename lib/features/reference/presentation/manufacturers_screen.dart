import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../products/data/product_models.dart';
import 'reference_list_provider.dart';
import 'widgets/reference_list_view.dart';

/// Manufacturers reference screen (TZ_03 §C.5): list + side-panel editor.
class ManufacturersScreen extends StatelessWidget {
  const ManufacturersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ReferenceListView<Manufacturer>(
      title: l.refManufacturersTitle,
      icon: Icons.factory_outlined,
      newButtonLabel: l.refManufacturerNew,
      searchHint: l.refManufacturerSearchHint,
      emptyMessage: l.refManufacturerEmpty,
      entityName: l.refManufacturerEntity,
      provider: manufacturersListControllerProvider,
      columns: [
        DataColumn2(label: Text(l.refColName), size: ColumnSize.L),
        DataColumn2(label: Text(l.refColCountry)),
      ],
      cells: (context, m) => [
        DataCell(Text(m.name)),
        DataCell(Text(m.country ?? '—')),
      ],
      editorBuilder: (context, item, onDone) =>
          _ManufacturerEditor(item: item, onDone: onDone),
    );
  }
}

class _ManufacturerEditor extends ConsumerStatefulWidget {
  const _ManufacturerEditor({required this.item, required this.onDone});

  final Manufacturer? item;
  final VoidCallback onDone;

  @override
  ConsumerState<_ManufacturerEditor> createState() =>
      _ManufacturerEditorState();
}

class _ManufacturerEditorState extends ConsumerState<_ManufacturerEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _country;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.item?.name ?? '');
    _country = TextEditingController(text: widget.item?.country ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _country.dispose();
    super.dispose();
  }

  String? _nullIfEmpty(String v) {
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  ReferenceListController<Manufacturer> get _controller =>
      ref.read(manufacturersListControllerProvider.notifier);

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final value = Manufacturer(
      id: widget.item?.id ?? '',
      name: _name.text.trim(),
      country: _nullIfEmpty(_country.text),
    );
    final result = _isEditing
        ? await _controller.update(value)
        : await _controller.create(value);
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    handleReferenceSave(
      context,
      result,
      successMessage: _isEditing
          ? l.refManufacturerUpdated
          : l.refManufacturerCreated,
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
      successMessage: l.refManufacturerDeleted,
      onSuccess: widget.onDone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isSaving = ref.watch(
      manufacturersListControllerProvider.select((s) => s.isSaving),
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
              prefixIcon: const Icon(Icons.factory_outlined),
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? l.refManufacturerValName
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _country,
            decoration: InputDecoration(
              labelText: l.refColCountry,
              prefixIcon: const Icon(Icons.public_outlined),
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

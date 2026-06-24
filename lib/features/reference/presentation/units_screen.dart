import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../products/data/product_models.dart';
import 'reference_list_provider.dart';
import 'widgets/reference_list_view.dart';

/// Units-of-measure reference screen (TZ_03 §C.5): list + side-panel editor.
class UnitsScreen extends StatelessWidget {
  const UnitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ReferenceListView<Unit>(
      title: l.refUnitsTitle,
      icon: Icons.straighten_outlined,
      newButtonLabel: l.refUnitNew,
      searchHint: l.refUnitSearchHint,
      emptyMessage: l.refUnitEmpty,
      entityName: l.refUnitEntity,
      provider: unitsListControllerProvider,
      columns: [
        DataColumn2(label: Text(l.refColName), size: ColumnSize.L),
      ],
      cells: (context, u) => [DataCell(Text(u.name))],
      editorBuilder: (context, item, onDone) =>
          _UnitEditor(item: item, onDone: onDone),
    );
  }
}

class _UnitEditor extends ConsumerStatefulWidget {
  const _UnitEditor({required this.item, required this.onDone});

  final Unit? item;
  final VoidCallback onDone;

  @override
  ConsumerState<_UnitEditor> createState() => _UnitEditorState();
}

class _UnitEditorState extends ConsumerState<_UnitEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.item?.name ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  ReferenceListController<Unit> get _controller =>
      ref.read(unitsListControllerProvider.notifier);

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final value = Unit(id: widget.item?.id ?? '', name: _name.text.trim());
    final result = _isEditing
        ? await _controller.update(value)
        : await _controller.create(value);
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    handleReferenceSave(
      context,
      result,
      successMessage: _isEditing ? l.refUnitUpdated : l.refUnitCreated,
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
      successMessage: l.refUnitDeleted,
      onSuccess: widget.onDone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isSaving = ref.watch(
      unitsListControllerProvider.select((s) => s.isSaving),
    );
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _name,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l.refFieldName,
              prefixIcon: const Icon(Icons.straighten_outlined),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.refUnitValName : null,
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

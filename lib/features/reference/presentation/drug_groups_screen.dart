import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../products/data/product_models.dart';
import 'reference_list_provider.dart';
import 'widgets/reference_list_view.dart';

/// Drug-groups reference screen (TZ_03 §C.5): list + side-panel editor.
class DrugGroupsScreen extends StatelessWidget {
  const DrugGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ReferenceListView<DrugGroup>(
      title: l.refGroupsTitle,
      icon: Icons.category_outlined,
      newButtonLabel: l.refGroupNew,
      searchHint: l.refGroupSearchHint,
      emptyMessage: l.refGroupEmpty,
      entityName: l.refGroupEntity,
      provider: drugGroupsListControllerProvider,
      columns: [
        DataColumn2(label: Text(l.refColName), size: ColumnSize.L),
      ],
      cells: (context, g) => [DataCell(Text(g.name))],
      editorBuilder: (context, item, onDone) =>
          _DrugGroupEditor(item: item, onDone: onDone),
    );
  }
}

class _DrugGroupEditor extends ConsumerStatefulWidget {
  const _DrugGroupEditor({required this.item, required this.onDone});

  final DrugGroup? item;
  final VoidCallback onDone;

  @override
  ConsumerState<_DrugGroupEditor> createState() => _DrugGroupEditorState();
}

class _DrugGroupEditorState extends ConsumerState<_DrugGroupEditor> {
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

  ReferenceListController<DrugGroup> get _controller =>
      ref.read(drugGroupsListControllerProvider.notifier);

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final value = DrugGroup(
      id: widget.item?.id ?? '',
      name: _name.text.trim(),
      parentId: widget.item?.parentId,
    );
    final result = _isEditing
        ? await _controller.update(value)
        : await _controller.create(value);
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    handleReferenceSave(
      context,
      result,
      successMessage: _isEditing ? l.refGroupUpdated : l.refGroupCreated,
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
      successMessage: l.refGroupDeleted,
      onSuccess: widget.onDone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isSaving = ref.watch(
      drugGroupsListControllerProvider.select((s) => s.isSaving),
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
              prefixIcon: const Icon(Icons.category_outlined),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.refGroupValName : null,
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

import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/app_data_table.dart';
import '../../../../shared/app_scaffold.dart';
import '../../../../shared/app_toast.dart';
import '../../../../shared/primary_button.dart';
import '../reference_list_provider.dart';
import 'side_panel.dart';

/// Generic list + side-panel editor for a single reference entity (TZ_03
/// §C.5). Renders an [AppScaffold] page header (icon/title + "+ Нав" action),
/// a search field, an [AppDataTable] on the left, and a 380px [SidePanel]
/// editor on the right (open via "+ Нав" for create, or a row tap for edit).
///
/// All four reference screens share this; only the columns and the editor form
/// differ, supplied via [columns]/[cells] and [editorBuilder].
class ReferenceListView<T> extends ConsumerStatefulWidget {
  const ReferenceListView({
    super.key,
    required this.title,
    required this.icon,
    required this.newButtonLabel,
    required this.searchHint,
    required this.emptyMessage,
    required this.provider,
    required this.columns,
    required this.cells,
    required this.editorBuilder,
    required this.entityName,
  });

  final String title;
  final IconData icon;
  final String newButtonLabel;
  final String searchHint;
  final String emptyMessage;

  /// The per-entity list controller provider.
  final StateNotifierProvider<ReferenceListController<T>,
      ReferenceListState<T>> provider;

  /// Table column headers.
  final List<DataColumn2> columns;

  /// Builds the cells for one row.
  final List<DataCell> Function(BuildContext context, T item) cells;

  /// Builds the side-panel editor body for [item] (`null` = create). Should
  /// call [onDone] after a successful save/delete to close the panel.
  final Widget Function(
    BuildContext context,
    T? item,
    VoidCallback onDone,
  ) editorBuilder;

  /// Singular entity name for the editor header ("нав" / "таҳрир").
  final String entityName;

  @override
  ConsumerState<ReferenceListView<T>> createState() =>
      _ReferenceListViewState<T>();
}

class _ReferenceListViewState<T> extends ConsumerState<ReferenceListView<T>> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  /// `null` = panel closed; sentinel `_creating` = create; otherwise edit.
  bool _editorOpen = false;
  T? _editing;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(widget.provider.notifier).search(value);
    });
  }

  void _openCreate() => setState(() {
    _editing = null;
    _editorOpen = true;
  });

  void _openEdit(T item) => setState(() {
    _editing = item;
    _editorOpen = true;
  });

  void _closePanel() => setState(() => _editorOpen = false);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.provider);
    final controller = ref.read(widget.provider.notifier);

    return AppScaffold(
      title: widget.title,
      icon: widget.icon,
      subtitle: 'Ҳамагӣ: ${state.total}',
      actions: [
        PrimaryButton(
          label: widget.newButtonLabel,
          icon: Icons.add,
          expand: false,
          onPressed: _openCreate,
        ),
      ],
      padBody: false,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SearchField(
                    controller: _searchController,
                    hint: widget.searchHint,
                    onChanged: _onSearchChanged,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Stack(
                      children: [
                        AppDataTable(
                          minWidth: 640,
                          isLoading: state.isLoading,
                          emptyMessage: widget.emptyMessage,
                          emptyIcon: widget.icon,
                          errorMessage:
                              state.failure != null && state.items.isEmpty
                              ? state.failure!.message
                              : null,
                          onRetry: controller.refresh,
                          columns: widget.columns,
                          rows: [
                            for (final item in state.items)
                              DataRow2(
                                onTap: () => _openEdit(item),
                                cells: widget.cells(context, item),
                              ),
                          ],
                        ),
                        if (state.isLoading && state.items.isNotEmpty)
                          const Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: LinearProgressIndicator(minHeight: 2),
                          ),
                      ],
                    ),
                  ),
                  _PaginationBar(
                    page: state.page,
                    pageCount: state.pageCount,
                    hasPrevious: state.hasPrevious && !state.isLoading,
                    hasNext: state.hasNext && !state.isLoading,
                    onPrevious: controller.previousPage,
                    onNext: controller.nextPage,
                  ),
                ],
              ),
            ),
          ),
          if (_editorOpen)
            SidePanel(
              title: _editing == null
                  ? '${widget.entityName} нав'
                  : 'Таҳрири ${widget.entityName}',
              onClose: _closePanel,
              child: widget.editorBuilder(context, _editing, _closePanel),
            ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.page,
    required this.pageCount,
    required this.hasPrevious,
    required this.hasNext,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int pageCount;
  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            tooltip: 'Қаблӣ',
            icon: const Icon(Icons.chevron_left),
            onPressed: hasPrevious ? onPrevious : null,
          ),
          Text('$page / $pageCount'),
          IconButton(
            tooltip: 'Баъдӣ',
            icon: const Icon(Icons.chevron_right),
            onPressed: hasNext ? onNext : null,
          ),
        ],
      ),
    );
  }
}

/// Shared editor footer: a save button (with busy spinner) and, in edit mode,
/// a delete button. Used by every reference editor form.
class ReferenceEditorActions extends StatelessWidget {
  const ReferenceEditorActions({
    super.key,
    required this.isSaving,
    required this.isEditing,
    required this.onSave,
    this.onDelete,
  });

  final bool isSaving;
  final bool isEditing;
  final VoidCallback onSave;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        PrimaryButton(
          label: isEditing ? 'Нигоҳ доштан' : 'Сохтан',
          icon: Icons.save_outlined,
          isLoading: isSaving,
          onPressed: onSave,
        ),
        if (isEditing && onDelete != null) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: isSaving ? null : onDelete,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Ҳазф'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

/// Shared confirm dialog for reference deletes.
Future<bool> confirmReferenceDelete(
  BuildContext context,
  String name,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Ҳазф'),
      content: Text('«$name» ҳазф карда шавад?'),
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
  return confirmed ?? false;
}

/// Maps a [ReferenceSaveResult] to a toast + panel close on success.
void handleReferenceSave(
  BuildContext context,
  ReferenceSaveResult result, {
  required String successMessage,
  required VoidCallback onSuccess,
}) {
  switch (result) {
    case ReferenceSaveSuccess():
      AppToast.success(context, successMessage);
      onSuccess();
    case ReferenceSaveFailure(:final failure):
      AppToast.error(context, failure.message);
  }
}

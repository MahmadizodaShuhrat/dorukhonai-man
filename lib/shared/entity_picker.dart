import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_result.dart';
import '../features/reference/presentation/reference_providers.dart';
import '../l10n/app_localizations.dart';

/// Reusable searchable reference-data picker (TZ_03 §C.5/P2). Shows entity
/// NAMES in a typeahead dropdown and yields the selected id via [onChanged] —
/// replacing the old typed-GUID `TextField`s.
///
/// Backed by a `FutureProvider.family<List<EntityOption>, String>` (the search
/// term). Options load lazily when the field opens; selecting one stores its
/// id while displaying its label.
class EntityPicker extends ConsumerStatefulWidget {
  const EntityPicker({
    super.key,
    required this.label,
    required this.optionsProvider,
    required this.selectedId,
    required this.onChanged,
    this.icon,
    this.enabled = true,
    this.isRequired = false,
  });

  /// Field label (e.g. "Гурӯҳи дору").
  final String label;

  /// The provider family that loads options for a given search term.
  final ProviderBase<AsyncValue<List<EntityOption>>> Function(String search)
  optionsProvider;

  /// Currently-selected entity id (`null` when nothing chosen).
  final String? selectedId;

  /// Emits the chosen id, or `null` when cleared.
  final ValueChanged<String?> onChanged;

  final IconData? icon;
  final bool enabled;

  /// When true, shows a validation error if nothing is selected (used inside a
  /// [Form] via the internal [FormField]).
  final bool isRequired;

  @override
  ConsumerState<EntityPicker> createState() => _EntityPickerState();
}

class _EntityPickerState extends ConsumerState<EntityPicker> {
  /// Cached label for the current [selectedId], resolved as options load so
  /// the field shows a name (not a GUID) immediately in edit mode.
  String? _resolvedLabel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Watch the unfiltered list to resolve the current selection's label.
    final all = ref.watch(widget.optionsProvider(''));
    all.whenData((options) {
      final match = findOptionById(options, widget.selectedId);
      if (match != null && match.label != _resolvedLabel) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _resolvedLabel = match.label);
        });
      }
    });

    final displayText = widget.selectedId == null
        ? null
        : (_resolvedLabel ?? widget.selectedId);

    return FormField<String>(
      initialValue: widget.selectedId,
      validator: (_) {
        if (widget.isRequired &&
            (widget.selectedId == null || widget.selectedId!.isEmpty)) {
          return l.refPickerSelect(widget.label);
        }
        return null;
      },
      builder: (state) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: widget.isRequired ? '${widget.label} *' : widget.label,
            prefixIcon: widget.icon == null ? null : Icon(widget.icon),
            errorText: state.errorText,
            suffixIcon: const Icon(Icons.arrow_drop_down),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          isEmpty: displayText == null,
          child: InkWell(
            onTap: widget.enabled
                ? () async {
                    final picked = await _openSearch(context);
                    if (picked == null) return;
                    setState(() => _resolvedLabel = picked.label);
                    state.didChange(picked.id);
                    widget.onChanged(picked.id);
                  }
                : null,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText ?? '',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.selectedId != null && widget.enabled)
                  GestureDetector(
                    onTap: () {
                      setState(() => _resolvedLabel = null);
                      state.didChange(null);
                      widget.onChanged(null);
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(Icons.clear, size: 16),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<EntityOption?> _openSearch(BuildContext context) {
    return showDialog<EntityOption>(
      context: context,
      builder: (_) => _EntitySearchDialog(
        title: widget.label,
        optionsProvider: widget.optionsProvider,
      ),
    );
  }
}

/// Modal search list for the picker: a debounced search field over a scrolling
/// list of options.
class _EntitySearchDialog extends ConsumerStatefulWidget {
  const _EntitySearchDialog({
    required this.title,
    required this.optionsProvider,
  });

  final String title;
  final ProviderBase<AsyncValue<List<EntityOption>>> Function(String search)
  optionsProvider;

  @override
  ConsumerState<_EntitySearchDialog> createState() =>
      _EntitySearchDialogState();
}

class _EntitySearchDialogState extends ConsumerState<_EntitySearchDialog> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(widget.optionsProvider(_search));
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 420,
        height: 420,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: l.refSearchHint,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: async.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Text(
                    err is Failure ? err.message : l.refLoadError,
                    textAlign: TextAlign.center,
                  ),
                ),
                data: (options) {
                  if (options.isEmpty) {
                    return Center(child: Text(l.commandNothingFound));
                  }
                  return ListView.builder(
                    itemCount: options.length,
                    itemBuilder: (context, i) {
                      final o = options[i];
                      return ListTile(
                        dense: true,
                        title: Text(o.label),
                        subtitle: o.sublabel == null
                            ? null
                            : Text(o.sublabel!),
                        onTap: () => Navigator.of(context).pop(o),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.commonCancel),
        ),
      ],
    );
  }
}

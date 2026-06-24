import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../stock/data/stock_models.dart';
import '../../stock/data/stock_repository.dart';

/// A reusable modal stock-batch picker for the MODUL 6 editors (Списание /
/// Инвентаризатсия / Бозгашт). Searches on-hand stock (`GET /stock?search=`) and
/// returns the chosen [StockItem] (which carries `batchId`, `seriesNumber`,
/// `quantity` on-hand) via `Navigator.pop`, or `null` if cancelled.
///
/// Mirrors [ProductPickerDialog] but yields a batch (a product may have several
/// batches in stock, each a distinct write-off/return/count target).
class BatchPickerDialog extends ConsumerStatefulWidget {
  const BatchPickerDialog({super.key, this.branchId});

  /// Branch to scope the stock query to (the resolved session branch).
  final String? branchId;

  static Future<StockItem?> show(BuildContext context, {String? branchId}) {
    return showDialog<StockItem>(
      context: context,
      builder: (_) => BatchPickerDialog(branchId: branchId),
    );
  }

  @override
  ConsumerState<BatchPickerDialog> createState() => _BatchPickerDialogState();
}

class _BatchPickerDialogState extends ConsumerState<BatchPickerDialog> {
  final _queryController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  List<StockItem> _results = const [];
  bool _isLoading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
    _runSearch('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _runSearch(value),
    );
  }

  Future<void> _runSearch(String term) async {
    final repo = ref.read(stockRepositoryProvider);
    setState(() {
      _isLoading = true;
      _message = null;
    });
    final result = await repo.list(
      branchId: widget.branchId,
      search: term,
      page: 1,
      size: 25,
    );
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    switch (result) {
      case Success(:final data):
        setState(() {
          _results = data.items;
          _isLoading = false;
          _message = data.items.isEmpty ? l.batchPickerEmpty : null;
        });
      case Error(:final failure):
        setState(() {
          _results = const [];
          _isLoading = false;
          _message = failure.message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.batchPickerTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l.commonClose,
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _queryController,
                focusNode: _focusNode,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: _onChanged,
                decoration: InputDecoration(
                  hintText: l.batchPickerSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              if (_isLoading) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: (_message != null && _results.isEmpty)
                    ? Center(child: Text(_message!))
                    : ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _results[index];
                          return ListTile(
                            dense: true,
                            title: Text(item.productName),
                            subtitle: Text(
                              l.batchPickerSubtitle(
                                item.seriesNumber,
                                Formatters.date(item.expiryDate),
                              ),
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: Text(
                              l.batchPickerRemaining(_qty(item.quantity)),
                              style: theme.textTheme.bodySmall,
                            ),
                            onTap: () => Navigator.of(context).pop(item),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _qty(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';
}

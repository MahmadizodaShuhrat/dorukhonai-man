import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'empty_state.dart';
import 'loading_state.dart';

/// Styled wrapper over [DataTable2] (TZ_03 §B.6): sticky header, dense rows,
/// hairline dividers, hover highlight, optional pinned-left column, and
/// built-in empty/loading/error states.
///
/// Columns and rows use the standard [DataColumn2]/[DataRow2] API so existing
/// call sites move over with minimal change.
class AppDataTable extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.minWidth = 720,
    this.fixedLeftColumns = 0,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
    this.sortColumnIndex,
    this.sortAscending = true,
  });

  final List<DataColumn2> columns;
  final List<DataRow2> rows;
  final double minWidth;

  /// Number of leftmost columns to pin while scrolling horizontally.
  final int fixedLeftColumns;

  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  /// Empty-state message; falls back to a localized "no data" when `null`.
  final String? emptyMessage;
  final IconData emptyIcon;
  final int? sortColumnIndex;
  final bool sortAscending;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (isLoading && rows.isEmpty) {
      return const LoadingState();
    }
    if (errorMessage != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: l.commonError,
        message: errorMessage!,
        action: onRetry == null
            ? null
            : FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l.commonRetry),
              ),
      );
    }
    if (rows.isEmpty) {
      return EmptyState(icon: emptyIcon, message: emptyMessage ?? l.commonNoData);
    }

    final theme = Theme.of(context);
    return DataTable2(
      minWidth: minWidth,
      fixedTopRows: 1,
      fixedLeftColumns: fixedLeftColumns,
      headingRowColor: WidgetStatePropertyAll(
        theme.colorScheme.surfaceContainer,
      ),
      headingRowHeight: 40,
      dataRowHeight: 40,
      headingRowDecoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      dividerThickness: 1,
      showCheckboxColumn: false,
      sortColumnIndex: sortColumnIndex,
      sortAscending: sortAscending,
      columns: columns,
      rows: rows,
    );
  }
}

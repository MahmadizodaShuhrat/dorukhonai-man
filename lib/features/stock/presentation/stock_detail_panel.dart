import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/status_colors.dart';
import '../../../core/api/api_result.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/status_chip.dart';
import '../data/stock_models.dart';
import 'stock_provider.dart';
import 'stock_screen.dart';

/// Master-detail side panel (TZ_03 §C.3, fixed 380px) for a selected product.
///
/// Shows the product header, its on-hand batches (pulled from the currently
/// loaded «Бақия» page), and its movement ledger (`/stock/movements`) with
/// human-readable [MovementType] labels. Selecting a row never navigates away —
/// it just rebuilds this panel, preserving the table context.
class StockDetailPanel extends ConsumerWidget {
  const StockDetailPanel({
    super.key,
    required this.selection,
    required this.onClose,
  });

  final StockSelection selection;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Batches for this product, taken from the loaded on-hand page (no extra
    // endpoint — the contract has no per-product batch list).
    final batches = [
      for (final s in ref.watch(stockListControllerProvider).items)
        if (s.productId == selection.productId) s,
    ];
    final movements = ref.watch(stockMovementsProvider(selection.productId));

    return SizedBox(
      width: 380,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: product name + close.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selection.productName,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Пӯшидан',
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                _SectionLabel(text: 'Партияҳо (${batches.length})'),
                const SizedBox(height: 8),
                if (batches.isEmpty)
                  Text(
                    'Дар саҳифаи ҷорӣ партия нест.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  for (final b in batches) _BatchTile(item: b),
                const SizedBox(height: 20),
                _SectionLabel(text: 'Ҳаракати дору'),
                const SizedBox(height: 8),
                movements.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => _MovementsError(
                    message: err is Failure ? err.message : err.toString(),
                    onRetry: () => ref.invalidate(
                      stockMovementsProvider(selection.productId),
                    ),
                  ),
                  data: (list) => list.isEmpty
                      ? Text(
                          'Ҳаракат нест',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : Column(
                          children: [
                            for (final m in list) _MovementTile(movement: m),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A single on-hand batch row inside the panel: series + expiry chip + qty.
class _BatchTile extends StatelessWidget {
  const _BatchTile({required this.item});

  final StockItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = item.daysUntilExpiry();
    final (tone, _) = expiryTone(days);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.seriesNumber, style: theme.textTheme.bodyMedium),
                Text(
                  Formatters.date(item.expiryDate),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          StatusChip(label: expiryLabel(days), tone: tone, dense: true),
          const SizedBox(width: 8),
          Text(
            formatQuantity(item.quantity),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// One ledger entry: direction icon + type label + document/date + signed qty.
class _MovementTile extends StatelessWidget {
  const _MovementTile({required this.movement});

  final StockMovement movement;

  @override
  Widget build(BuildContext context) {
    final status = StatusColors.of(context);
    final isInbound = movement.quantity >= 0;
    final color = isInbound ? status.ok : status.danger;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isInbound ? Icons.south_west : Icons.north_east,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movementTypeLabel(movement.type)),
                Text(
                  [
                    if (movement.documentType != null) movement.documentType!,
                    Formatters.dateTime(movement.createdAt),
                  ].join(' • '),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _signed(movement.quantity),
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  String _signed(double value) {
    final sign = value > 0 ? '+' : '';
    return '$sign${formatQuantity(value)}';
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.primary,
        letterSpacing: 0.4,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _MovementsError extends StatelessWidget {
  const _MovementsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: TextStyle(color: StatusColors.of(context).danger),
        ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Аз нав'),
        ),
      ],
    );
  }
}

/// Maps a raw `MovementType` wire value to a Tajik label (TZ_03 §C.3 "ledger
/// with MovementType labels"). Falls back to the raw value when unknown.
String movementTypeLabel(String type) {
  switch (type) {
    case 'Receipt':
    case 'Inbound':
    case 'Приход':
      return 'Приход';
    case 'Sale':
      return 'Фурӯш';
    case 'Return':
      return 'Бозгашт';
    case 'WriteOff':
    case 'Списание':
      return 'Списание';
    case 'Adjustment':
      return 'Тасҳеҳ';
    case 'Transfer':
      return 'Интиқол';
    default:
      return type;
  }
}

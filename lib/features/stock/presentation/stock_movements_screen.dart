import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/utils/formatters.dart';
import '../data/stock_models.dart';
import 'stock_provider.dart';

/// Movement history for a single product (Анбор → таърихи ҳаракат, TZ §3.5).
/// Lists the newest [StockMovement] entries (type, quantity, document, time).
class StockMovementsScreen extends ConsumerWidget {
  const StockMovementsScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  final String productId;
  final String productName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(stockMovementsProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ҳаракати дору'),
        actions: [
          IconButton(
            tooltip: 'Навсозӣ',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(stockMovementsProvider(productId)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              productName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => _ErrorView(
                message: err is Failure ? err.message : err.toString(),
                onRetry: () =>
                    ref.invalidate(stockMovementsProvider(productId)),
              ),
              data: (movements) {
                if (movements.isEmpty) {
                  return const Center(child: Text('Ҳаракат нест'));
                }
                return ListView.separated(
                  itemCount: movements.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) =>
                      _MovementTile(movement: movements[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  const _MovementTile({required this.movement});

  final StockMovement movement;

  @override
  Widget build(BuildContext context) {
    // An inbound movement (e.g. receipt posting) is positive; outbound is
    // negative. We colour by sign for quick scanning.
    final isInbound = movement.quantity >= 0;
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(
        isInbound ? Icons.south_west : Icons.north_east,
        color: isInbound ? scheme.primary : scheme.error,
      ),
      title: Text(movement.type),
      subtitle: Text(
        [
          if (movement.documentType != null) movement.documentType!,
          Formatters.dateTime(movement.createdAt),
        ].join(' • '),
      ),
      trailing: Text(
        _qty(movement.quantity),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isInbound ? scheme.primary : scheme.error,
        ),
      ),
    );
  }

  String _qty(double value) {
    final sign = value > 0 ? '+' : '';
    final body = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : '$value';
    return '$sign$body';
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Аз нав кӯшиш кунед'),
          ),
        ],
      ),
    );
  }
}

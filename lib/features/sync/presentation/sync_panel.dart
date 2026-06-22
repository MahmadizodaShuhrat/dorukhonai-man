import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/app_toast.dart';
import '../../../shared/empty_state.dart';
import '../../../shared/status_chip.dart';
import 'connectivity_provider.dart';
import 'sync_providers.dart';

/// Sync queue + reconciliation surface (TZ_04 §6). Lists offline sales awaiting
/// sync (queued) and any that came back `conflict` from the server, with a
/// "Sync now" action and per-conflict dismissal. Opened from the top-bar
/// connectivity chip.
class SyncPanel extends ConsumerWidget {
  const SyncPanel({super.key});

  /// Shows the panel as a right-anchored modal dialog.
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const SyncPanel(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final conn = ref.watch(connectivityControllerProvider);
    final rowsAsync = ref.watch(conflictSalesProvider);
    final pending = ref.watch(pendingSyncCountProvider).valueOrNull ?? 0;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    conn.isOnline
                        ? Icons.cloud_done_outlined
                        : Icons.cloud_off_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Синхронизатсия',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  StatusChip(
                    label: conn.isOnline ? 'Онлайн' : 'Офлайн',
                    tone: conn.isOnline ? StatusTone.ok : StatusTone.warn,
                  ),
                  const SizedBox(width: 8),
                  StatusChip(
                    label: '$pending дар навбат',
                    tone: pending > 0 ? StatusTone.warn : StatusTone.info,
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    icon: const Icon(Icons.sync, size: 18),
                    label: const Text('Синхрон кардан'),
                    onPressed: () => _syncNow(context, ref),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                'Низоъҳо (conflict)',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Flexible(
                child: rowsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Хато: $e'),
                  data: (rows) => rows.isEmpty
                      ? const EmptyState(
                          icon: Icons.check_circle_outline,
                          title: 'Низоъ нест',
                          message: 'Ҳама фурӯшҳои офлайн бомуваффақият '
                              'синхрон шуданд.',
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: rows.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (_, i) =>
                              _ConflictTile(sale: rows[i]),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _syncNow(BuildContext context, WidgetRef ref) async {
    final outcome = await ref.read(syncCoordinatorProvider).syncNow();
    if (!context.mounted) return;
    final p = outcome.push;
    AppToast.info(
      context,
      'Синхрон: ${p.pushed} қабул, ${p.conflicts} низоъ, ${p.failed} нашуд.',
    );
  }
}

class _ConflictTile extends ConsumerWidget {
  const _ConflictTile({required this.sale});
  final OutboxSale sale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
      title: Text('Фурӯш ${Formatters.dateTime(sale.createdAt)}'),
      subtitle: Text(
        sale.conflictMessage ?? 'Бақия дар сервер нарасид.',
        style: theme.textTheme.bodySmall,
      ),
      trailing: TextButton(
        onPressed: () async {
          await ref.read(cacheDaoProvider).dropConflict(sale.clientId);
          if (context.mounted) {
            AppToast.info(context, 'Низоъ рад карда шуд.');
          }
        },
        child: const Text('Рад кардан'),
      ),
    );
  }
}

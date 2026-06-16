import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/utils/formatters.dart';
import '../data/pos_models.dart';
import '../data/pos_repository.dart';
import 'pos_providers.dart';

/// Close-shift flow (TZ §3.2): enter counted `closingCash`, close the shift,
/// then show the Z-report summary. The cashier confirms before closing.
class CloseShiftDialog extends ConsumerStatefulWidget {
  const CloseShiftDialog({super.key, required this.shift});

  final CashShift shift;

  /// Opens the dialog. Resolves when dismissed.
  static Future<void> show(BuildContext context, CashShift shift) {
    return showDialog<void>(
      context: context,
      builder: (_) => CloseShiftDialog(shift: shift),
    );
  }

  @override
  ConsumerState<CloseShiftDialog> createState() => _CloseShiftDialogState();
}

class _CloseShiftDialogState extends ConsumerState<CloseShiftDialog> {
  final _closingCash = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  /// Once closed, the Z-report figures to display.
  ZReport? _report;
  String? _error;

  @override
  void dispose() {
    _closingCash.dispose();
    super.dispose();
  }

  double? _parse(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));

  Future<void> _close() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final closing = _parse(_closingCash.text)!;
    final result = await ref
        .read(cashShiftControllerProvider.notifier)
        .closeShift(closing);
    if (!mounted) return;
    switch (result) {
      case CloseShiftSuccess(:final shift):
        // Pull the full Z-report for the closed shift.
        final repo = ref.read(posRepositoryProvider);
        final reportResult = await repo.zReport(shift.id);
        if (!mounted) return;
        switch (reportResult) {
          case Success(:final data):
            setState(() => _report = data);
          case Error(:final failure):
            setState(() => _error = failure.message);
        }
      case CloseShiftFailure(:final failure):
        setState(() => _error = failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(cashShiftControllerProvider).isLoading;
    final report = _report;

    if (report != null) {
      return _ZReportView(report: report);
    }

    return AlertDialog(
      title: const Text('Бастани смена'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Кушода шуд: ${Formatters.dateTime(widget.shift.openedAt)}'),
              Text('Нақди ибтидоӣ: ${Formatters.money(widget.shift.openingCash)}'),
              Text('Фурӯш: ${Formatters.money(widget.shift.totalSales)}'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _closingCash,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Нақди ниҳоӣ (ҳисобшуда) *',
                  prefixIcon: Icon(Icons.payments_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final parsed = _parse(v ?? '');
                  if (parsed == null) return 'Рақами дуруст ворид кунед';
                  if (parsed < 0) return 'Манфӣ шуда наметавонад';
                  return null;
                },
                onFieldSubmitted: (_) => busy ? null : _close(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Бекор'),
        ),
        FilledButton.icon(
          onPressed: busy ? null : _close,
          icon: const Icon(Icons.lock_outline),
          label: const Text('Бастан'),
        ),
      ],
    );
  }
}

/// Read-only Z-report summary shown after a shift closes.
class _ZReportView extends StatelessWidget {
  const _ZReportView({required this.report});

  final ZReport report;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Z-ҳисобот'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _row('Кушода шуд', Formatters.dateTime(report.openedAt)),
              if (report.closedAt != null)
                _row('Баста шуд', Formatters.dateTime(report.closedAt!)),
              const Divider(),
              _row('Нақди ибтидоӣ', Formatters.money(report.openingCash)),
              _row('Шумораи фурӯш', '${report.salesCount}'),
              _row('Фурӯш (ҷамъ)', Formatters.money(report.totalSales)),
              _row('Бозгашт (ҷамъ)', Formatters.money(report.totalReturns)),
              _row('Софи фурӯш', Formatters.money(report.netTotal),
                  emphasize: true),
              const Divider(),
              _row('Нақд', Formatters.money(report.amountFor(PaymentMethod.cash))),
              _row('Корт', Formatters.money(report.amountFor(PaymentMethod.card))),
              _row('Қарз',
                  Formatters.money(report.amountFor(PaymentMethod.credit))),
              const Divider(),
              _row('Нақди интизорӣ', Formatters.money(report.expectedCash)),
              if (report.closingCash != null)
                _row('Нақди ҳисобшуда', Formatters.money(report.closingCash!)),
              if (report.closingCash != null)
                _row(
                  'Фарқият',
                  Formatters.money(report.closingCash! - report.expectedCash),
                  emphasize: true,
                ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Пӯшидан'),
        ),
      ],
    );
  }

  Widget _row(String label, String value, {bool emphasize = false}) {
    return Builder(
      builder: (context) {
        final style = emphasize
            ? Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)
            : Theme.of(context).textTheme.bodyMedium;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: style),
              Text(value, style: style),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/app_localizations.dart';
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
    final l = AppLocalizations.of(context);
    final busy = ref.watch(cashShiftControllerProvider).isLoading;
    final report = _report;

    if (report != null) {
      return _ZReportView(report: report);
    }

    return AlertDialog(
      title: Text(l.closeShiftTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.closeShiftOpenedAt(
                  Formatters.dateTime(widget.shift.openedAt))),
              Text(l.closeShiftOpeningCash(
                  Formatters.money(widget.shift.openingCash))),
              Text(l.closeShiftSales(
                  Formatters.money(widget.shift.totalSales))),
              const SizedBox(height: 12),
              TextFormField(
                controller: _closingCash,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l.closeShiftClosingCash,
                  prefixIcon: const Icon(Icons.payments_outlined),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  final parsed = _parse(v ?? '');
                  if (parsed == null) return l.validationEnterNumber;
                  if (parsed < 0) return l.validationNotNegative;
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
          child: Text(l.commonCancel),
        ),
        FilledButton.icon(
          onPressed: busy ? null : _close,
          icon: const Icon(Icons.lock_outline),
          label: Text(l.closeShiftClose),
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
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.zReportTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _row(l.zReportOpened, Formatters.dateTime(report.openedAt)),
              if (report.closedAt != null)
                _row(l.zReportClosed, Formatters.dateTime(report.closedAt!)),
              const Divider(),
              _row(l.zReportOpeningCash, Formatters.money(report.openingCash)),
              _row(l.zReportSalesCount, '${report.salesCount}'),
              _row(l.zReportSalesTotal, Formatters.money(report.totalSales)),
              _row(l.zReportReturnsTotal, Formatters.money(report.totalReturns)),
              _row(l.zReportNet, Formatters.money(report.netTotal),
                  emphasize: true),
              const Divider(),
              _row(l.paymentMethodCash,
                  Formatters.money(report.amountFor(PaymentMethod.cash))),
              _row(l.paymentMethodCard,
                  Formatters.money(report.amountFor(PaymentMethod.card))),
              _row(l.paymentMethodCredit,
                  Formatters.money(report.amountFor(PaymentMethod.credit))),
              const Divider(),
              _row(l.zReportExpectedCash, Formatters.money(report.expectedCash)),
              if (report.closingCash != null)
                _row(l.zReportCountedCash,
                    Formatters.money(report.closingCash!)),
              if (report.closingCash != null)
                _row(
                  l.zReportDiff,
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
          child: Text(l.commonClose),
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

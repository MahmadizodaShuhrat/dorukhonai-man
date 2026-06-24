import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../data/pos_models.dart';

/// Result of the payment dialog: the chosen tenders. The cart-level discount is
/// applied separately on the sale screen.
class PaymentResult {
  const PaymentResult({required this.payments});

  final List<Payment> payments;
}

/// Single-tender payment panel (TZ §3.2): choose method (Нақд/Корт/Қарз),
/// enter the amount, and (for cash) see the change due. Returns a
/// [PaymentResult] via `Navigator.pop`, or `null` on cancel.
///
/// For simplicity this books one payment; the model already supports multiple
/// (the contract `payments` is a list).
class PaymentDialog extends StatefulWidget {
  const PaymentDialog({super.key, required this.total});

  /// The amount due (already net of discounts).
  final double total;

  /// Opens the dialog and resolves to the chosen tender(s) or `null`.
  static Future<PaymentResult?> show(BuildContext context, double total) {
    return showDialog<PaymentResult>(
      context: context,
      builder: (_) => PaymentDialog(total: total),
    );
  }

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  PaymentMethod _method = PaymentMethod.cash;
  late final TextEditingController _amount;

  @override
  void initState() {
    super.initState();
    // Default the tendered amount to the exact total.
    _amount = TextEditingController(text: _trimNum(widget.total));
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  double get _tendered =>
      double.tryParse(_amount.text.trim().replaceAll(',', '.')) ?? 0;

  double get _change =>
      (_tendered - widget.total).clamp(0, double.infinity).toDouble();

  bool get _isCash => _method == PaymentMethod.cash;

  /// Must tender at least the total; cash may over-tender (the surplus is the
  /// change due, card/credit fields are locked to the exact total).
  bool get _canPay => _tendered >= widget.total;

  void _submit() {
    if (!_canPay) return;
    // For card/credit, book exactly the total; for cash, book exactly the
    // total too (the over-tender is returned as change, not recorded).
    final payment = Payment(method: _method, amount: widget.total);
    Navigator.of(context).pop(PaymentResult(payments: [payment]));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(l.payTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.payForPayment(Formatters.money(widget.total)),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SegmentedButton<PaymentMethod>(
              segments: [
                ButtonSegment(
                  value: PaymentMethod.cash,
                  label: Text(l.paymentMethodCash),
                  icon: const Icon(Icons.payments_outlined),
                ),
                ButtonSegment(
                  value: PaymentMethod.card,
                  label: Text(l.paymentMethodCard),
                  icon: const Icon(Icons.credit_card),
                ),
                ButtonSegment(
                  value: PaymentMethod.credit,
                  label: Text(l.paymentMethodCredit),
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                ),
              ],
              selected: {_method},
              onSelectionChanged: (s) => setState(() {
                _method = s.first;
                if (!_isCash) _amount.text = _trimNum(widget.total);
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amount,
              autofocus: true,
              enabled: _isCash,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l.payAmountGiven,
                prefixIcon: const Icon(Icons.attach_money),
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _submit(),
            ),
            if (_isCash) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l.payChange),
                  Text(
                    Formatters.money(_change),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.commonCancel),
        ),
        FilledButton.icon(
          onPressed: _canPay ? _submit : null,
          icon: const Icon(Icons.check),
          label: Text(l.commonConfirm),
        ),
      ],
    );
  }

  String _trimNum(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';
}

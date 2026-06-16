import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../data/receipt_models.dart';

/// Modal form for one receipt line: quantity, series, expiry date, purchase &
/// sale price. Returns the built [ReceiptLine] via `Navigator.pop`, or `null`
/// on cancel. The product is already chosen (via the product picker) and is
/// shown read-only at the top.
class ReceiptLineDialog extends StatefulWidget {
  const ReceiptLineDialog({
    super.key,
    required this.productId,
    this.productName,
    this.initial,
  });

  final String productId;
  final String? productName;

  /// When editing an existing line, prefill the fields.
  final ReceiptLine? initial;

  /// Opens the dialog and resolves to the edited/created line (or `null`).
  static Future<ReceiptLine?> show(
    BuildContext context, {
    required String productId,
    String? productName,
    ReceiptLine? initial,
  }) {
    return showDialog<ReceiptLine>(
      context: context,
      builder: (_) => ReceiptLineDialog(
        productId: productId,
        productName: productName,
        initial: initial,
      ),
    );
  }

  @override
  State<ReceiptLineDialog> createState() => _ReceiptLineDialogState();
}

class _ReceiptLineDialogState extends State<ReceiptLineDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _quantity;
  late final TextEditingController _series;
  late final TextEditingController _purchasePrice;
  late final TextEditingController _salePrice;

  late DateTime _expiry;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _quantity = TextEditingController(
      text: initial == null ? '' : _trimNum(initial.quantity),
    );
    _series = TextEditingController(text: initial?.seriesNumber ?? '');
    _purchasePrice = TextEditingController(
      text: initial == null ? '' : _trimNum(initial.purchasePrice),
    );
    _salePrice = TextEditingController(
      text: initial == null ? '' : _trimNum(initial.salePrice),
    );
    _expiry =
        initial?.expiryDate ?? DateTime.now().add(const Duration(days: 365));
  }

  @override
  void dispose() {
    _quantity.dispose();
    _series.dispose();
    _purchasePrice.dispose();
    _salePrice.dispose();
    super.dispose();
  }

  /// Parses a decimal allowing a comma decimal separator (ru locale input).
  double? _parse(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));

  String? _requiredPositive(String? value, {bool allowZero = false}) {
    final parsed = _parse(value ?? '');
    if (parsed == null) return 'Рақами дуруст ворид кунед';
    if (allowZero ? parsed < 0 : parsed <= 0) return 'Бояд аз сифр зиёд бошад';
    return null;
  }

  Future<void> _pickExpiry() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiry,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _expiry = picked);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final line = ReceiptLine(
      id: widget.initial?.id,
      productId: widget.productId,
      productName: widget.productName,
      quantity: _parse(_quantity.text)!,
      seriesNumber: _series.text.trim(),
      expiryDate: _expiry,
      purchasePrice: _parse(_purchasePrice.text)!,
      salePrice: _parse(_salePrice.text)!,
    );
    Navigator.of(context).pop(line);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.productName ?? 'Сатр'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _quantity,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Миқдор *',
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  validator: (v) => _requiredPositive(v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _series,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Серия *',
                    prefixIcon: Icon(Icons.tag),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Серияро ворид кунед'
                      : null,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickExpiry,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Мӯҳлат (то) *',
                      prefixIcon: Icon(Icons.event_busy),
                    ),
                    child: Text(Formatters.date(_expiry)),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _purchasePrice,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Нархи харид *',
                    prefixIcon: Icon(Icons.shopping_cart_outlined),
                  ),
                  validator: (v) => _requiredPositive(v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _salePrice,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(
                    labelText: 'Нархи фурӯш *',
                    prefixIcon: Icon(Icons.sell_outlined),
                  ),
                  validator: (v) => _requiredPositive(v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Бекор'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.initial == null ? 'Илова' : 'Нигоҳ доштан'),
        ),
      ],
    );
  }

  String _trimNum(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/utils/formatters.dart';
import '../data/pos_models.dart';

/// On-screen sale receipt + cross-platform PDF "Print" action (TZ §3.2).
///
/// Renders the shop header, the server-allocated [SaleLine]s (which may be
/// split per batch by FEFO), totals, payments and change. The PDF is produced
/// with the `pdf` package and sent to the platform print/share sheet via
/// `printing`, which works on Windows/macOS/iOS/Android.
class ReceiptDialog extends StatelessWidget {
  const ReceiptDialog({super.key, required this.sale});

  final Sale sale;

  /// Shop name shown on the receipt header.
  static const String shopName = 'Дорухонаи Ман';

  /// Shows the receipt and resolves when it is dismissed.
  static Future<void> show(BuildContext context, Sale sale) {
    return showDialog<void>(
      context: context,
      builder: (_) => ReceiptDialog(sale: sale),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Row(
        children: [
          const Expanded(child: Text('Чек')),
          IconButton(
            tooltip: 'Пӯшидан',
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360, maxHeight: 520),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  shopName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(child: Text('Чек № ${sale.number}')),
              Center(child: Text(Formatters.dateTime(sale.createdAt))),
              const Divider(),
              for (final line in sale.lines) _ReceiptLineRow(line: line),
              const Divider(),
              _AmountRow(
                label: 'Зерҷамъ',
                value: Formatters.money(sale.subtotal),
              ),
              if (sale.discount > 0)
                _AmountRow(
                  label: 'Тахфиф',
                  value: '-${Formatters.money(sale.discount)}',
                ),
              _AmountRow(
                label: 'ҲАМАГӢ',
                value: Formatters.money(sale.total),
                emphasize: true,
              ),
              const Divider(),
              for (final payment in sale.payments)
                _AmountRow(
                  label: _paymentLabel(payment.method),
                  value: Formatters.money(payment.amount),
                ),
              if (sale.changeDue > 0)
                _AmountRow(
                  label: 'Қайтарма',
                  value: Formatters.money(sale.changeDue),
                ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Ташаккур барои харид!',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Пӯшидан'),
        ),
        FilledButton.icon(
          onPressed: () => printReceipt(sale),
          icon: const Icon(Icons.print),
          label: const Text('Чоп'),
        ),
      ],
    );
  }
}

/// Builds a printable PDF receipt and hands it to the platform print dialog.
/// Cross-platform (Windows/macOS/iOS/Android) via the `printing` package.
Future<void> printReceipt(Sale sale) async {
  await Printing.layoutPdf(
    onLayout: (format) async => _buildReceiptPdf(sale, format),
    name: 'Чек ${sale.number}',
  );
}

/// Produces the receipt PDF bytes on an ~80mm roll page (`PdfPageFormat`).
Future<Uint8List> _buildReceiptPdf(Sale sale, PdfPageFormat format) async {
  final doc = pw.Document();
  // 80mm roll receipt with a generous max height.
  final pageFormat = PdfPageFormat(
    80 * PdfPageFormat.mm,
    double.infinity,
    marginAll: 6 * PdfPageFormat.mm,
  );

  doc.addPage(
    pw.Page(
      pageFormat: pageFormat,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Center(
              child: pw.Text(
                ReceiptDialog.shopName,
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Center(child: pw.Text('Чек № ${sale.number}')),
            pw.Center(child: pw.Text(Formatters.dateTime(sale.createdAt))),
            pw.Divider(),
            for (final line in sale.lines) _pdfLine(line),
            pw.Divider(),
            _pdfAmount('Зерҷамъ', Formatters.money(sale.subtotal)),
            if (sale.discount > 0)
              _pdfAmount('Тахфиф', '-${Formatters.money(sale.discount)}'),
            _pdfAmount('ҲАМАГӢ', Formatters.money(sale.total), bold: true),
            pw.Divider(),
            for (final payment in sale.payments)
              _pdfAmount(
                _paymentLabel(payment.method),
                Formatters.money(payment.amount),
              ),
            if (sale.changeDue > 0)
              _pdfAmount('Қайтарма', Formatters.money(sale.changeDue)),
            pw.SizedBox(height: 8),
            pw.Center(child: pw.Text('Ташаккур барои харид!')),
          ],
        );
      },
    ),
  );

  return doc.save();
}

pw.Widget _pdfLine(SaleLine line) {
  final name = line.productName ?? line.productId;
  final series = line.seriesNumber;
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Text(name, style: const pw.TextStyle(fontSize: 10)),
      if (series != null && series.isNotEmpty)
        pw.Text(
          'Серия: $series',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '${_trimNum(line.quantity)} x ${Formatters.money(line.unitPrice)}',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.Text(
            Formatters.money(line.lineTotal),
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
      pw.SizedBox(height: 3),
    ],
  );
}

pw.Widget _pdfAmount(String label, String value, {bool bold = false}) {
  final style = pw.TextStyle(
    fontSize: bold ? 12 : 10,
    fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
  );
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(label, style: style),
      pw.Text(value, style: style),
    ],
  );
}

String _paymentLabel(PaymentMethod method) => switch (method) {
  PaymentMethod.cash => 'Нақд',
  PaymentMethod.card => 'Корт',
  PaymentMethod.credit => 'Қарз',
};

/// Renders a quantity without a trailing `.0` for whole numbers.
String _trimNum(double value) =>
    value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';

/// One receipt line in the on-screen dialog (name + series + qty x price).
class _ReceiptLineRow extends StatelessWidget {
  const _ReceiptLineRow({required this.line});

  final SaleLine line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final series = line.seriesNumber;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(line.productName ?? line.productId),
          if (series != null && series.isNotEmpty)
            Text(
              'Серия: $series',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_trimNum(line.quantity)} x ${Formatters.money(line.unitPrice)}',
                style: theme.textTheme.bodySmall,
              ),
              Text(Formatters.money(line.lineTotal)),
            ],
          ),
        ],
      ),
    );
  }
}

/// A label/value amount row used in the totals/payments block.
class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = emphasize
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : theme.textTheme.bodyMedium;
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
  }
}

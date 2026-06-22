import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// A tabular dataset ready for PDF/CSV export. Decouples export from any one
/// report type: each view assembles a [ReportTable] (title, column headers,
/// string rows) and hands it to [ReportExporter].
class ReportTable {
  const ReportTable({
    required this.title,
    required this.headers,
    required this.rows,
    this.subtitle,
    this.numericColumns = const {},
  });

  /// Document/report title (e.g. "Ҳисоботи фурӯш").
  final String title;

  /// Optional line under the title (e.g. the date range).
  final String? subtitle;

  /// Column header labels.
  final List<String> headers;

  /// Body rows, each already formatted to display strings.
  final List<List<String>> rows;

  /// Indices of columns that should be right-aligned (money/quantity).
  final Set<int> numericColumns;
}

/// Outcome of a save-to-disk export (CSV). [path] is the written file.
class ExportResult {
  const ExportResult(this.path);
  final String path;
}

/// Renders a [ReportTable] to PDF (print/save dialog) or CSV (saved to the
/// documents directory). Uses the already-bundled `printing`/`pdf` packages
/// for PDF and `path_provider` for CSV (TZ_03 §C.6 — no extra deps).
class ReportExporter {
  const ReportExporter();

  /// Opens the OS print/save-to-PDF dialog for the given [table]. Returns the
  /// result of [Printing.layoutPdf] (false when the user cancels).
  Future<bool> printPdf(ReportTable table) {
    return Printing.layoutPdf(
      name: table.title,
      onLayout: (format) => _buildPdf(table, format),
    );
  }

  /// Writes [table] to a UTF-8 CSV file in the app documents directory and
  /// returns its [ExportResult]. The path is shown to the user via a toast.
  Future<ExportResult> saveCsv(ReportTable table) async {
    final dir = await getApplicationDocumentsDirectory();
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final safeTitle = table.title.replaceAll(RegExp(r'[^\wЀ-ӿ]+'), '_');
    final file = File(p.join(dir.path, '${safeTitle}_$stamp.csv'));
    await file.writeAsString(_buildCsv(table));
    return ExportResult(file.path);
  }

  /// Builds the CSV body. Prefixes a BOM so Excel opens UTF-8 (Cyrillic)
  /// correctly, and quotes/escapes every field.
  String _buildCsv(ReportTable table) {
    final buffer = StringBuffer('﻿');
    void writeRow(List<String> cells) {
      buffer.writeln(cells.map(_escapeCsv).join(','));
    }

    writeRow(table.headers);
    for (final row in table.rows) {
      writeRow(row);
    }
    return buffer.toString();
  }

  String _escapeCsv(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  Future<Uint8List> _buildPdf(ReportTable table, PdfPageFormat format) async {
    // Use a Unicode TTF so Cyrillic/Tajik glyphs render in the PDF; fall back
    // to the default font if the Google-font fetch is unavailable offline.
    pw.ThemeData? theme;
    try {
      theme = pw.ThemeData.withFont(
        base: await PdfGoogleFonts.robotoRegular(),
        bold: await PdfGoogleFonts.robotoBold(),
      );
    } catch (_) {
      theme = null;
    }

    final doc = pw.Document(theme: theme);
    doc.addPage(
      pw.MultiPage(
        pageFormat: format.landscape,
        build: (context) => [
          pw.Header(level: 0, text: table.title),
          if (table.subtitle != null)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(
                table.subtitle!,
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
          pw.TableHelper.fromTextArray(
            headers: table.headers,
            data: table.rows,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignments: {
              for (final i in table.numericColumns)
                i: pw.Alignment.centerRight,
            },
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellStyle: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
    return doc.save();
  }
}

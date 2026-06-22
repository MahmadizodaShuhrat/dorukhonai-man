import 'package:dorukhonai_man/features/reports/data/report_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SalesReportRow.fromJson', () {
    test('parses a day bucket with explicit fields', () {
      final row = SalesReportRow.fromJson({
        'date': '2026-06-20',
        'salesCount': 4,
        'quantity': 12,
        'subtotal': 200,
        'discount': 10,
        'total': 190,
      });
      expect(row.label, '2026-06-20');
      expect(row.date, DateTime(2026, 6, 20));
      expect(row.salesCount, 4);
      expect(row.total, 190);
    });

    test('falls back to productName / count aliases', () {
      final row = SalesReportRow.fromJson({
        'productName': 'Аспирин',
        'count': 7,
        'total': 50,
      });
      expect(row.label, 'Аспирин');
      expect(row.salesCount, 7);
      expect(row.date, isNull);
    });
  });

  group('ProfitReport.fromJson', () {
    test('computes profit and margin when omitted', () {
      final p = ProfitReport.fromJson({'revenue': 100, 'cost': 60});
      expect(p.profit, 40);
      expect(p.margin, closeTo(0.4, 1e-9));
    });

    test('uses server-provided margin when present', () {
      final p = ProfitReport.fromJson({
        'revenue': 100,
        'cost': 60,
        'profit': 40,
        'margin': 0.5,
      });
      expect(p.margin, 0.5);
    });

    test('margin is zero on zero revenue', () {
      final p = ProfitReport.fromJson({'revenue': 0, 'cost': 0});
      expect(p.margin, 0);
    });
  });

  group('StockValueRow.fromJson', () {
    test('parses purchase/sale value with aliases', () {
      final r = StockValueRow.fromJson({
        'name': 'Парацетамол',
        'quantity': 30,
        'costValue': 150,
        'retailValue': 240,
      });
      expect(r.productName, 'Парацетамол');
      expect(r.purchaseValue, 150);
      expect(r.saleValue, 240);
    });
  });

  group('SalesGroupBy', () {
    test('wire tokens match the contract', () {
      expect(SalesGroupBy.day.wire, 'day');
      expect(SalesGroupBy.product.wire, 'product');
      expect(SalesGroupBy.seller.wire, 'seller');
    });
  });
}

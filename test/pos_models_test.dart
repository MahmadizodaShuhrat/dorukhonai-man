import 'package:dorukhonai_man/features/pos/data/pos_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CashShift.fromJson', () {
    test('parses an open shift with a null closedAt/closingCash', () {
      final shift = CashShift.fromJson({
        'id': 'shift-1',
        'branchId': 'br-1',
        'userId': 'u1',
        'openedAt': '2026-06-16T09:00:00Z',
        'closedAt': null,
        'openingCash': 100.5,
        'closingCash': null,
        'totalSales': 250.0,
        'status': 'Open',
      });

      expect(shift.id, 'shift-1');
      expect(shift.closedAt, isNull);
      expect(shift.closingCash, isNull);
      expect(shift.openingCash, 100.5);
      expect(shift.status, ShiftStatus.open);
      expect(shift.status.isOpen, isTrue);
    });
  });

  group('Sale.fromJson', () {
    test('parses lines + payments and computes change due', () {
      final sale = Sale.fromJson({
        'id': 'sale-1',
        'number': 'S-001',
        'branchId': 'br-1',
        'shiftId': 'shift-1',
        'userId': 'u1',
        'createdAt': '2026-06-16T10:00:00Z',
        'lines': [
          {
            'id': 'sl-1',
            'productId': 'p1',
            'productName': 'Аспирин',
            'batchId': 'b1',
            'seriesNumber': 'S-1',
            'quantity': 2,
            'unitPrice': 15,
            'lineDiscount': 0,
            'lineTotal': 30,
          },
        ],
        'payments': [
          {'method': 'Cash', 'amount': 50},
        ],
        'subtotal': 30,
        'discount': 0,
        'total': 30,
      });

      expect(sale.lines, hasLength(1));
      expect(sale.lines.first.batchId, 'b1');
      expect(sale.lines.first.seriesNumber, 'S-1');
      expect(sale.payments.first.method, PaymentMethod.cash);
      expect(sale.paid, 50);
      expect(sale.changeDue, 20); // 50 paid - 30 total
    });
  });

  group('CartItem', () {
    test('toRequestJson sends product+qty and omits a zero lineDiscount', () {
      const item = CartItem(
        productId: 'p1',
        name: 'Аспирин',
        quantity: 3,
        unitPrice: 10,
      );

      final json = item.toRequestJson();

      expect(json, {'productId': 'p1', 'quantity': 3});
      expect(json.containsKey('lineDiscount'), isFalse);
    });

    test('toRequestJson includes a positive lineDiscount and computes total',
        () {
      const item = CartItem(
        productId: 'p1',
        name: 'Аспирин',
        quantity: 2,
        unitPrice: 10,
        lineDiscount: 5,
      );

      expect(item.toRequestJson()['lineDiscount'], 5);
      expect(item.lineTotal, 15); // 2*10 - 5
    });
  });

  group('Payment.toJson', () {
    test('uses the exact wire method token', () {
      const payment = Payment(method: PaymentMethod.card, amount: 42);
      expect(payment.toJson(), {'method': 'Card', 'amount': 42});
    });
  });

  group('ZReport.fromJson', () {
    test('parses byMethod into a PaymentMethod-keyed map', () {
      final report = ZReport.fromJson({
        'shiftId': 'shift-1',
        'branchId': 'br-1',
        'openedAt': '2026-06-16T09:00:00Z',
        'closedAt': '2026-06-16T18:00:00Z',
        'openingCash': 100,
        'closingCash': 450,
        'salesCount': 12,
        'totalSales': 400,
        'totalReturns': 50,
        'netTotal': 350,
        'byMethod': {'Cash': 300, 'Card': 100, 'Credit': 0},
        'expectedCash': 400,
      });

      expect(report.salesCount, 12);
      expect(report.amountFor(PaymentMethod.cash), 300);
      expect(report.amountFor(PaymentMethod.card), 100);
      expect(report.amountFor(PaymentMethod.credit), 0);
      expect(report.netTotal, 350);
    });
  });
}

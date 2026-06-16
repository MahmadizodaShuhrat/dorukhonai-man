import 'package:dorukhonai_man/features/receipts/data/receipt_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReceiptStatus wire values', () {
    test('match the API contract exactly', () {
      expect(ReceiptStatus.draft.wire, 'Draft');
      expect(ReceiptStatus.posted.wire, 'Posted');
      expect(ReceiptStatus.cancelled.wire, 'Cancelled');
    });

    test('fromWire round-trips and defaults to draft on unknown', () {
      expect(ReceiptStatus.fromWire('Posted'), ReceiptStatus.posted);
      expect(ReceiptStatus.fromWire('Cancelled'), ReceiptStatus.cancelled);
      expect(ReceiptStatus.fromWire('???'), ReceiptStatus.draft);
      expect(ReceiptStatus.fromWire(null), ReceiptStatus.draft);
    });
  });

  group('Receipt.fromJson', () {
    test('decodes header + lines with the contract field names', () {
      final receipt = Receipt.fromJson(<String, dynamic>{
        'id': 'r1',
        'number': 'PR-001',
        'supplierId': 'sup-1',
        'branchId': 'br-1',
        'date': '2026-06-01T08:00:00Z',
        'status': 'Posted',
        'total': 30.5,
        'lines': [
          {
            'id': 'l1',
            'productId': 'p1',
            'productName': 'Аспирин',
            'quantity': 2,
            'seriesNumber': 'S-1',
            'expiryDate': '2027-01-01',
            'purchasePrice': 10,
            'salePrice': 15,
          },
        ],
      });

      expect(receipt.id, 'r1');
      expect(receipt.number, 'PR-001');
      expect(receipt.supplierId, 'sup-1');
      expect(receipt.branchId, 'br-1');
      expect(receipt.status, ReceiptStatus.posted);
      expect(receipt.total, 30.5);
      expect(receipt.lines, hasLength(1));
      final line = receipt.lines.first;
      expect(line.productId, 'p1');
      expect(line.productName, 'Аспирин');
      expect(line.quantity, 2);
      expect(line.seriesNumber, 'S-1');
      expect(line.purchasePrice, 10);
      expect(line.salePrice, 15);
      expect(line.expiryDate, DateTime(2027, 1, 1));
    });

    test('list header with empty lines is tolerated', () {
      final receipt = Receipt.fromJson(<String, dynamic>{
        'id': 'r1',
        'number': 'PR-001',
        'supplierId': 'sup-1',
        'branchId': 'br-1',
        'date': '2026-06-01T08:00:00Z',
        'status': 'Draft',
        'total': 0,
      });
      expect(receipt.lines, isEmpty);
    });
  });

  group('toCreateJson', () {
    test('receipt payload has exactly {supplierId, branchId, date, lines}', () {
      final receipt = Receipt(
        id: 'r1',
        number: 'PR-001',
        supplierId: 'sup-1',
        branchId: 'br-1',
        date: DateTime.utc(2026, 6, 1, 8),
        status: ReceiptStatus.draft,
        total: 30,
        lines: [
          ReceiptLine(
            id: 'l1',
            productId: 'p1',
            productName: 'Аспирин',
            quantity: 2,
            seriesNumber: 'S-1',
            expiryDate: DateTime(2027, 1, 1),
            purchasePrice: 10,
            salePrice: 15,
          ),
        ],
      );

      final json = receipt.toCreateJson();
      expect(json.keys.toSet(), {'supplierId', 'branchId', 'date', 'lines'});
      // Header omits id/number/status/total (server-owned).
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('status'), isFalse);
      expect(json.containsKey('total'), isFalse);

      final lines = json['lines'] as List<dynamic>;
      final line = lines.first as Map<String, dynamic>;
      // Line create payload strips id + productName and is date-only expiry.
      expect(line.keys.toSet(), {
        'productId',
        'quantity',
        'seriesNumber',
        'expiryDate',
        'purchasePrice',
        'salePrice',
      });
      expect(line['expiryDate'], '2027-01-01');
    });
  });

  test('ReceiptLine.lineTotal = quantity * purchasePrice', () {
    final line = ReceiptLine(
      productId: 'p1',
      quantity: 3,
      seriesNumber: 'S',
      expiryDate: DateTime(2027),
      purchasePrice: 12.5,
      salePrice: 20,
    );
    expect(line.lineTotal, 37.5);
  });

  test('Receipt.computedTotal sums line subtotals', () {
    final receipt = Receipt(
      id: 'r1',
      number: 'n',
      supplierId: 's',
      branchId: 'b',
      date: DateTime(2026),
      status: ReceiptStatus.draft,
      total: 0,
      lines: [
        ReceiptLine(
          productId: 'p1',
          quantity: 2,
          seriesNumber: 'S',
          expiryDate: DateTime(2027),
          purchasePrice: 10,
          salePrice: 15,
        ),
        ReceiptLine(
          productId: 'p2',
          quantity: 1,
          seriesNumber: 'S2',
          expiryDate: DateTime(2027),
          purchasePrice: 5,
          salePrice: 8,
        ),
      ],
    );
    expect(receipt.computedTotal, 25);
  });
}

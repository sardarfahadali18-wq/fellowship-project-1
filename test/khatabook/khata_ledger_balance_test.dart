import 'package:fellowship_project_1/khatabook/models/khata_transaction_data.dart';
import 'package:fellowship_project_1/khatabook/models/khata_txn_type.dart';
import 'package:fellowship_project_1/khatabook/services/ledger_repository.dart';
import 'package:flutter_test/flutter_test.dart';

KhataTransactionData _txn(KhataTxnType type, double amount) {
  return KhataTransactionData(
    id: 0,
    customerId: 1,
    type: type,
    amount: amount,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('computeKhataBalance', () {
    test('empty list settles at zero', () {
      expect(computeKhataBalance([]), 0.0);
    });

    test('gave-only transactions increase what the customer owes', () {
      final balance = computeKhataBalance([
        _txn(KhataTxnType.gave, 500),
        _txn(KhataTxnType.gave, 250),
      ]);
      expect(balance, 750.0);
    });

    test('got-only transactions go negative (vendor owes customer)', () {
      final balance = computeKhataBalance([
        _txn(KhataTxnType.got, 300),
      ]);
      expect(balance, -300.0);
    });

    test('mixed gave/got nets out correctly', () {
      final balance = computeKhataBalance([
        _txn(KhataTxnType.gave, 1000),
        _txn(KhataTxnType.got, 400),
        _txn(KhataTxnType.gave, 150),
      ]);
      expect(balance, 750.0);
    });

    test('overpayment leaves a negative balance', () {
      final balance = computeKhataBalance([
        _txn(KhataTxnType.gave, 100),
        _txn(KhataTxnType.got, 250),
      ]);
      expect(balance, -150.0);
    });
  });
}

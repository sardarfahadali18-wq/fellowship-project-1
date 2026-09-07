import 'package:fellowship_project_1/khatabook/models/khata_transaction_data.dart';
import 'package:fellowship_project_1/khatabook/models/khata_txn_type.dart';
import 'package:fellowship_project_1/khatabook/services/ledger_repository.dart';
import 'package:flutter_test/flutter_test.dart';

KhataTransactionData _transaction(
  KhataTxnType type,
  double amount,
  DateTime createdAt,
) {
  return KhataTransactionData(
    id: 0,
    customerId: 1,
    type: type,
    amount: amount,
    createdAt: createdAt,
  );
}

void main() {
  final now = DateTime(2026, 9, 8, 12);

  test('no transactions are not overdue', () {
    expect(isKhataCustomerOverdue([], now: now), isFalse);
  });

  test('recent credit is not overdue', () {
    final transactions = [
      _transaction(
        KhataTxnType.gave,
        100,
        now.subtract(const Duration(days: 29)),
      ),
    ];
    expect(isKhataCustomerOverdue(transactions, now: now), isFalse);
  });

  test('old credit with a positive balance is overdue', () {
    final transactions = [
      _transaction(
        KhataTxnType.gave,
        100,
        now.subtract(const Duration(days: 30)),
      ),
    ];
    expect(isKhataCustomerOverdue(transactions, now: now), isTrue);
  });

  test('old credit with zero or negative balance is not overdue', () {
    final oldCredit = now.subtract(const Duration(days: 30));
    expect(
      isKhataCustomerOverdue([
        _transaction(KhataTxnType.gave, 100, oldCredit),
        _transaction(KhataTxnType.got, 100, now),
      ], now: now),
      isFalse,
    );
    expect(
      isKhataCustomerOverdue([
        _transaction(KhataTxnType.gave, 100, oldCredit),
        _transaction(KhataTxnType.got, 150, now),
      ], now: now),
      isFalse,
    );
  });

  test('oldest gave transaction determines overdue status', () {
    final transactions = [
      _transaction(
        KhataTxnType.gave,
        25,
        now.subtract(const Duration(days: 10)),
      ),
      _transaction(
        KhataTxnType.gave,
        25,
        now.subtract(const Duration(days: 31)),
      ),
      _transaction(KhataTxnType.got, 10, now),
    ];
    expect(
      oldestGaveTransactionDate(transactions),
      now.subtract(const Duration(days: 31)),
    );
    expect(isKhataCustomerOverdue(transactions, now: now), isTrue);
  });

  test('payments affect the existing balance calculation', () {
    final transactions = [
      _transaction(
        KhataTxnType.gave,
        500,
        now.subtract(const Duration(days: 30)),
      ),
      _transaction(KhataTxnType.got, 200, now),
    ];
    expect(computeKhataBalance(transactions), 300);
    expect(isKhataCustomerOverdue(transactions, now: now), isTrue);
  });
}

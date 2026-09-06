import '../models/khata_customer_data.dart';
import '../models/khata_transaction_data.dart';
import '../models/khata_txn_type.dart';

/// Storage-agnostic contract for the ledger. [KhataLedgerRepository] (Isar,
/// used on Android/desktop) and [InMemoryKhataLedgerRepository] (used by the
/// Chrome/web demo, since Isar can't compile for web) both implement this.
abstract class LedgerRepository {
  Future<KhataCustomerData> addCustomer({
    required String name,
    String? phone,
    String? photoPath,
  });

  Future<List<KhataCustomerData>> listCustomers();

  Future<KhataTransactionData> addTransaction({
    required int customerId,
    required KhataTxnType type,
    required double amount,
    String? note,
    String? photoPath,
  });

  Future<List<KhataTransactionData>> transactionsForCustomer(int customerId);

  Future<double> balanceForCustomer(int customerId);
}

/// Positive balance = customer owes the vendor. Negative = vendor owes the
/// customer (overpayment). Pure function shared by both repository
/// implementations and directly unit-testable.
double computeKhataBalance(List<KhataTransactionData> transactions) {
  var balance = 0.0;
  for (final txn in transactions) {
    balance += txn.type == KhataTxnType.gave ? txn.amount : -txn.amount;
  }
  return balance;
}

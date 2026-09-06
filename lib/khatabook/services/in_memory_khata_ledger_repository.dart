import '../models/khata_customer_data.dart';
import '../models/khata_transaction_data.dart';
import '../models/khata_txn_type.dart';
import 'ledger_repository.dart';

/// In-memory [LedgerRepository], used only by the Chrome/web demo. Isar
/// (this app's real local database, used app-wide) cannot compile for web —
/// its generated schema code embeds 64-bit IDs that overflow JavaScript's
/// safe integer range — so the browser demo swaps in this non-persistent
/// implementation instead. Deliberately has no Isar dependency whatsoever
/// (direct or transitive) so it's safe to import from a web entry point.
/// The Android/desktop app keeps using the real Isar-backed
/// `KhataLedgerRepository` untouched.
class InMemoryKhataLedgerRepository implements LedgerRepository {
  final _customers = <KhataCustomerData>[];
  final _transactions = <KhataTransactionData>[];
  int _nextId = 1;

  @override
  Future<KhataCustomerData> addCustomer({
    required String name,
    String? phone,
    String? photoPath,
  }) async {
    final customer = KhataCustomerData(
      id: _nextId++,
      name: name,
      phone: phone,
      photoPath: photoPath,
      createdAt: DateTime.now(),
    );
    _customers.add(customer);
    return customer;
  }

  @override
  Future<List<KhataCustomerData>> listCustomers() async {
    final sorted = [..._customers]..sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }

  @override
  Future<KhataTransactionData> addTransaction({
    required int customerId,
    required KhataTxnType type,
    required double amount,
    String? note,
    String? photoPath,
  }) async {
    final txn = KhataTransactionData(
      id: _nextId++,
      customerId: customerId,
      type: type,
      amount: amount,
      note: note,
      photoPath: photoPath,
      createdAt: DateTime.now(),
    );
    _transactions.add(txn);
    return txn;
  }

  @override
  Future<List<KhataTransactionData>> transactionsForCustomer(int customerId) async {
    final matches = _transactions.where((t) => t.customerId == customerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return matches;
  }

  @override
  Future<double> balanceForCustomer(int customerId) async {
    return computeKhataBalance(await transactionsForCustomer(customerId));
  }
}

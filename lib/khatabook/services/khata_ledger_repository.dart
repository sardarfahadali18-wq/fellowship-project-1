import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../data/khatabook_isar_service.dart';
import '../models/khata_customer.dart';
import '../models/khata_customer_data.dart';
import '../models/khata_transaction.dart';
import '../models/khata_transaction_data.dart';
import 'ledger_repository.dart';

/// Isar-backed [LedgerRepository]: real, persistent storage used on
/// Android/desktop. For the Chrome/web demo, see
/// `InMemoryKhataLedgerRepository` instead — Isar cannot compile for web.
class KhataLedgerRepository implements LedgerRepository {
  final _uuid = const Uuid();

  Future<Isar> get _isar => KhataBookIsarService.getInstance();

  @override
  Future<KhataCustomerData> addCustomer({
    required String name,
    String? phone,
    String? photoPath,
  }) async {
    final isar = await _isar;
    final customer = KhataCustomer()
      ..uuid = _uuid.v4()
      ..name = name
      ..phone = phone
      ..photoPath = photoPath
      ..createdAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.khataCustomers.put(customer);
    });
    return customer.toData();
  }

  @override
  Future<List<KhataCustomerData>> listCustomers() async {
    final isar = await _isar;
    final customers = await isar.khataCustomers.where().sortByName().findAll();
    return customers.map((c) => c.toData()).toList();
  }

  @override
  Future<KhataTransactionData> addTransaction({
    required int customerId,
    required KhataTxnType type,
    required double amount,
    String? note,
    String? photoPath,
  }) async {
    final isar = await _isar;
    final txn = KhataTransaction()
      ..uuid = _uuid.v4()
      ..customerId = customerId
      ..type = type
      ..amount = amount
      ..note = note
      ..photoPath = photoPath
      ..createdAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.khataTransactions.put(txn);
    });
    return txn.toData();
  }

  @override
  Future<List<KhataTransactionData>> transactionsForCustomer(int customerId) async {
    final isar = await _isar;
    final transactions = await isar.khataTransactions
        .filter()
        .customerIdEqualTo(customerId)
        .sortByCreatedAtDesc()
        .findAll();
    return transactions.map((t) => t.toData()).toList();
  }

  @override
  Future<double> balanceForCustomer(int customerId) async {
    return computeKhataBalance(await transactionsForCustomer(customerId));
  }
}

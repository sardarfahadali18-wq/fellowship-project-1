import '../models/khata_customer_data.dart';
import '../models/khata_transaction_data.dart';
import '../models/khata_txn_type.dart';
import '../services/ledger_repository.dart';
import 'khata_sync_types.dart';

/// Wraps any [LedgerRepository] so every local write also lands in the sync
/// outbox. Reads pass straight through, so the ledger stays fully usable
/// offline and no UI or ledger code needs to know sync exists.
class SyncingLedgerRepository implements LedgerRepository {
  SyncingLedgerRepository(this._inner, this._store, {this.onQueued});

  final LedgerRepository _inner;
  final KhataSyncStore _store;
  final void Function()? onQueued;

  @override
  Future<KhataCustomerData> addCustomer({
    required String name,
    String? phone,
    String? photoPath,
  }) async {
    final customer = await _inner.addCustomer(
      name: name,
      phone: phone,
      photoPath: photoPath,
    );
    await _queue(KhataEntity.customers, customer.id);
    return customer;
  }

  @override
  Future<KhataTransactionData> addTransaction({
    required int customerId,
    required KhataTxnType type,
    required double amount,
    String? note,
    String? photoPath,
  }) async {
    final txn = await _inner.addTransaction(
      customerId: customerId,
      type: type,
      amount: amount,
      note: note,
      photoPath: photoPath,
    );
    await _queue(KhataEntity.transactions, txn.id);
    return txn;
  }

  @override
  Future<List<KhataCustomerData>> listCustomers() => _inner.listCustomers();

  @override
  Future<List<KhataTransactionData>> transactionsForCustomer(int customerId) =>
      _inner.transactionsForCustomer(customerId);

  @override
  Future<double> balanceForCustomer(int customerId) =>
      _inner.balanceForCustomer(customerId);

  Future<void> _queue(KhataEntity entity, int localId) async {
    await _store.enqueue(entity, localId);
    onQueued?.call();
  }
}

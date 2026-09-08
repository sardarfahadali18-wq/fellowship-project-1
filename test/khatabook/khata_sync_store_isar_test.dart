@Tags(['isar'])
library;

import 'dart:io';

import 'package:fellowship_project_1/khatabook/models/khata_customer.dart';
import 'package:fellowship_project_1/khatabook/models/khata_transaction.dart';
import 'package:fellowship_project_1/khatabook/models/khata_txn_type.dart';
import 'package:fellowship_project_1/khatabook/sync/khata_sync_op.dart';
import 'package:fellowship_project_1/khatabook/sync/khata_sync_types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

/// Exercises [IsarKhataSyncStore] against a real Isar database. Needs the
/// native Isar library, so it is tagged `isar` and skipped by default:
///   flutter test --tags isar --run-skipped test/khatabook
void main() {
  late Directory dir;
  late Isar isar;
  late IsarKhataSyncStore store;
  const uuid = Uuid();

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('khata_sync_test');
    isar = await Isar.open(
      [KhataCustomerSchema, KhataTransactionSchema, KhataSyncOpRowSchema],
      directory: dir.path,
      name: 'khatabook_test_${DateTime.now().microsecondsSinceEpoch}',
    );
    store = IsarKhataSyncStore(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  Future<KhataCustomer> addCustomer({String name = 'Ali'}) async {
    final customer = KhataCustomer()
      ..uuid = uuid.v4()
      ..name = name
      ..phone = '03001234567'
      ..photoPath = '/data/user/0/cache/ali.jpg'
      ..createdAt = DateTime.utc(2026, 3, 1);
    await isar.writeTxn(() => isar.khataCustomers.put(customer));
    return customer;
  }

  Future<KhataTransaction> addTxn(int customerId) async {
    final txn = KhataTransaction()
      ..uuid = uuid.v4()
      ..customerId = customerId
      ..type = KhataTxnType.gave
      ..amount = 250
      ..note = 'sugar'
      ..createdAt = DateTime.utc(2026, 3, 2);
    await isar.writeTxn(() => isar.khataTransactions.put(txn));
    return txn;
  }

  test('enqueue then claim yields the row once, with a future lease', () async {
    final customer = await addCustomer();
    await store.enqueue(KhataEntity.customers, customer.id);
    expect(await store.pending(), 1);

    final first = await store.claim();
    expect(first.single.uuid, customer.uuid);
    expect(first.single.attempts, 1);
    expect(await store.claim(), isEmpty);
  });

  test('repeat edits coalesce into a single outbox row', () async {
    final customer = await addCustomer();
    await store.enqueue(KhataEntity.customers, customer.id);
    await store.enqueue(KhataEntity.customers, customer.id);
    await store.enqueue(KhataEntity.customers, customer.id);
    expect(await store.pending(), 1);
  });

  test('a customer payload carries no device-local photo path', () async {
    final customer = await addCustomer();
    await store.enqueue(KhataEntity.customers, customer.id);
    final record = await store.payload((await store.claim()).single);

    expect(record!.data['name'], 'Ali');
    expect(record.data.containsKey('photoPath'), isFalse);
    expect(record.key, khataOpKey(KhataEntity.customers, customer.uuid));
  });

  test('a transaction payload references the customer uuid, not local id',
      () async {
    final customer = await addCustomer();
    final txn = await addTxn(customer.id);
    await store.enqueue(KhataEntity.transactions, txn.id);
    final record = await store.payload((await store.claim()).single);

    expect(record!.data['customerUuid'], customer.uuid);
    expect(record.data['type'], 'gave');
    expect(record.data['amount'], 250.0);
  });

  test('payload is null once the local row is gone', () async {
    final customer = await addCustomer();
    await store.enqueue(KhataEntity.customers, customer.id);
    final op = (await store.claim()).single;
    await isar.writeTxn(() => isar.khataCustomers.delete(customer.id));

    expect(await store.payload(op), isNull);
  });

  test('commit clears the claimed row', () async {
    final customer = await addCustomer();
    await store.enqueue(KhataEntity.customers, customer.id);
    await store.commit(await store.claim());

    expect(await store.pending(), 0);
  });

  test('commit keeps a newer edit that landed during the push', () async {
    final customer = await addCustomer();
    await store.enqueue(KhataEntity.customers, customer.id);
    final inFlight = await store.claim();

    await store.enqueue(KhataEntity.customers, customer.id);
    await store.commit(inFlight);

    expect(await store.pending(), 1);
    expect((await store.claim()).single.uuid, customer.uuid);
  });

  test('expedite clears the lease and the attempt count', () async {
    final customer = await addCustomer();
    await store.enqueue(KhataEntity.customers, customer.id);
    await store.claim();
    expect(await store.claim(), isEmpty);

    await store.expedite();
    final retried = await store.claim();
    expect(retried.single.attempts, 1);
  });

  test('claim stops handing out an op once the retry budget is spent',
      () async {
    final customer = await addCustomer();
    await store.enqueue(KhataEntity.customers, customer.id);

    for (var i = 0; i < 3; i++) {
      await store.expedite();
      final claimed = await store.claim(maxAttempts: 3);
      expect(claimed, hasLength(1));
      await store.release(claimed, error: 'boom');
      await isar.writeTxn(() async {
        final row = await isar.khataSyncOpRows.where().findFirst();
        row!.attempts = i + 1;
        row.nextAt = DateTime.utc(2020);
        await isar.khataSyncOpRows.put(row);
      });
    }
    expect(await store.claim(maxAttempts: 3), isEmpty);
    expect(await store.pending(), 1);
  });

  test('restore rebuilds a ledger and relinks transactions by uuid', () async {
    final customerUuid = uuid.v4();
    final applied = await store.applyRemote([
      KhataSyncRecord(
        entity: KhataEntity.customers,
        uuid: customerUuid,
        data: {
          'name': 'Restored Shop',
          'phone': '03001112222',
          'createdAt': '2026-02-01T00:00:00Z',
        },
      ),
      KhataSyncRecord(
        entity: KhataEntity.transactions,
        uuid: uuid.v4(),
        data: {
          'customerUuid': customerUuid,
          'type': 'got',
          'amount': 75.5,
          'note': null,
          'createdAt': '2026-02-02T00:00:00Z',
        },
      ),
    ]);

    expect(applied, 2);
    final customer = await isar.khataCustomers.getByUuid(customerUuid);
    final txn = await isar.khataTransactions.where().findFirst();
    expect(customer!.name, 'Restored Shop');
    expect(txn!.customerId, customer.id);
    expect(txn.type, KhataTxnType.got);
    expect(txn.amount, 75.5);
  });

  test('restore is idempotent and never duplicates rows', () async {
    final record = KhataSyncRecord(
      entity: KhataEntity.customers,
      uuid: uuid.v4(),
      data: {'name': 'Twice', 'createdAt': '2026-02-01T00:00:00Z'},
    );
    await store.applyRemote([record]);
    await store.applyRemote([record]);

    expect(await isar.khataCustomers.count(), 1);
  });

  test('restore drops a transaction whose customer is unknown', () async {
    final applied = await store.applyRemote([
      KhataSyncRecord(
        entity: KhataEntity.transactions,
        uuid: uuid.v4(),
        data: {
          'customerUuid': uuid.v4(),
          'type': 'gave',
          'amount': 10.0,
          'createdAt': '2026-02-02T00:00:00Z',
        },
      ),
    ]);

    expect(applied, 0);
    expect(await isar.khataTransactions.count(), 0);
  });
}

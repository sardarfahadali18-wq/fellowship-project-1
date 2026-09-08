import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/khata_customer.dart';
import '../models/khata_transaction.dart';
import 'khata_sync_types.dart';

part 'khata_sync_op.g.dart';

@collection
class KhataSyncOpRow {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String key;

  @enumerated
  late KhataEntity entity;

  @enumerated
  late KhataOpKind kind;

  late String uuid;

  late int localId;

  int attempts = 0;

  @Index()
  late DateTime nextAt;

  late DateTime createdAt;

  String? lastError;
}

const String kKhataCursorKey = 'khata_sync_cursor';
const Duration kKhataMinLease = Duration(seconds: 45);

class IsarKhataSyncStore implements KhataSyncStore {
  IsarKhataSyncStore(this._isar);

  final Isar _isar;

  @override
  Future<void> enqueue(
    KhataEntity entity,
    int localId, {
    KhataOpKind kind = KhataOpKind.upsert,
    String? uuid,
  }) async {
    final id = uuid ?? await _uuidOf(entity, localId);
    if (id == null) return;
    final now = DateTime.now().toUtc();
    final row = KhataSyncOpRow()
      ..key = khataOpKey(entity, id)
      ..entity = entity
      ..kind = kind
      ..uuid = id
      ..localId = localId
      ..nextAt = now
      ..createdAt = now;
    await _isar.writeTxn(() => _isar.khataSyncOpRows.put(row));
  }

  @override
  Future<List<KhataOp>> claim({
    int limit = 100,
    int maxAttempts = 8,
    DateTime? now,
  }) async {
    final at = (now ?? DateTime.now()).toUtc();
    final rows = await _isar.khataSyncOpRows
        .filter()
        .nextAtLessThan(at, include: true)
        .attemptsLessThan(maxAttempts)
        .sortByCreatedAt()
        .limit(limit)
        .findAll();
    if (rows.isEmpty) return const [];
    await _isar.writeTxn(() async {
      for (final row in rows) {
        row.attempts += 1;
        final lease = khataBackoff(row.attempts);
        row.nextAt = at.add(lease < kKhataMinLease ? kKhataMinLease : lease);
        await _isar.khataSyncOpRows.put(row);
      }
    });
    return rows
        .map(
          (row) => KhataOp(
            id: row.id,
            entity: row.entity,
            kind: row.kind,
            uuid: row.uuid,
            localId: row.localId,
            attempts: row.attempts,
          ),
        )
        .toList();
  }

  /// Only clears the exact row that was claimed. A newer local edit coalesced
  /// onto the same key resets [KhataSyncOpRow.attempts], so it survives an
  /// in-flight push instead of being dropped with it.
  @override
  Future<void> commit(List<KhataOp> ops) async {
    if (ops.isEmpty) return;
    await _isar.writeTxn(() async {
      for (final op in ops) {
        final row = await _isar.khataSyncOpRows.get(op.id);
        if (row == null || row.attempts != op.attempts) continue;
        await _isar.khataSyncOpRows.delete(op.id);
      }
    });
  }

  @override
  Future<void> release(List<KhataOp> ops, {String? error}) async {
    if (ops.isEmpty) return;
    await _isar.writeTxn(() async {
      for (final op in ops) {
        final row = await _isar.khataSyncOpRows.get(op.id);
        if (row == null) continue;
        row.lastError = khataText(error, kKhataMaxText);
        await _isar.khataSyncOpRows.put(row);
      }
    });
  }

  @override
  Future<void> expedite() async {
    final now = DateTime.now().toUtc();
    await _isar.writeTxn(() async {
      final rows = await _isar.khataSyncOpRows.where().findAll();
      for (final row in rows) {
        row.attempts = 0;
        row.nextAt = now;
        await _isar.khataSyncOpRows.put(row);
      }
    });
  }

  @override
  Future<int> pending() => _isar.khataSyncOpRows.count();

  @override
  Future<KhataSyncRecord?> payload(KhataOp op) async {
    if (op.kind == KhataOpKind.delete) {
      return KhataSyncRecord(
        entity: op.entity,
        uuid: op.uuid,
        kind: KhataOpKind.delete,
        data: const {},
      );
    }
    if (op.entity == KhataEntity.customers) {
      final row = await _isar.khataCustomers.get(op.localId);
      if (row == null || row.uuid != op.uuid) return null;
      return KhataSyncRecord(
        entity: op.entity,
        uuid: row.uuid,
        data: {
          'name': row.name,
          'phone': row.phone,
          'createdAt': row.createdAt.toUtc().toIso8601String(),
        },
      );
    }
    final row = await _isar.khataTransactions.get(op.localId);
    if (row == null || row.uuid != op.uuid) return null;
    final owner = await _isar.khataCustomers.get(row.customerId);
    if (owner == null) return null;
    return KhataSyncRecord(
      entity: op.entity,
      uuid: row.uuid,
      data: {
        'customerUuid': owner.uuid,
        'type': row.type.name,
        'amount': row.amount,
        'note': row.note,
        'createdAt': row.createdAt.toUtc().toIso8601String(),
      },
    );
  }

  @override
  Future<int> applyRemote(List<KhataSyncRecord> records) async {
    var applied = 0;
    await _isar.writeTxn(() async {
      for (final record in records.where(
        (r) => r.entity == KhataEntity.customers,
      )) {
        if (record.kind == KhataOpKind.delete) {
          applied += await _isar.khataCustomers.deleteByUuid(record.uuid) ? 1 : 0;
          continue;
        }
        final row =
            await _isar.khataCustomers.getByUuid(record.uuid) ??
            (KhataCustomer()..uuid = record.uuid);
        row
          ..name = record.data['name'] as String
          ..phone = record.data['phone'] as String?
          ..createdAt = khataParseTime(record.data['createdAt']);
        await _isar.khataCustomers.put(row);
        applied += 1;
      }
      for (final record in records.where(
        (r) => r.entity == KhataEntity.transactions,
      )) {
        if (record.kind == KhataOpKind.delete) {
          applied +=
              await _isar.khataTransactions.deleteByUuid(record.uuid) ? 1 : 0;
          continue;
        }
        final owner = await _isar.khataCustomers.getByUuid(
          record.data['customerUuid'] as String,
        );
        if (owner == null) continue;
        final row =
            await _isar.khataTransactions.getByUuid(record.uuid) ??
            (KhataTransaction()..uuid = record.uuid);
        row
          ..customerId = owner.id
          ..type = record.data['type'] == 'got'
              ? KhataTxnType.got
              : KhataTxnType.gave
          ..amount = (record.data['amount'] as num).toDouble()
          ..note = record.data['note'] as String?
          ..createdAt = khataParseTime(record.data['createdAt']);
        await _isar.khataTransactions.put(row);
        applied += 1;
      }
    });
    return applied;
  }

  @override
  Future<DateTime?> cursor() async {
    final raw = (await SharedPreferences.getInstance()).getString(
      kKhataCursorKey,
    );
    return raw == null ? null : DateTime.tryParse(raw);
  }

  @override
  Future<void> setCursor(DateTime at) async {
    await (await SharedPreferences.getInstance()).setString(
      kKhataCursorKey,
      at.toUtc().toIso8601String(),
    );
  }

  Future<String?> _uuidOf(KhataEntity entity, int localId) async =>
      entity == KhataEntity.customers
      ? (await _isar.khataCustomers.get(localId))?.uuid
      : (await _isar.khataTransactions.get(localId))?.uuid;
}

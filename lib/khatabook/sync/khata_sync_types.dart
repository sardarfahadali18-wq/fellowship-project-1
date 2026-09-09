import 'dart:math';

enum KhataEntity { customers, transactions }

enum KhataOpKind { upsert, delete }

enum KhataSyncState { idle, syncing, offline, error, done }

const int kKhataMaxText = 120;
const int kKhataMaxNote = 500;
const double kKhataMaxAmount = 1e9;
const Duration kKhataBackoffCap = Duration(seconds: 900);

final RegExp _uuidRe = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  caseSensitive: false,
);
final Random _rng = Random();

String khataOpKey(KhataEntity entity, String uuid) => '${entity.name}:$uuid';

class KhataOp {
  const KhataOp({
    required this.id,
    required this.entity,
    required this.kind,
    required this.uuid,
    required this.localId,
    required this.attempts,
  });

  final int id;
  final KhataEntity entity;
  final KhataOpKind kind;
  final String uuid;
  final int localId;
  final int attempts;

  String get key => khataOpKey(entity, uuid);
}

class KhataSyncRecord {
  const KhataSyncRecord({
    required this.entity,
    required this.uuid,
    required this.data,
    this.kind = KhataOpKind.upsert,
    this.updatedAt,
  });

  final KhataEntity entity;
  final String uuid;
  final Map<String, dynamic> data;
  final KhataOpKind kind;
  final DateTime? updatedAt;

  String get key => khataOpKey(entity, uuid);

  KhataSyncRecord withData(Map<String, dynamic> next) => KhataSyncRecord(
    entity: entity,
    uuid: uuid,
    data: next,
    kind: kind,
    updatedAt: updatedAt,
  );
}

class KhataPushResult {
  const KhataPushResult({required this.accepted, this.error});

  final Set<String> accepted;
  final String? error;

  bool get ok => error == null;
}

class KhataPullPage {
  const KhataPullPage({required this.records, this.cursor});

  final List<KhataSyncRecord> records;
  final DateTime? cursor;
}

class KhataSyncStatus {
  const KhataSyncStatus({
    required this.state,
    required this.pending,
    this.message,
    this.syncedAt,
  });

  final KhataSyncState state;
  final int pending;
  final String? message;
  final DateTime? syncedAt;
}

abstract class KhataSyncApi {
  Future<KhataPushResult> push(List<KhataSyncRecord> records);

  Future<KhataPullPage> pull({DateTime? since});
}

abstract class KhataSyncStore {
  Future<void> enqueue(
    KhataEntity entity,
    int localId, {
    KhataOpKind kind = KhataOpKind.upsert,
    String? uuid,
  });

  Future<List<KhataOp>> claim({int limit, int maxAttempts, DateTime? now});

  Future<void> commit(List<KhataOp> ops);

  Future<void> release(List<KhataOp> ops, {String? error});

  Future<void> expedite();

  Future<int> pending();

  Future<KhataSyncRecord?> payload(KhataOp op);

  Future<int> applyRemote(List<KhataSyncRecord> records);

  Future<DateTime?> cursor();

  Future<void> setCursor(DateTime at);
}

Duration khataBackoff(int attempts, {Random? rng}) {
  final secs = min(1 << attempts.clamp(1, 20), kKhataBackoffCap.inSeconds);
  return Duration(seconds: secs + (rng ?? _rng).nextInt(1 + secs ~/ 4));
}

DateTime khataParseTime(Object? value) {
  if (value is DateTime) return value.toUtc();
  final parsed = DateTime.tryParse(value?.toString() ?? '');
  return (parsed ?? DateTime.now()).toUtc();
}

String? khataText(Object? value, int max) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) return null;
  return text.length <= max ? text : text.substring(0, max);
}

String? khataPhone(Object? value) {
  final text = khataText(value, 24);
  if (text == null) return null;
  final digits = text.replaceAll(RegExp(r'[^0-9+]'), '');
  return digits.length < 4 ? null : digits;
}

/// Untrusted boundary: anything read back from the cloud is rebuilt field by
/// field here, so a malformed or tampered document can never reach local Isar.
KhataSyncRecord? sanitizeKhataRecord(KhataSyncRecord record) {
  if (!_uuidRe.hasMatch(record.uuid)) return null;
  if (record.kind == KhataOpKind.delete) return record.withData(const {});
  final data = record.data;
  final createdAt = khataParseTime(data['createdAt']);

  if (record.entity == KhataEntity.customers) {
    final name = khataText(data['name'], kKhataMaxText);
    if (name == null) return null;
    return record.withData({
      'name': name,
      'phone': khataPhone(data['phone']),
      'createdAt': createdAt.toIso8601String(),
    });
  }

  final amount = data['amount'] is num ? (data['amount'] as num).toDouble() : null;
  final type = data['type']?.toString();
  final customerUuid = data['customerUuid']?.toString() ?? '';
  if (amount == null || !amount.isFinite || amount < 0 || amount > kKhataMaxAmount) {
    return null;
  }
  if (type != 'gave' && type != 'got') return null;
  if (!_uuidRe.hasMatch(customerUuid)) return null;
  return record.withData({
    'customerUuid': customerUuid,
    'type': type,
    'amount': amount,
    'note': khataText(data['note'], kKhataMaxNote),
    'createdAt': createdAt.toIso8601String(),
  });
}

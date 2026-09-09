import 'dart:math';

import 'package:fellowship_project_1/khatabook/sync/khata_sync_engine.dart';
import 'package:fellowship_project_1/khatabook/sync/khata_sync_types.dart';
import 'package:fellowship_project_1/sync/connectivity_service.dart';
import 'package:flutter_test/flutter_test.dart';

const String _uuidA = '11111111-2222-4333-8444-555555555555';
const String _uuidB = 'aaaaaaaa-bbbb-4ccc-8ddd-eeeeeeeeeeee';

class _Row {
  _Row(this.op, this.record);

  KhataOp op;
  final KhataSyncRecord? record;
  DateTime nextAt = DateTime.utc(2020);
}

class _FakeStore implements KhataSyncStore {
  final List<_Row> rows = [];
  final List<KhataSyncRecord> applied = [];
  DateTime? saved;
  int nextId = 1;
  int? lastMaxAttempts;

  void seed(KhataEntity entity, String uuid, {bool orphaned = false}) {
    final id = nextId++;
    rows.add(
      _Row(
        KhataOp(
          id: id,
          entity: entity,
          kind: KhataOpKind.upsert,
          uuid: uuid,
          localId: id,
          attempts: 0,
        ),
        orphaned
            ? null
            : KhataSyncRecord(entity: entity, uuid: uuid, data: {'name': 'X'}),
      ),
    );
  }

  @override
  Future<void> enqueue(
    KhataEntity entity,
    int localId, {
    KhataOpKind kind = KhataOpKind.upsert,
    String? uuid,
  }) async => seed(entity, uuid ?? _uuidA);

  @override
  Future<List<KhataOp>> claim({
    int limit = 100,
    int maxAttempts = 8,
    DateTime? now,
  }) async {
    lastMaxAttempts = maxAttempts;
    final at = now ?? DateTime.now().toUtc();
    final due = rows
        .where((r) => !r.nextAt.isAfter(at) && r.op.attempts < maxAttempts)
        .take(limit)
        .toList();
    for (final row in due) {
      row.op = KhataOp(
        id: row.op.id,
        entity: row.op.entity,
        kind: row.op.kind,
        uuid: row.op.uuid,
        localId: row.op.localId,
        attempts: row.op.attempts + 1,
      );
      row.nextAt = at.add(khataBackoff(row.op.attempts));
    }
    return due.map((r) => r.op).toList();
  }

  @override
  Future<void> commit(List<KhataOp> ops) async {
    final ids = ops.map((o) => o.id).toSet();
    rows.removeWhere((r) => ids.contains(r.op.id));
  }

  @override
  Future<void> release(List<KhataOp> ops, {String? error}) async {}

  @override
  Future<void> expedite() async {
    for (final row in rows) {
      row.nextAt = DateTime.utc(2020);
      row.op = KhataOp(
        id: row.op.id,
        entity: row.op.entity,
        kind: row.op.kind,
        uuid: row.op.uuid,
        localId: row.op.localId,
        attempts: 0,
      );
    }
  }

  @override
  Future<int> pending() async => rows.length;

  @override
  Future<KhataSyncRecord?> payload(KhataOp op) async =>
      rows.firstWhere((r) => r.op.id == op.id).record;

  @override
  Future<int> applyRemote(List<KhataSyncRecord> records) async {
    applied.addAll(records);
    return records.length;
  }

  @override
  Future<DateTime?> cursor() async => saved;

  @override
  Future<void> setCursor(DateTime at) async => saved = at;
}

class _FakeApi implements KhataSyncApi {
  _FakeApi({this.error, this.reject = const {}, this.page});

  final String? error;
  final Set<String> reject;
  final KhataPullPage? page;
  final List<KhataSyncRecord> pushed = [];
  int pulls = 0;
  DateTime? lastSince;

  @override
  Future<KhataPushResult> push(List<KhataSyncRecord> records) async {
    if (error != null) {
      return KhataPushResult(accepted: const {}, error: error);
    }
    pushed.addAll(records);
    return KhataPushResult(
      accepted: records
          .map((r) => r.key)
          .where((k) => !reject.contains(k))
          .toSet(),
    );
  }

  @override
  Future<KhataPullPage> pull({DateTime? since}) async {
    pulls += 1;
    lastSince = since;
    return page ?? const KhataPullPage(records: []);
  }
}

class _OfflineConnectivity extends ConnectivityService {
  @override
  Future<bool> checkOnline() async => false;
}

KhataSyncRecord _customer(Map<String, dynamic> data, {String uuid = _uuidA}) =>
    KhataSyncRecord(entity: KhataEntity.customers, uuid: uuid, data: data);

KhataSyncRecord _txn(Map<String, dynamic> data) =>
    KhataSyncRecord(entity: KhataEntity.transactions, uuid: _uuidB, data: data);

void main() {
  group('backoff', () {
    test('grows, never shrinks, and stays under the cap', () {
      final rng = Random(7);
      var previous = Duration.zero;
      for (var attempt = 1; attempt <= 20; attempt++) {
        final delay = khataBackoff(attempt, rng: rng);
        expect(delay.inSeconds, greaterThanOrEqualTo(2));
        expect(
          delay.inSeconds,
          lessThanOrEqualTo(kKhataBackoffCap.inSeconds * 5 ~/ 4),
        );
        if (attempt > 1) {
          expect(delay.inSeconds * 2, greaterThanOrEqualTo(previous.inSeconds));
        }
        previous = delay;
      }
    });
  });

  group('sanitizeKhataRecord', () {
    test('keeps a valid customer and drops device-local fields', () {
      final record = sanitizeKhataRecord(
        _customer({
          'name': ' Ali Store ',
          'phone': '+92 300 1234567',
          'photoPath': '/data/user/0/app/cache/ali.jpg',
          'createdAt': '2026-01-02T03:04:05Z',
        }),
      );
      expect(record!.data['name'], 'Ali Store');
      expect(record.data['phone'], '+923001234567');
      expect(record.data.containsKey('photoPath'), isFalse);
      expect(record.data['createdAt'], '2026-01-02T03:04:05.000Z');
    });

    test('clamps oversized text instead of failing', () {
      final record = sanitizeKhataRecord(
        _customer({'name': 'x' * 500, 'note': 'y' * 900}),
      );
      expect((record!.data['name'] as String).length, kKhataMaxText);
    });

    test('rejects a nameless customer and a bad uuid', () {
      expect(sanitizeKhataRecord(_customer({'name': '   '})), isNull);
      expect(
        sanitizeKhataRecord(_customer({'name': 'Ok'}, uuid: 'not-a-uuid')),
        isNull,
      );
    });

    test('rejects unusable transaction amounts and types', () {
      final base = {
        'customerUuid': _uuidA,
        'type': 'gave',
        'amount': 100.0,
      };
      expect(sanitizeKhataRecord(_txn(base))!.data['amount'], 100.0);
      expect(sanitizeKhataRecord(_txn({...base, 'amount': -1})), isNull);
      expect(sanitizeKhataRecord(_txn({...base, 'amount': 1e12})), isNull);
      expect(
        sanitizeKhataRecord(_txn({...base, 'amount': double.nan})),
        isNull,
      );
      expect(sanitizeKhataRecord(_txn({...base, 'type': 'drop'})), isNull);
      expect(
        sanitizeKhataRecord(_txn({...base, 'customerUuid': '../other'})),
        isNull,
      );
    });

    test('entity is part of the identity key', () {
      expect(
        _customer(const {'name': 'a'}).key,
        isNot(
          KhataSyncRecord(
            entity: KhataEntity.transactions,
            uuid: _uuidA,
            data: const {},
          ).key,
        ),
      );
    });
  });

  group('KhataSyncEngine', () {
    test('drains the outbox and clears it', () async {
      final store = _FakeStore()
        ..seed(KhataEntity.customers, _uuidA)
        ..seed(KhataEntity.transactions, _uuidB);
      final api = _FakeApi();
      final status = await KhataSyncEngine(store: store, api: api).sync();

      expect(api.pushed.length, 2);
      expect(store.rows, isEmpty);
      expect(status.state, KhataSyncState.done);
      expect(status.pending, 0);
    });

    test('a failed push keeps every op for a later retry', () async {
      final store = _FakeStore()..seed(KhataEntity.customers, _uuidA);
      final status = await KhataSyncEngine(
        store: store,
        api: _FakeApi(error: 'unavailable'),
      ).sync();

      expect(store.rows.length, 1);
      expect(status.state, KhataSyncState.error);
      expect(status.message, 'unavailable');
    });

    test('a partly accepted batch only clears what the server took', () async {
      final store = _FakeStore()
        ..seed(KhataEntity.customers, _uuidA)
        ..seed(KhataEntity.transactions, _uuidB);
      final status = await KhataSyncEngine(
        store: store,
        api: _FakeApi(reject: {khataOpKey(KhataEntity.transactions, _uuidB)}),
      ).sync();

      expect(store.rows.single.op.uuid, _uuidB);
      expect(status.state, KhataSyncState.error);
    });

    test('offline sync touches no network and reports offline', () async {
      final store = _FakeStore()..seed(KhataEntity.customers, _uuidA);
      final api = _FakeApi();
      final status = await KhataSyncEngine(
        store: store,
        api: api,
        connectivity: _OfflineConnectivity(),
      ).sync();

      expect(api.pushed, isEmpty);
      expect(api.pulls, 0);
      expect(status.state, KhataSyncState.offline);
      expect(status.pending, 1);
    });

    test('backoff gates retries and a forced sync overrides it', () async {
      final store = _FakeStore()..seed(KhataEntity.customers, _uuidA);
      final api = _FakeApi(
        reject: {khataOpKey(KhataEntity.customers, _uuidA)},
      );
      final engine = KhataSyncEngine(store: store, api: api, maxAttempts: 3);

      await engine.sync();
      expect(store.lastMaxAttempts, 3);
      expect(store.rows.single.op.attempts, 1);
      expect(api.pushed.length, 1);

      await engine.sync();
      expect(api.pushed.length, 1);

      await engine.sync(force: true);
      expect(api.pushed.length, 2);
      expect(store.rows.single.op.attempts, 1);
    });

    test('an op whose local row vanished is dropped, not retried', () async {
      final store = _FakeStore()
        ..seed(KhataEntity.customers, _uuidA, orphaned: true);
      final api = _FakeApi();
      await KhataSyncEngine(store: store, api: api).sync();

      expect(api.pushed, isEmpty);
      expect(store.rows, isEmpty);
    });

    test('sync pulls incrementally and stores the cursor', () async {
      final store = _FakeStore()..saved = DateTime.utc(2026, 1, 1);
      final cursor = DateTime.utc(2026, 5, 5);
      final api = _FakeApi(
        page: KhataPullPage(
          records: [_customer(const {'name': 'Remote'})],
          cursor: cursor,
        ),
      );
      await KhataSyncEngine(store: store, api: api).sync();

      expect(api.lastSince, DateTime.utc(2026, 1, 1));
      expect(store.applied.length, 1);
      expect(store.saved, cursor);
    });

    test('restore replays the whole backup from scratch', () async {
      final store = _FakeStore()..saved = DateTime.utc(2026, 1, 1);
      final api = _FakeApi(
        page: KhataPullPage(
          records: [
            _customer(const {'name': 'A'}),
            _txn(const {'customerUuid': _uuidA, 'type': 'got', 'amount': 5.0}),
          ],
          cursor: DateTime.utc(2026, 6, 6),
        ),
      );
      final applied = await KhataSyncEngine(store: store, api: api).restore();

      expect(applied, 2);
      expect(api.lastSince, isNull);
      expect(store.saved, DateTime.utc(2026, 6, 6));
    });

    test('a broken restore never loses queued local writes', () async {
      final store = _FakeStore()..seed(KhataEntity.customers, _uuidA);
      final api = _ThrowingPullApi();
      final status = await KhataSyncEngine(store: store, api: api).sync();

      expect(api.pushed.length, 1);
      expect(store.rows, isEmpty);
      expect(status.state, KhataSyncState.error);
      expect(status.message, 'restore-unavailable');
    });
  });
}

class _ThrowingPullApi extends _FakeApi {
  @override
  Future<KhataPullPage> pull({DateTime? since}) async =>
      throw StateError('sign-in required');
}

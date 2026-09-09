import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../sync/connectivity_service.dart';
import 'khata_sync_types.dart';

class KhataSyncEngine {
  KhataSyncEngine({
    required KhataSyncStore store,
    required KhataSyncApi api,
    ConnectivityService? connectivity,
    this.batchSize = 100,
    this.maxAttempts = 8,
  }) : _store = store,
       _api = api,
       _connectivity = connectivity;

  final KhataSyncStore _store;
  final KhataSyncApi _api;
  final ConnectivityService? _connectivity;
  final int batchSize;
  final int maxAttempts;

  final ValueNotifier<KhataSyncStatus> status = ValueNotifier(
    const KhataSyncStatus(state: KhataSyncState.idle, pending: 0),
  );

  bool _busy = false;
  StreamSubscription<bool>? _sub;

  void start() {
    _sub ??= _connectivity?.onStatusChange.listen((online) {
      if (online) {
        unawaited(sync(force: true));
      } else {
        unawaited(_emit(KhataSyncState.offline));
      }
    });
  }

  Future<KhataSyncStatus> sync({bool force = false, bool restoreAll = false}) async {
    if (_busy) return status.value;
    _busy = true;
    try {
      if (!(await (_connectivity?.checkOnline() ?? Future.value(true)))) {
        return _emit(KhataSyncState.offline);
      }
      await _emit(KhataSyncState.syncing);
      if (force) await _store.expedite();
      final pushError = await _pushAll();
      final pullError = await _pullSafely(restoreAll);
      final problem = pushError ?? pullError;
      return _emit(
        problem == null ? KhataSyncState.done : KhataSyncState.error,
        message: problem,
        syncedAt: DateTime.now(),
      );
    } finally {
      _busy = false;
    }
  }

  Future<int> restore() async {
    final page = await _api.pull(since: null);
    final applied = await _store.applyRemote(page.records);
    if (page.cursor != null) await _store.setCursor(page.cursor!);
    await _emit(KhataSyncState.done, syncedAt: DateTime.now());
    return applied;
  }

  Future<String?> _pushAll() async {
    String? problem;
    while (true) {
      final ops = await _store.claim(
        limit: batchSize,
        maxAttempts: maxAttempts,
      );
      if (ops.isEmpty) break;

      final live = <KhataOp>[];
      final stale = <KhataOp>[];
      final records = <KhataSyncRecord>[];
      for (final op in ops) {
        final record = await _store.payload(op);
        if (record == null) {
          stale.add(op);
        } else {
          live.add(op);
          records.add(record);
        }
      }
      await _store.commit(stale);
      if (records.isEmpty) continue;

      final result = await _api.push(records);
      final sent = <KhataOp>[];
      final kept = <KhataOp>[];
      for (var i = 0; i < live.length; i++) {
        (result.accepted.contains(records[i].key) ? sent : kept).add(live[i]);
      }
      await _store.commit(sent);
      if (kept.isNotEmpty) {
        problem = result.error ?? 'not-acknowledged';
        await _store.release(kept, error: problem);
      }
      if (!result.ok || ops.length < batchSize) break;
    }
    return problem;
  }

  Future<String?> _pullSafely(bool all) async {
    try {
      final since = all ? null : await _store.cursor();
      final page = await _api.pull(since: since);
      if (page.records.isNotEmpty) await _store.applyRemote(page.records);
      if (page.cursor != null) await _store.setCursor(page.cursor!);
      return null;
    } catch (_) {
      return 'restore-unavailable';
    }
  }

  Future<KhataSyncStatus> _emit(
    KhataSyncState state, {
    String? message,
    DateTime? syncedAt,
  }) async {
    final next = KhataSyncStatus(
      state: state,
      pending: await _store.pending(),
      message: message,
      syncedAt: syncedAt ?? status.value.syncedAt,
    );
    status.value = next;
    return next;
  }

  Future<void> refresh() => _emit(status.value.state);

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
    status.dispose();
  }
}

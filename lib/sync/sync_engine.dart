import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../data/models/sync_event.dart';
import 'connectivity_service.dart';
import 'sync_api_client.dart';

/// High-level state surfaced to the UI sync indicator.
enum SyncState { idle, syncing, success, offline, error }

class SyncStatusSnapshot {
  const SyncStatusSnapshot({
    required this.state,
    required this.pending,
    this.message,
    this.lastSyncedAt,
  });

  final SyncState state;
  final int pending;
  final String? message;
  final DateTime? lastSyncedAt;

  SyncStatusSnapshot copyWith({
    SyncState? state,
    int? pending,
    String? message,
    DateTime? lastSyncedAt,
  }) {
    return SyncStatusSnapshot(
      state: state ?? this.state,
      pending: pending ?? this.pending,
      message: message,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}

/// Drains the outbox to the backend and pulls the content manifest.
///
/// Design goals:
///  * Offline-first: never throws to callers; failures leave events pending.
///  * Idempotent: every event carries a UUID so retries are safe server-side.
///  * Resumable: a partial/failed batch keeps un-acked events for next run.
///  * Bounded retries with backoff so a poison event can't spin forever.
class SyncEngine {
  SyncEngine({
    required Isar isar,
    required SyncApi api,
    required ConnectivityService connectivity,
    this.batchSize = 50,
    this.maxAttempts = 5,
  })  : _isar = isar,
        _api = api,
        _connectivity = connectivity;

  final Isar _isar;
  final SyncApi _api;
  final ConnectivityService _connectivity;
  final int batchSize;
  final int maxAttempts;

  /// Observable status for the UI (sync indicator, "Sync now" button).
  final ValueNotifier<SyncStatusSnapshot> status = ValueNotifier(
    const SyncStatusSnapshot(state: SyncState.idle, pending: 0),
  );

  bool _running = false;
  StreamSubscription<bool>? _connSub;

  /// Auto-sync whenever the device comes back online.
  void startAutoSync() {
    _connSub ??= _connectivity.onStatusChange.listen((online) {
      if (online) {
        // Fire-and-forget; errors are captured in status.
        unawaited(syncNow());
      } else {
        _emit(state: SyncState.offline);
      }
    });
  }

  Future<void> stop() async {
    await _connSub?.cancel();
    _connSub = null;
  }

  /// Full sync pass: push the outbox, then pull the manifest. Safe to call from
  /// the "Sync now" button, connectivity changes, or the background worker.
  Future<SyncStatusSnapshot> syncNow() async {
    if (_running) return status.value;
    _running = true;
    try {
      final online = await _connectivity.checkOnline();
      if (!online) {
        return _emit(state: SyncState.offline, pending: await _pendingCount());
      }

      _emit(state: SyncState.syncing, pending: await _pendingCount());

      final pushed = await _pushOutbox();
      if (!pushed) {
        return _emit(
          state: SyncState.error,
          pending: await _pendingCount(),
          message: 'Some events could not sync; will retry.',
        );
      }

      // Pull is best-effort; a manifest failure shouldn't fail the whole sync.
      try {
        await pullManifest();
      } catch (_) {}

      return _emit(
        state: SyncState.success,
        pending: await _pendingCount(),
        lastSyncedAt: DateTime.now(),
      );
    } finally {
      _running = false;
    }
  }

  /// Pushes pending/failed events in batches. Returns true if the outbox is
  /// fully drained (or nothing was left), false if anything remains to retry.
  Future<bool> _pushOutbox() async {
    var allClear = true;

    while (true) {
      final batch = await _isar.syncEvents
          .filter()
          .statusEqualTo(SyncStatus.pending)
          .or()
          .statusEqualTo(SyncStatus.failed)
          .sortByCreatedAt()
          .limit(batchSize)
          .findAll();

      // Skip events that have already exhausted their retry budget.
      final sendable =
          batch.where((e) => e.attemptCount < maxAttempts).toList();
      if (sendable.isEmpty) {
        if (batch.isNotEmpty) allClear = false; // poison events remain
        break;
      }

      // Mark in-flight so a concurrent run won't double-send them.
      await _isar.writeTxn(() async {
        for (final e in sendable) {
          e.status = SyncStatus.inFlight;
          e.attemptCount += 1;
          e.lastAttemptAt = DateTime.now().toUtc();
          await _isar.syncEvents.put(e);
        }
      });

      final payload = sendable.map(_toWire).toList();
      final result = await _api.pushEvents(payload);

      await _isar.writeTxn(() async {
        for (final e in sendable) {
          if (result.acceptedUuids.contains(e.uuid)) {
            e.status = SyncStatus.synced;
            e.lastError = null;
          } else {
            // Not acked: back to pending, or fail permanently once out of tries.
            e.status = e.attemptCount >= maxAttempts
                ? SyncStatus.failed
                : SyncStatus.pending;
            e.lastError = result.serverError ?? 'not acknowledged';
            allClear = false;
          }
          await _isar.syncEvents.put(e);
        }
      });

      // Whole-request failure (offline mid-sync / 5xx): stop and resume later.
      if (!result.isSuccess) {
        allClear = false;
        break;
      }

      // Fewer than a full batch means the queue is drained.
      if (sendable.length < batchSize) break;
    }

    // Housekeeping: drop events the server has confirmed.
    await _isar.writeTxn(() async {
      await _isar.syncEvents
          .filter()
          .statusEqualTo(SyncStatus.synced)
          .deleteAll();
    });

    return allClear;
  }

  /// Checks the backend content version. Returns the manifest so the UI /
  /// download flow (Adil) can decide whether new packs need fetching.
  Future<ContentManifest> pullManifest() {
    return _api.fetchManifest();
  }

  Map<String, dynamic> _toWire(SyncEvent e) => {
        'uuid': e.uuid,
        'type': e.type.name,
        'studentId': e.studentId,
        'payload': jsonDecode(e.payloadJson),
        'createdAt': e.createdAt.toIso8601String(),
      };

  Future<int> _pendingCount() {
    return _isar.syncEvents
        .filter()
        .statusEqualTo(SyncStatus.pending)
        .or()
        .statusEqualTo(SyncStatus.inFlight)
        .or()
        .statusEqualTo(SyncStatus.failed)
        .count();
  }

  SyncStatusSnapshot _emit({
    required SyncState state,
    int? pending,
    String? message,
    DateTime? lastSyncedAt,
  }) {
    final snap = SyncStatusSnapshot(
      state: state,
      pending: pending ?? status.value.pending,
      message: message,
      lastSyncedAt: lastSyncedAt ?? status.value.lastSyncedAt,
    );
    status.value = snap;
    return snap;
  }

  void dispose() {
    status.dispose();
  }
}

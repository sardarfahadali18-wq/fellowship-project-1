import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fellowship_project_1/models/walk_session.dart';
import 'package:fellowship_project_1/services/firestore_walk_session_store.dart';
import 'package:fellowship_project_1/services/walk_session_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final startedAt = DateTime.utc(2026, 8, 21, 10, 0);

  WalkSession session({
    WalkSessionStatus status = WalkSessionStatus.active,
    double? lat,
    double? lng,
    DateTime? at,
  }) =>
      WalkSession(
        id: 'walk1',
        ownerUid: 'stale',
        startedAt: startedAt,
        plannedDuration: const Duration(minutes: 30),
        destinationLat: 31.53,
        destinationLng: 74.37,
        status: status,
        lastLat: lat,
        lastLng: lng,
        lastUpdatedAt: at,
        sharedWithContactIds: const ['c1'],
      );

  group('parent payload', () {
    final store = FirestoreWalkSessionStore(throttle: Duration.zero);

    test('overrides ownerUid and uses server time for the date fields', () {
      final data = store.parentPayload('uid1', session(), created: false);

      expect(data[WalkSession.keyOwnerUid], 'uid1');
      expect(data[WalkSession.keyStartedAt], isA<FieldValue>());
      expect(data[WalkSession.keyLastUpdatedAt], isA<FieldValue>());
      expect(data.containsKey(WalkSession.keyEndedAt), isFalse);
    });

    test('omits startedAt once the document exists', () {
      final data = store.parentPayload('uid1', session(), created: true);

      expect(data.containsKey(WalkSession.keyStartedAt), isFalse);
      expect(data[WalkSession.keyLastUpdatedAt], isA<FieldValue>());
    });

    test('writes endedAt only when the walk is finished', () {
      final done = store.parentPayload(
          'uid1', session(status: WalkSessionStatus.completed),
          created: true);

      expect(done[WalkSession.keyEndedAt], isA<FieldValue>());
    });

    test('never leaves a device clock value on a server time field', () {
      final data = store.parentPayload('uid1', session(), created: false);

      expect(data[WalkSession.keyStartedAt], isNot(isA<String>()));
      expect(data[WalkSession.keyLastUpdatedAt], isNot(isA<String>()));
    });
  });

  test('round trips through the payload, Firestore types, and fromMap', () {
    final store = FirestoreWalkSessionStore(throttle: Duration.zero);
    final original = session(
        status: WalkSessionStatus.completed,
        lat: 31.52,
        lng: 74.35,
        at: startedAt);

    final written = store.parentPayload('uid1', original, created: false);
    final asStored = written.map((k, v) => MapEntry(
        k, v is FieldValue ? Timestamp.fromDate(startedAt) : v));
    final restored = WalkSession.fromMap(
        original.id, FirestoreWalkSessionStore.normalize(asStored));

    expect(restored.id, original.id);
    expect(restored.ownerUid, 'uid1');
    expect(restored.startedAt, startedAt);
    expect(restored.endedAt, startedAt);
    expect(restored.lastUpdatedAt, startedAt);
    expect(restored.plannedDuration, original.plannedDuration);
    expect(restored.destinationLat, original.destinationLat);
    expect(restored.lastLat, original.lastLat);
    expect(restored.status, WalkSessionStatus.completed);
    expect(restored.sharedWithContactIds, original.sharedWithContactIds);
  });

  group('throttle', () {
    final now = DateTime.utc(2026, 8, 21, 12, 0);
    const throttle = Duration(seconds: 10);

    test('flushes the first write', () {
      expect(
          shouldFlush(
              throttle: throttle, now: now, finished: false, lastFlush: null),
          isTrue);
    });

    test('holds a write inside the window', () {
      expect(
          shouldFlush(
              throttle: throttle,
              now: now,
              finished: false,
              lastFlush: now.subtract(const Duration(seconds: 9))),
          isFalse);
    });

    test('flushes once the window has passed', () {
      expect(
          shouldFlush(
              throttle: throttle,
              now: now,
              finished: false,
              lastFlush: now.subtract(const Duration(seconds: 10))),
          isTrue);
    });

    test('a finished walk ignores the window', () {
      expect(
          shouldFlush(
              throttle: throttle,
              now: now,
              finished: true,
              lastFlush: now.subtract(const Duration(seconds: 1))),
          isTrue);
    });
  });

  group('point queue', () {
    test('queues one point per new position', () {
      final store = FirestoreWalkSessionStore();

      store.enqueuePoint(session(lat: 1, lng: 2, at: startedAt));
      store.enqueuePoint(session(lat: 1, lng: 2, at: startedAt));
      store.enqueuePoint(session(
          lat: 3, lng: 4, at: startedAt.add(const Duration(seconds: 5))));

      expect(store.queuedPoints, 2);
    });

    test('ignores a session with no position', () {
      final store = FirestoreWalkSessionStore();

      store.enqueuePoint(session());

      expect(store.queuedPoints, 0);
    });

    test('caps the queue at maxQueuedPoints', () {
      final store = FirestoreWalkSessionStore();

      for (var i = 0; i < FirestoreWalkSessionStore.maxQueuedPoints + 25; i++) {
        store.enqueuePoint(session(
            lat: 1, lng: 2, at: startedAt.add(Duration(seconds: i))));
      }

      expect(store.queuedPoints, FirestoreWalkSessionStore.maxQueuedPoints);
    });
  });

  test('isFinished covers every status', () {
    expect(session().isFinished, isFalse);
    expect(session(status: WalkSessionStatus.overdue).isFinished, isFalse);
    expect(session(status: WalkSessionStatus.completed).isFinished, isTrue);
    expect(session(status: WalkSessionStatus.cancelled).isFinished, isTrue);
  });

  test('a null point timestamp cannot bypass the dedupe', () {
    final store = FirestoreWalkSessionStore();
    final noTime = session(lat: 1, lng: 2);

    store.enqueuePoint(noTime);
    store.enqueuePoint(noTime);
    store.enqueuePoint(noTime);

    expect(store.queuedPoints, 1);
  });

  group('sent points are removed by identity, not by index', () {
    test('a point queued during an in flight commit is not swept away', () {
      final store = FirestoreWalkSessionStore();
      for (var i = 0; i < FirestoreWalkSessionStore.maxQueuedPoints; i++) {
        store.enqueuePoint(session(
            lat: 1, lng: 2, at: startedAt.add(Duration(seconds: i))));
      }
      expect(store.queuedPoints, FirestoreWalkSessionStore.maxQueuedPoints);

      final sending = store.snapshotQueue();
      store.enqueuePoint(session(
          lat: 9, lng: 9, at: startedAt.add(const Duration(hours: 1))));
      store.removeSentPoints(sending);

      expect(store.queuedPoints, 1);
      expect(store.snapshotQueue().single[FirestoreWalkSessionStore.keyPointLat],
          9);
    });

    test('a clean commit empties the queue', () {
      final store = FirestoreWalkSessionStore();
      store.enqueuePoint(session(lat: 1, lng: 2, at: startedAt));
      store.enqueuePoint(session(
          lat: 3, lng: 4, at: startedAt.add(const Duration(seconds: 5))));

      store.removeSentPoints(store.snapshotQueue());

      expect(store.queuedPoints, 0);
    });
  });

  test('the same position at a new time queues a new point', () {
    final store = FirestoreWalkSessionStore();

    store.enqueuePoint(session(lat: 1, lng: 2, at: startedAt));
    store.enqueuePoint(session(
        lat: 1, lng: 2, at: startedAt.add(const Duration(seconds: 5))));

    expect(store.queuedPoints, 2);
  });
}

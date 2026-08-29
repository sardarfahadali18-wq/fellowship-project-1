import 'package:fellowship_project_1/models/walk_session.dart';
import 'package:fellowship_project_1/services/fake_location_service.dart';
import 'package:fellowship_project_1/services/location_service.dart';
import 'package:fellowship_project_1/services/walk_session_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'walk_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('H1 a walk is persisted while it runs, not only at the end', () {
    test('positions are saved mid walk', () async {
      final location = FakeLocationService(tick: fast);
      final store = MemoryStore();
      final service = buildService(location, store);

      await service.start(plannedDuration: long);
      await Future<void>.delayed(settle);

      expect(store.saveCalls, greaterThan(1));
      expect(store.saved.single.lastLat, isNotNull);

      await service.end();
      await location.stop();
    });

    test('an interrupted walk still leaves a record', () async {
      final location = FakeLocationService(tick: fast);
      final store = MemoryStore();
      final service = buildService(location, store);

      await service.start(plannedDuration: long);
      await Future<void>.delayed(settle);

      expect(store.saved, isNotEmpty);
      expect(store.saved.single.status, WalkSessionStatus.active);

      await location.stop();
    });

    test('flags are persisted when they fire', () async {
      final location = FakeLocationService(tick: fast);
      final store = MemoryStore();
      final service = buildService(location, store);

      await service.start(plannedDuration: long);
      final before = store.saveCalls;
      await service.flagDeviation(metresOffRoute: 120);
      await service.flagMissedCheckIn(dueAt: DateTime.utc(2026, 8, 21));

      expect(store.saveCalls, before + 2);
      expect(store.saved.single.lastDeviationMetres, 120);
      expect(store.saved.single.missedCheckInAt, isNotNull);

      await service.end();
      await location.stop();
    });
  });

  group('H1 the prefs store throttles so it is not written every fix', () {
    Future<PrefsWalkSessionStore> build({String uid = 'uid1'}) async {
      SharedPreferences.setMockInitialValues({});
      return PrefsWalkSessionStore(await SharedPreferences.getInstance(),
          uid: () => uid, throttle: const Duration(seconds: 10));
    }

    WalkSession live(int i) => WalkSession(
          id: 'walk1',
          ownerUid: 'uid1',
          startedAt: DateTime.utc(2026, 8, 21, 10, 0),
          plannedDuration: const Duration(minutes: 30),
          lastLat: 1.0 + i,
          lastLng: 2.0,
        );

    test('rapid saves collapse into one write', () async {
      final store = await build();

      for (var i = 0; i < 8; i++) {
        await store.save(live(i));
      }

      expect((await store.loadAll()).single.lastLat, 1.0);
      expect(store.hasUnsyncedWrites, isTrue);
      store.dispose();
    });

    test('a finished walk is written immediately, ignoring the throttle',
        () async {
      final store = await build();

      await store.save(live(0));
      await store.save(
          live(5).copyWith(status: WalkSessionStatus.completed));

      expect((await store.loadAll()).single.lastLat, 6.0);
      expect((await store.loadAll()).single.status,
          WalkSessionStatus.completed);
      store.dispose();
    });
  });

  group('H2 local history is scoped to the signed in user', () {
    test('one user cannot see another user on the same device', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final ayesha = PrefsWalkSessionStore(prefs,
          uid: () => 'ayesha', throttle: Duration.zero);
      final bilal = PrefsWalkSessionStore(prefs,
          uid: () => 'bilal', throttle: Duration.zero);

      await ayesha.save(WalkSession(
          id: 'a1',
          ownerUid: 'ayesha',
          startedAt: DateTime.utc(2026, 8, 21, 10, 0),
          plannedDuration: const Duration(minutes: 30)));
      await bilal.save(WalkSession(
          id: 'b1',
          ownerUid: 'bilal',
          startedAt: DateTime.utc(2026, 8, 21, 11, 0),
          plannedDuration: const Duration(minutes: 30)));

      expect((await ayesha.loadAll()).map((s) => s.id), ['a1']);
      expect((await bilal.loadAll()).map((s) => s.id), ['b1']);
    });

    test('one user saving does not delete the other user data', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ayesha = PrefsWalkSessionStore(prefs,
          uid: () => 'ayesha', throttle: Duration.zero);
      final bilal = PrefsWalkSessionStore(prefs,
          uid: () => 'bilal', throttle: Duration.zero);

      await ayesha.save(WalkSession(
          id: 'a1',
          ownerUid: 'ayesha',
          startedAt: DateTime.utc(2026, 8, 21, 10, 0),
          plannedDuration: const Duration(minutes: 30)));
      await bilal.save(WalkSession(
          id: 'b1',
          ownerUid: 'bilal',
          startedAt: DateTime.utc(2026, 8, 21, 11, 0),
          plannedDuration: const Duration(minutes: 30)));

      expect((await ayesha.loadAll()).single.id, 'a1');
    });

    test('the store stamps the owner even if the model disagrees', () async {
      SharedPreferences.setMockInitialValues({});
      final store = PrefsWalkSessionStore(
          await SharedPreferences.getInstance(),
          uid: () => 'ayesha',
          throttle: Duration.zero);

      await store.save(WalkSession(
          id: 'a1',
          ownerUid: 'someone-else',
          startedAt: DateTime.utc(2026, 8, 21, 10, 0),
          plannedDuration: const Duration(minutes: 30)));

      expect((await store.loadAll()).single.ownerUid, 'ayesha');
    });

    test('legacy records with no owner are invisible to a signed in user',
        () async {
      SharedPreferences.setMockInitialValues({
        PrefsWalkSessionStore.storageKey:
            '[{"id":"legacy1","ownerUid":"","plannedDurationMs":0}]'
      });
      final prefs = await SharedPreferences.getInstance();

      final signedIn = PrefsWalkSessionStore(prefs,
          uid: () => 'ayesha', throttle: Duration.zero);
      final anonymous =
          PrefsWalkSessionStore(prefs, throttle: Duration.zero);

      expect(await signedIn.loadAll(), isEmpty);
      expect((await anonymous.loadAll()).single.id, 'legacy1');
    });

    test('delete cannot remove another user record', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ayesha = PrefsWalkSessionStore(prefs,
          uid: () => 'ayesha', throttle: Duration.zero);
      final bilal = PrefsWalkSessionStore(prefs,
          uid: () => 'bilal', throttle: Duration.zero);

      await ayesha.save(WalkSession(
          id: 'a1',
          ownerUid: 'ayesha',
          startedAt: DateTime.utc(2026, 8, 21, 10, 0),
          plannedDuration: const Duration(minutes: 30)));

      await bilal.delete('a1');

      expect((await ayesha.loadAll()).single.id, 'a1');
    });

    test('clear only clears the current user', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ayesha = PrefsWalkSessionStore(prefs,
          uid: () => 'ayesha', throttle: Duration.zero);
      final bilal = PrefsWalkSessionStore(prefs,
          uid: () => 'bilal', throttle: Duration.zero);

      await ayesha.save(WalkSession(
          id: 'a1',
          ownerUid: 'ayesha',
          startedAt: DateTime.utc(2026, 8, 21, 10, 0),
          plannedDuration: const Duration(minutes: 30)));
      await bilal.save(WalkSession(
          id: 'b1',
          ownerUid: 'bilal',
          startedAt: DateTime.utc(2026, 8, 21, 11, 0),
          plannedDuration: const Duration(minutes: 30)));

      await bilal.clear();

      expect((await ayesha.loadAll()).single.id, 'a1');
      expect(await bilal.loadAll(), isEmpty);
    });
  });

  group('H5 a failed write is observable', () {
    test('the service reports unsynced writes without throwing', () async {
      final location = FakeLocationService(tick: fast);
      final store = MemoryStore(failSaves: true);
      final service = buildService(location, store);

      expect(service.hasUnsyncedWrites, isFalse);

      await service.start(plannedDuration: long);
      await Future<void>.delayed(settle);

      expect(service.hasUnsyncedWrites, isTrue);
      expect(store.saveCalls, greaterThan(1));

      await location.stop();
    });
  });

  group('M1 location does not run without an active session', () {
    test('nothing is emitted before start', () async {
      final location = FakeLocationService(tick: fast);
      final service = buildService(location, MemoryStore());

      final seen = <LocationSample>[];
      final sub = service.locationStream.listen(seen.add);
      await Future<void>.delayed(settle);

      expect(seen, isEmpty);

      await sub.cancel();
      await location.stop();
    });

    test('samples flow during a walk and stop after it ends', () async {
      final location = FakeLocationService(tick: fast);
      final service = buildService(location, MemoryStore());

      final seen = <LocationSample>[];
      final sub = service.locationStream.listen(seen.add);

      await service.start(plannedDuration: long);
      await Future<void>.delayed(settle);
      expect(seen, isNotEmpty);

      await service.end();
      final afterEnd = seen.length;
      await Future<void>.delayed(settle);

      expect(seen.length, afterEnd);
      await sub.cancel();
    });
  });

  group('M3 dispose', () {
    test('closes streams, kills timers and disposes the store', () async {
      final location = FakeLocationService(tick: fast);
      final store = MemoryStore();
      final service = buildService(location, store);

      await service.start(plannedDuration: long);
      await service.dispose();

      expect(service.activeSession, isNull);
      expect(store.disposed, isTrue);

      var sessionsDone = false;
      var locationsDone = false;
      service.sessionStream.listen(null, onDone: () => sessionsDone = true);
      service.locationStream.listen(null, onDone: () => locationsDone = true);
      await Future<void>.delayed(Duration.zero);

      expect(sessionsDone, isTrue);
      expect(locationsDone, isTrue);
      await location.stop();
    });
  });

  group('M4 lastUpdatedAt is receipt time', () {
    test('it is not the epoch based sample time from the fake', () async {
      final location = FakeLocationService(tick: fast);
      final service = buildService(location, MemoryStore());

      await service.start(plannedDuration: long);
      await Future<void>.delayed(settle);

      final stamp = service.activeSession!.lastUpdatedAt!;
      final sampleTime = FakeLocationService.route.first.at;

      expect(stamp.isAfter(sampleTime), isTrue);
      expect(stamp.year, greaterThan(2020));

      await service.end();
      await location.stop();
    });
  });
}

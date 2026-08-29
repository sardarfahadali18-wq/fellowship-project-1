import 'package:fellowship_project_1/models/walk_session.dart';
import 'package:fellowship_project_1/services/fake_location_service.dart';
import 'package:fellowship_project_1/services/walk_session_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'walk_support.dart';

void main() {
  late MemoryStore store;
  late FakeLocationService location;
  late WalkSessionService service;

  setUp(() {
    store = MemoryStore();
    location = FakeLocationService(tick: fast);
    service = buildService(location, store);
  });

  tearDown(() => location.stop());

  test('start then end completes and saves', () async {
    await service.start(plannedDuration: long);
    expect(service.activeSession, isNotNull);

    await service.end();

    expect(service.activeSession, isNull);
    expect(store.saved.single.status, WalkSessionStatus.completed);
    expect(store.saved.single.endedAt, isNotNull);
    expect(store.saved.single.ownerUid, 'uid1');
  });

  test('start then cancel saves as cancelled', () async {
    await service.start(plannedDuration: long);
    await service.cancel();

    expect(service.activeSession, isNull);
    expect(store.saved.single.status, WalkSessionStatus.cancelled);
  });

  test('overdue fires when the planned duration elapses', () async {
    await service.start(plannedDuration: brief);
    await Future<void>.delayed(settle);

    expect(service.activeSession?.status, WalkSessionStatus.overdue);
    expect(service.remaining, Duration.zero);
  });

  test('positions update the last known location', () async {
    await service.start(plannedDuration: long);
    await Future<void>.delayed(settle);

    expect(service.activeSession?.lastLat, isNotNull);
    expect(service.activeSession?.lastLng, isNotNull);
    expect(service.activeSession?.lastUpdatedAt, isNotNull);
  });

  test('timer and subscription are dead after end', () async {
    await service.start(plannedDuration: brief);
    await service.end();

    final after = <WalkSession>[];
    final sub = service.sessionStream.listen(after.add);
    await Future<void>.delayed(settle);
    await sub.cancel();

    expect(after, isEmpty);
    expect(service.activeSession, isNull);
  });

  test('timer and subscription are dead after cancel', () async {
    await service.start(plannedDuration: brief);
    await service.cancel();

    final after = <WalkSession>[];
    final sub = service.sessionStream.listen(after.add);
    await Future<void>.delayed(settle);
    await sub.cancel();

    expect(after, isEmpty);
    expect(service.activeSession, isNull);
  });

  test('supports a second walk after the first ends', () async {
    await service.start(plannedDuration: long);
    await service.end();

    await service.start(plannedDuration: long);
    await Future<void>.delayed(settle);

    expect(service.activeSession?.lastLat, isNotNull);

    await service.end();
    expect(store.saved.length, 2);
  });

  test('init registers the singleton', () {
    WalkSessionService.init(service);
    expect(WalkSessionService.instance, same(service));
  });
}

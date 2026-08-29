import 'package:fellowship_project_1/models/walk_session.dart';
import 'package:fellowship_project_1/services/fake_location_service.dart';
import 'package:fellowship_project_1/services/location_service.dart';
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

  test('double start throws', () async {
    await service.start(plannedDuration: long);

    await expectLater(service.start(plannedDuration: long), throwsStateError);
    expect(service.activeSession, isNotNull);
  });

  test('end and cancel with no session are safe', () async {
    await service.end();
    await service.cancel();

    expect(service.activeSession, isNull);
    expect(store.saved, isEmpty);
  });

  test('start refuses when permission is not granted', () async {
    for (final state in [
      LocationPermissionState.denied,
      LocationPermissionState.deniedForever,
      LocationPermissionState.serviceDisabled,
    ]) {
      final blocked = buildService(
          FakeLocationService(tick: fast, permission: state), MemoryStore());

      await expectLater(blocked.start(plannedDuration: long), throwsStateError);
      expect(blocked.activeSession, isNull);
    }
  });

  test('flags record a deviation and a missed check-in', () async {
    final due = DateTime.utc(2026, 8, 21, 10, 30);
    await service.start(plannedDuration: long);
    await service.flagDeviation(metresOffRoute: 180);
    await service.flagMissedCheckIn(dueAt: due);

    expect(service.activeSession?.lastDeviationMetres, 180);
    expect(service.activeSession?.missedCheckInAt, due);
  });

  test('flags are ignored with no active session', () async {
    await service.flagDeviation(metresOffRoute: 180);
    await service.flagMissedCheckIn(dueAt: DateTime.utc(2026, 8, 21));

    expect(service.activeSession, isNull);
  });

  test('start mints a share token and end clears it', () async {
    final session = await service.start(plannedDuration: long);

    expect(session.shareToken, isNotNull);
    expect(session.shareToken!.length, greaterThanOrEqualTo(24));

    await service.end();

    expect(store.saved.single.shareToken, isNull);
  });

  test('cancel also clears the share token', () async {
    await service.start(plannedDuration: long);
    await service.cancel();

    expect(store.saved.single.shareToken, isNull);
  });

  test('the token survives updates during the walk', () async {
    final started = await service.start(plannedDuration: long);
    await service.flagDeviation(metresOffRoute: 50);
    await Future<void>.delayed(settle);

    expect(service.activeSession?.shareToken, started.shareToken);
  });

  test('two walks get different tokens', () async {
    final first = await service.start(plannedDuration: long);
    await service.end();
    final second = await service.start(plannedDuration: long);
    await service.end();

    expect(first.shareToken, isNot(second.shareToken));
  });

  test('contact ids are capped at the model limit', () async {
    final ids = List.generate(WalkSession.maxSharedContacts + 5, (i) => 'c$i');
    final session = await service.start(plannedDuration: long, contactIds: ids);

    expect(session.sharedWithContactIds.length, WalkSession.maxSharedContacts);
  });
}

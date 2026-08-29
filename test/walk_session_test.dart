import 'package:fellowship_project_1/models/walk_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final startedAt = DateTime.utc(2026, 8, 21, 10, 0);

  WalkSession build() => WalkSession(
        id: 'walk1',
        ownerUid: 'uid1',
        startedAt: startedAt,
        plannedDuration: const Duration(minutes: 30),
        endedAt: startedAt.add(const Duration(minutes: 45)),
        destinationLat: 31.53,
        destinationLng: 74.37,
        status: WalkSessionStatus.overdue,
        lastLat: 31.521,
        lastLng: 74.359,
        lastUpdatedAt: startedAt,
        sharedWithContactIds: const ['c1', 'c2'],
        lastDeviationMetres: 120.5,
        missedCheckInAt: startedAt.add(const Duration(minutes: 31)),
      );

  test('round trips every field', () {
    final original = build();
    final restored = WalkSession.fromMap(original.id, original.toMap());

    expect(restored.toMap(), original.toMap());
    expect(restored.status, WalkSessionStatus.overdue);
    expect(restored.destinationLat, 31.53);
    expect(restored.lastDeviationMetres, 120.5);
    expect(restored.missedCheckInAt, original.missedCheckInAt);
  });

  test('toMap leaves the document id out', () {
    expect(build().toMap().containsKey('id'), isFalse);
  });

  test('fromMap survives an empty map', () {
    final session = WalkSession.fromMap('walk2', const {});

    expect(session.ownerUid, '');
    expect(session.startedAt, WalkSession.epoch);
    expect(session.endedAt, isNull);
    expect(session.plannedDuration, Duration.zero);
    expect(session.status, WalkSessionStatus.active);
    expect(session.destinationLat, isNull);
    expect(session.sharedWithContactIds, isEmpty);
    expect(session.lastDeviationMetres, isNull);
    expect(session.missedCheckInAt, isNull);
  });

  test('fromMap survives nulls and wrong types', () {
    final session = WalkSession.fromMap('walk3', const {
      WalkSession.keyOwnerUid: 42,
      WalkSession.keyStartedAt: null,
      WalkSession.keyPlannedDurationMs: 'soon',
      WalkSession.keyDestinationLat: 'north',
      WalkSession.keyStatus: 'exploded',
      WalkSession.keySharedWithContactIds: 'c1',
      WalkSession.keyLastDeviationMetres: [],
      WalkSession.keyMissedCheckInAt: 900,
    });

    expect(session.ownerUid, '');
    expect(session.startedAt, WalkSession.epoch);
    expect(session.plannedDuration, Duration.zero);
    expect(session.destinationLat, isNull);
    expect(session.status, WalkSessionStatus.active);
    expect(session.sharedWithContactIds, isEmpty);
    expect(session.lastDeviationMetres, isNull);
    expect(session.missedCheckInAt, isNull);
  });

  test('reads integer coordinates as doubles', () {
    final session = WalkSession.fromMap(
      'walk4',
      const {WalkSession.keyLastLat: 31, WalkSession.keyLastLng: 74},
    );

    expect(session.lastLat, 31.0);
    expect(session.lastLng, 74.0);
  });

  test('caps sharedWithContactIds on read', () {
    final ids = List.generate(
      WalkSession.maxSharedContacts + 5,
      (i) => 'contact$i',
    );
    final session = WalkSession.fromMap(
      'walk5',
      {WalkSession.keySharedWithContactIds: ids},
    );

    expect(session.sharedWithContactIds.length, WalkSession.maxSharedContacts);
    expect(session.sharedWithContactIds.first, 'contact0');
  });

  test('copyWith records a deviation and a missed check-in', () {
    final original = WalkSession(
      id: 'walk6',
      ownerUid: 'uid1',
      startedAt: startedAt,
      plannedDuration: const Duration(minutes: 30),
    );
    final flagged = original.copyWith(
      lastDeviationMetres: 240.0,
      missedCheckInAt: startedAt.add(const Duration(minutes: 31)),
      status: WalkSessionStatus.overdue,
    );

    expect(flagged.lastDeviationMetres, 240.0);
    expect(flagged.missedCheckInAt, startedAt.add(const Duration(minutes: 31)));
    expect(flagged.status, WalkSessionStatus.overdue);
    expect(original.lastDeviationMetres, isNull);
    expect(original.missedCheckInAt, isNull);
  });

  test('copyWith keeps identity and changes nothing when empty', () {
    final original = build();
    final updated = original.copyWith(
      status: WalkSessionStatus.completed,
      lastLat: 1.5,
      lastLng: 2.5,
    );

    expect(updated.status, WalkSessionStatus.completed);
    expect(updated.lastLat, 1.5);
    expect(updated.id, original.id);
    expect(updated.ownerUid, original.ownerUid);
    expect(updated.startedAt, original.startedAt);
    expect(updated.destinationLat, original.destinationLat);
    expect(original.copyWith().toMap(), original.toMap());
  });
}

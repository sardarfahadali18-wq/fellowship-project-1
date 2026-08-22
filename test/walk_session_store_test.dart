import 'package:fellowship_project_1/models/walk_session.dart';
import 'package:fellowship_project_1/services/walk_session_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<PrefsWalkSessionStore> build() async {
    SharedPreferences.setMockInitialValues({});
    return PrefsWalkSessionStore(await SharedPreferences.getInstance(),
        uid: () => 'uid1', throttle: Duration.zero);
  }

  WalkSession session(int i) => WalkSession(
        id: 'walk$i',
        ownerUid: 'uid1',
        startedAt: DateTime.utc(2026, 8, 21).add(Duration(minutes: i)),
        plannedDuration: const Duration(minutes: 30),
      );

  test('round trips a saved session', () async {
    final store = await build();
    await store.save(session(1));

    final loaded = await store.loadAll();

    expect(loaded.single.id, 'walk1');
    expect(loaded.single.ownerUid, 'uid1');
    expect(loaded.single.plannedDuration, const Duration(minutes: 30));
  });

  test('caps history at maxEntries, newest first', () async {
    final store = await build();
    for (var i = 0; i < PrefsWalkSessionStore.maxEntries + 5; i++) {
      await store.save(session(i));
    }

    final loaded = await store.loadAll();

    expect(loaded.length, PrefsWalkSessionStore.maxEntries);
    expect(loaded.first.id, 'walk54');
  });

  test('an unsaved key loads as empty', () async {
    expect(await (await build()).loadAll(), isEmpty);
  });

  test('corrupt or non-list data returns empty', () async {
    SharedPreferences.setMockInitialValues(
        {PrefsWalkSessionStore.storageKey: 'not json'});
    final prefs = await SharedPreferences.getInstance();

    expect(await PrefsWalkSessionStore(prefs).loadAll(), isEmpty);

    await prefs.setString(PrefsWalkSessionStore.storageKey, '{"a":1}');
    expect(await PrefsWalkSessionStore(prefs).loadAll(), isEmpty);
  });

  test('entries with no id are dropped', () async {
    SharedPreferences.setMockInitialValues(
        {PrefsWalkSessionStore.storageKey: '[{"ownerUid":"uid1"}]'});
    final prefs = await SharedPreferences.getInstance();

    expect(await PrefsWalkSessionStore(prefs).loadAll(), isEmpty);
  });

  test('delete removes one and clear removes all', () async {
    final store = await build();
    await store.save(session(1));
    await store.save(session(2));

    await store.delete('walk1');
    expect((await store.loadAll()).single.id, 'walk2');

    await store.clear();
    expect(await store.loadAll(), isEmpty);
  });
}

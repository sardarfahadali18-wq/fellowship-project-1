import 'package:fellowship_project_1/models/walk_session.dart';
import 'package:fellowship_project_1/services/fake_location_service.dart';
import 'package:fellowship_project_1/services/walk_session_service.dart';
import 'package:fellowship_project_1/services/walk_session_store.dart';

const fast = Duration(milliseconds: 1);
const settle = Duration(milliseconds: 60);
const long = Duration(minutes: 5);
const brief = Duration(milliseconds: 10);

class MemoryStore implements WalkSessionStore {
  MemoryStore({this.failSaves = false});

  final bool failSaves;
  final saved = <WalkSession>[];

  int saveCalls = 0;
  bool disposed = false;
  bool _failed = false;

  @override
  bool get hasUnsyncedWrites => _failed;

  @override
  void dispose() => disposed = true;

  @override
  Future<void> save(WalkSession session) async {
    saveCalls++;
    if (failSaves) {
      _failed = true;
      throw StateError('offline');
    }
    saved.removeWhere((s) => s.id == session.id);
    saved.add(session);
  }

  @override
  Future<List<WalkSession>> loadAll() async => saved;

  @override
  Future<void> delete(String id) async => saved.removeWhere((s) => s.id == id);

  @override
  Future<void> clear() async => saved.clear();
}

WalkSessionService buildService(
        FakeLocationService location, WalkSessionStore store) =>
    WalkSessionService(
        location: location, store: store, tick: fast, uid: () => 'uid1');

import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/walk_session.dart';

bool shouldFlush({
  required Duration throttle,
  required DateTime now,
  required bool finished,
  DateTime? lastFlush,
}) =>
    finished || lastFlush == null || now.difference(lastFlush) >= throttle;

abstract class WalkSessionStore {
  Future<void> save(WalkSession session);
  Future<List<WalkSession>> loadAll();
  Future<void> delete(String id);
  Future<void> clear();

  bool get hasUnsyncedWrites => false;

  void dispose() {}
}

class PrefsWalkSessionStore implements WalkSessionStore {
  PrefsWalkSessionStore(this._prefs,
      {String Function()? uid, this.throttle = const Duration(seconds: 10)})
      : _uid = uid;

  static const storageKey = 'walk_sessions';
  static const maxEntries = 50;
  static const keyId = 'id';

  final SharedPreferences _prefs;
  final String Function()? _uid;
  final Duration throttle;

  DateTime? _lastWrite;
  Timer? _pending;
  bool _failed = false;

  String get currentUid => _uid?.call() ?? '';

  @override
  bool get hasUnsyncedWrites => _pending != null || _failed;

  @override
  void dispose() {
    _pending?.cancel();
    _pending = null;
  }

  WalkSession _owned(WalkSession session) => session.ownerUid == currentUid
      ? session
      : WalkSession.fromMap(session.id,
          {...session.toMap(), WalkSession.keyOwnerUid: currentUid});

  List<WalkSession> _readAll() {
    final raw = _prefs.getString(storageKey);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .map((e) => WalkSession.fromMap(e[keyId]?.toString() ?? '', e))
          .where((s) => s.id.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<WalkSession>> loadAll() async {
    final mine =
        _readAll().where((s) => s.ownerUid == currentUid).toList();
    mine.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return mine.take(maxEntries).toList();
  }

  @override
  Future<void> save(WalkSession session) async {
    final owned = _owned(session);
    _failed = false;
    if (shouldFlush(
        throttle: throttle,
        now: DateTime.now(),
        finished: owned.isFinished,
        lastFlush: _lastWrite)) {
      _pending?.cancel();
      _pending = null;
      await _put(owned);
      return;
    }
    if (_pending != null) return;
    _pending = Timer(throttle, () {
      _pending = null;
      _put(owned).catchError((_) => _failed = true);
    });
  }

  @override
  Future<void> delete(String id) async {
    final all = _readAll();
    all.removeWhere((s) => s.id == id && s.ownerUid == currentUid);
    await _write(all);
  }

  @override
  Future<void> clear() async {
    final others =
        _readAll().where((s) => s.ownerUid != currentUid).toList();
    if (others.isEmpty) {
      await _prefs.remove(storageKey);
      return;
    }
    await _write(others);
  }

  Future<void> _put(WalkSession session) async {
    final all = _readAll();
    all.removeWhere((s) => s.id == session.id);
    all.insert(0, session);
    await _write(all);
    _lastWrite = DateTime.now();
  }

  Future<void> _write(List<WalkSession> sessions) async {
    final encoded = jsonEncode(sessions
        .take(maxEntries)
        .map((s) => {keyId: s.id, ...s.toMap()})
        .toList());
    final ok = await _prefs.setString(storageKey, encoded);
    if (!ok) {
      _failed = true;
      throw StateError('Could not save walk history.');
    }
  }
}

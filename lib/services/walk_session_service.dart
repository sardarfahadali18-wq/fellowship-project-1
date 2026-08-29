import 'dart:async';
import 'dart:math';

import '../models/walk_session.dart';
import 'location_service.dart';
import 'walk_session_store.dart';

class WalkSessionService {
  WalkSessionService({
    required LocationService location,
    required WalkSessionStore store,
    String Function()? uid,
    Duration tick = const Duration(seconds: 1),
  }) : _location = location, _store = store, _uid = uid, _tick = tick;

  static WalkSessionService? _instance;
  static WalkSessionService get instance =>
      _instance ?? (throw StateError('WalkSessionService.init() first.'));
  static WalkSessionService init(WalkSessionService service) =>
      _instance = service;

  final LocationService _location;
  final WalkSessionStore _store;
  final String Function()? _uid;
  final Duration _tick;
  final _sessions = StreamController<WalkSession>.broadcast();
  final _locations = StreamController<LocationSample>.broadcast();

  WalkSession? _active;
  Timer? _timer;
  StreamSubscription<LocationSample>? _sub;

  WalkSession? get activeSession => _active;
  Stream<WalkSession> get sessionStream => _sessions.stream;
  Stream<LocationSample> get locationStream => _locations.stream;
  bool get hasUnsyncedWrites => _store.hasUnsyncedWrites;

  Duration get remaining {
    final session = _active;
    if (session == null) return Duration.zero;
    final left = session.plannedDuration - DateTime.now().difference(session.startedAt);
    return left.isNegative ? Duration.zero : left;
  }

  Future<WalkSession> start({
    required Duration plannedDuration,
    LocationSample? destination,
    List<String> contactIds = const [],
  }) async {
    if (_active != null) throw StateError('A walk is already active.');
    final problem = permissionProblem(await _location.ensurePermission());
    if (problem != null) throw StateError(problem);
    final session = WalkSession(
      id: _newId(),
      ownerUid: _uid?.call() ?? '',
      startedAt: DateTime.now(),
      plannedDuration: plannedDuration,
      destinationLat: destination?.lat,
      destinationLng: destination?.lng,
      sharedWithContactIds:
          contactIds.take(WalkSession.maxSharedContacts).toList(),
      shareToken: newShareToken(),
    );

    _active = session;
    _sub = _location.positionStream.listen(_onSample);
    _timer = Timer.periodic(_tick, (_) => _onTick());
    _emit(session);
    await _persist(session);
    return session;
  }

  Future<void> end() => _finish(WalkSessionStatus.completed);

  Future<void> cancel() => _finish(WalkSessionStatus.cancelled);

  Future<void> flagDeviation({required double metresOffRoute}) async {
    final session = _active;
    if (session == null) return;
    _active = session.copyWith(lastDeviationMetres: metresOffRoute);
    _emit(_active!);
    await _persist(_active!);
  }

  Future<void> flagMissedCheckIn({required DateTime dueAt}) async {
    final session = _active;
    if (session == null) return;
    _active = session.copyWith(missedCheckInAt: dueAt);
    _emit(_active!);
    await _persist(_active!);
  }

  Future<void> dispose() async {
    _timer?.cancel();
    _timer = null;
    await _sub?.cancel();
    _sub = null;
    _active = null;
    _store.dispose();
    await _sessions.close();
    await _locations.close();
  }

  Future<void> _finish(WalkSessionStatus status) async {
    final session = _active;
    if (session == null) return;

    _active = null;
    _timer?.cancel();
    _timer = null;
    await _sub?.cancel();
    _sub = null;
    await _location.stop();
    final done = session.copyWith(
        status: status, endedAt: DateTime.now(), clearShareToken: true);
    _emit(done);
    await _store.save(done);
  }

  Future<void> _persist(WalkSession session) async {
    try {
      await _store.save(session);
    } catch (_) {
      return;
    }
  }

  void _onSample(LocationSample sample) {
    final session = _active;
    if (session == null) return;
    if (!_locations.isClosed) _locations.add(sample);
    _active = session.copyWith(
      lastLat: sample.lat,
      lastLng: sample.lng,
      lastUpdatedAt: DateTime.now(),
    );
    _emit(_active!);
    _persist(_active!);
  }

  void _onTick() {
    final session = _active;
    if (session == null) return;
    if (session.status != WalkSessionStatus.active) return;
    if (remaining > Duration.zero) return;
    _active = session.copyWith(status: WalkSessionStatus.overdue);
    _emit(_active!);
    _persist(_active!);
  }

  void _emit(WalkSession session) {
    if (!_sessions.isClosed) _sessions.add(session);
  }

  static const tokenAlphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';

  static String newShareToken() {
    final random = Random.secure();
    return List.generate(
        32, (_) => tokenAlphabet[random.nextInt(tokenAlphabet.length)]).join();
  }

  static String _newId() {
    final random = Random.secure();
    return List.generate(16, (_) => random.nextInt(16).toRadixString(16)).join();
  }
}

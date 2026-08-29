import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/walk_session.dart';
import 'walk_session_store.dart';

class FirestoreWalkSessionStore implements WalkSessionStore {
  FirestoreWalkSessionStore({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    this.throttle = const Duration(seconds: 10),
  })  : _injectedDb = firestore,
        _injectedAuth = auth;

  static const collection = 'walk_sessions';
  static const pointsCollection = 'points';
  static const keyPointLat = 'lat';
  static const keyPointLng = 'lng';
  static const keyPointAt = 'at';
  static const maxQueuedPoints = 200;
  static const maxRetries = 5;
  static const maxHistory = 50;

  final FirebaseFirestore? _injectedDb;
  final FirebaseAuth? _injectedAuth;
  final Duration throttle;
  final _queue = <Map<String, dynamic>>[];

  FirebaseFirestore get _db => _injectedDb ?? FirebaseFirestore.instance;

  FirebaseAuth get _auth => _injectedAuth ?? FirebaseAuth.instance;

  DateTime? _lastAttempt;
  String? _attemptedId;
  String? _lastPointKey;
  String? _createdId;
  WalkSession? _latest;
  Timer? _pending;
  int _attempts = 0;
  bool _failed = false;

  int get queuedPoints => _queue.length;

  @override
  bool get hasUnsyncedWrites => _failed || _queue.isNotEmpty;

  String get _uid =>
      _auth.currentUser?.uid ??
      (throw StateError('Cannot save a walk: no signed-in user.'));

  static Map<String, dynamic> normalize(Map<String, dynamic> data) =>
      data.map((k, v) => MapEntry(
          k, v is Timestamp ? v.toDate().toUtc().toIso8601String() : v));

  Map<String, dynamic> parentPayload(String uid, WalkSession session,
      {required bool created}) {
    final data = Map<String, dynamic>.of(session.toMap())
      ..[WalkSession.keyOwnerUid] = uid
      ..[WalkSession.keyLastUpdatedAt] = FieldValue.serverTimestamp()
      ..remove(WalkSession.keyStartedAt)
      ..remove(WalkSession.keyEndedAt);
    if (!created) {
      data[WalkSession.keyStartedAt] = FieldValue.serverTimestamp();
    }
    if (session.isFinished) {
      data[WalkSession.keyEndedAt] = FieldValue.serverTimestamp();
    }
    return data;
  }

  void enqueuePoint(WalkSession session) {
    final lat = session.lastLat;
    final lng = session.lastLng;
    if (lat == null || lng == null) return;
    final at = session.lastUpdatedAt;
    final key = '$lat,$lng,${at?.toIso8601String() ?? ''}';
    if (key == _lastPointKey) return;
    _lastPointKey = key;
    if (_queue.length >= maxQueuedPoints) _queue.removeAt(0);
    _queue.add({
      keyPointLat: lat,
      keyPointLng: lng,
      keyPointAt: at?.toIso8601String(),
    });
  }

  @override
  Future<void> save(WalkSession session) async {
    final uid = _uid;
    _latest = session;
    enqueuePoint(session);
    if (session.isFinished) {
      _pending?.cancel();
      _pending = null;
      await _flush(uid);
      return;
    }
    if (_pending != null) return;
    if (shouldFlush(
        throttle: throttle,
        now: DateTime.now(),
        finished: false,
        lastFlush: _attemptedId == session.id ? _lastAttempt : null)) {
      await _flush(uid);
      return;
    }
    _pending = Timer(throttle, () {
      _pending = null;
      _flush(uid);
    });
  }

  List<Map<String, dynamic>> snapshotQueue() => List.of(_queue);

  void removeSentPoints(List<Map<String, dynamic>> sent) {
    for (final point in sent) {
      _queue.remove(point);
    }
  }

  Future<void> _flush(String uid) async {
    final session = _latest;
    if (session == null) return;
    _attemptedId = session.id;
    _lastAttempt = DateTime.now();
    final ref = _db.collection(collection).doc(session.id);
    final batch = _db.batch();
    batch.set(
        ref,
        parentPayload(uid, session, created: _createdId == session.id),
        SetOptions(merge: true));
    final sending = snapshotQueue();
    for (final point in sending) {
      batch.set(ref.collection(pointsCollection).doc(), point);
    }
    try {
      await batch.commit();
      removeSentPoints(sending);
      _createdId = session.id;
      _attempts = 0;
      _failed = false;
      _pending?.cancel();
      _pending = null;
    } catch (_) {
      _failed = true;
      if (_attempts >= maxRetries) {
        _attempts = 0;
        return;
      }
      _attempts++;
      _pending?.cancel();
      _pending = Timer(Duration(seconds: 1 << _attempts), () {
        _pending = null;
        _flush(uid);
      });
    }
  }

  @override
  Future<List<WalkSession>> loadAll() async {
    final snapshot = await _db
        .collection(collection)
        .where(WalkSession.keyOwnerUid, isEqualTo: _uid)
        .orderBy(WalkSession.keyStartedAt, descending: true)
        .limit(maxHistory)
        .get();
    return snapshot.docs
        .map((d) => WalkSession.fromMap(d.id, normalize(d.data())))
        .toList();
  }

  @override
  Future<void> delete(String id) async {
    final uid = _uid;
    final ref = _db.collection(collection).doc(id);
    final parent = await ref.get();
    if (!parent.exists) {
      throw StateError('Cannot delete a walk that does not exist.');
    }
    if (parent.data()?[WalkSession.keyOwnerUid] != uid) {
      throw StateError('Cannot delete a walk owned by someone else.');
    }
    final points =
        await ref.collection(pointsCollection).limit(maxQueuedPoints).get();
    final batch = _db.batch();
    for (final point in points.docs) {
      batch.delete(point.reference);
    }
    batch.delete(ref);
    await batch.commit();
  }

  @override
  Future<void> clear() async {
    final snapshot = await _db
        .collection(collection)
        .where(WalkSession.keyOwnerUid, isEqualTo: _uid)
        .get();
    for (final doc in snapshot.docs) {
      await delete(doc.id);
    }
  }

  @override
  void dispose() {
    _pending?.cancel();
    _pending = null;
  }
}

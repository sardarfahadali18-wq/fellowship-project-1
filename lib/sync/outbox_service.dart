import 'dart:convert';

import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../data/models/sync_event.dart';

/// Write-side of the outbox. Other modules call these helpers whenever the user
/// does something that must eventually reach the server. The event is persisted
/// immediately (survives app kill / offline) and drained later by [SyncEngine].
class OutboxService {
  OutboxService(this._isar, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Isar _isar;
  final Uuid _uuid;

  /// Called by the lesson viewer (Sardar) when a lesson is opened.
  Future<void> logLessonOpened({
    required int studentId,
    required int lessonId,
  }) {
    return _enqueue(
      studentId: studentId,
      type: SyncEventType.lessonOpened,
      payload: {'lessonId': lessonId},
    );
  }

  /// Called when a lesson is marked complete.
  Future<void> logLessonCompleted({
    required int studentId,
    required int lessonId,
  }) {
    return _enqueue(
      studentId: studentId,
      type: SyncEventType.lessonCompleted,
      payload: {'lessonId': lessonId},
    );
  }

  /// Called by the quiz engine (Faizan) after local grading.
  Future<void> logQuizSubmitted({
    required int studentId,
    required int lessonId,
    required int score,
    required int total,
  }) {
    return _enqueue(
      studentId: studentId,
      type: SyncEventType.quizSubmitted,
      payload: {
        'lessonId': lessonId,
        'score': score,
        'total': total,
      },
    );
  }

  Future<void> _enqueue({
    required int studentId,
    required SyncEventType type,
    required Map<String, dynamic> payload,
  }) async {
    final event = SyncEvent()
      ..uuid = _uuid.v4()
      ..type = type
      ..status = SyncStatus.pending
      ..studentId = studentId
      ..payloadJson = jsonEncode(payload)
      ..createdAt = DateTime.now().toUtc();

    await _isar.writeTxn(() async {
      await _isar.syncEvents.put(event);
    });
  }

  /// Number of events still waiting to reach the server — powers the UI badge.
  Future<int> pendingCount() {
    return _isar.syncEvents
        .filter()
        .statusEqualTo(SyncStatus.pending)
        .or()
        .statusEqualTo(SyncStatus.failed)
        .count();
  }
}

import 'package:isar_community/isar.dart';

part 'sync_event.g.dart';

/// The kind of local event that needs to be pushed to the backend.
enum SyncEventType {
  lessonOpened,
  lessonCompleted,
  quizSubmitted,
}

/// Where an outbox event currently sits in its lifecycle.
enum SyncStatus {
  /// Created locally, not yet acknowledged by the backend.
  pending,

  /// Currently being pushed (guards against double-send).
  inFlight,

  /// Successfully acknowledged by the backend.
  synced,

  /// Permanently failed after exhausting retries.
  failed,
}

/// Local outbox record. Every user action that must reach the server is written
/// here first (offline-first), then drained by [SyncEngine] when connectivity
/// allows. The [uuid] makes each event idempotent so the backend can safely
/// de-duplicate retries.
@collection
class SyncEvent {
  Id id = Isar.autoIncrement;

  /// Client-generated idempotency key. Unique per logical event.
  @Index(unique: true, replace: false)
  late String uuid;

  @enumerated
  @Index()
  late SyncEventType type;

  @enumerated
  @Index()
  SyncStatus status = SyncStatus.pending;

  /// Profile / student this event belongs to (local Isar id).
  late int studentId;

  /// JSON-encoded event body (lessonId, score, timestamps, etc.).
  late String payloadJson;

  late DateTime createdAt;

  /// How many push attempts have been made so far.
  int attemptCount = 0;

  DateTime? lastAttemptAt;

  /// Last error message, for debugging failed sends.
  String? lastError;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reminder.dart';

/// Firestore-backed replacement for the old local-only reminder + streak
/// storage. All data lives under users/{uid}/reminders and
/// users/{uid}/completions, so it persists across devices and is
/// visible to a linked caregiver (read-only).
class ReminderService {
  final _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> _remindersRef(String uid) =>
      _db.collection('users').doc(uid).collection('reminders');

  CollectionReference<Map<String, dynamic>> _completionsRef(String uid) =>
      _db.collection('users').doc(uid).collection('completions');

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Live stream of reminders for a given user (defaults to current user).
  Stream<List<Reminder>> watchReminders({String? uid}) {
    return _remindersRef(uid ?? _uid)
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map(Reminder.fromDoc).toList());
  }

  Future<void> addReminder(Reminder reminder) async {
    await _remindersRef(_uid).add(reminder.toMap());
  }

  Future<void> updateReminder(Reminder reminder) async {
    await _remindersRef(_uid).doc(reminder.id).update(reminder.toMap());
  }

  Future<void> deleteReminder(String reminderId) async {
    await _remindersRef(_uid).doc(reminderId).delete();
  }

  /// Live stream of completed reminder IDs for a given date (defaults to
  /// today, current user).
  Stream<Set<String>> watchCompletions({String? uid, DateTime? date}) {
    final dateKey = _formatDate(date ?? DateTime.now());
    return _completionsRef(uid ?? _uid).doc(dateKey).snapshots().map((doc) {
      final ids = doc.data()?['reminderIds'] as List<dynamic>?;
      return ids?.map((e) => e.toString()).toSet() ?? <String>{};
    });
  }

  Future<void> completeReminder(String reminderId, {DateTime? date}) async {
    final dateKey = _formatDate(date ?? DateTime.now());
    await _completionsRef(_uid).doc(dateKey).set({
      'reminderIds': FieldValue.arrayUnion([reminderId]),
    }, SetOptions(merge: true));
    await _recalculateBestStreak();
  }

  Future<void> uncompleteReminder(String reminderId, {DateTime? date}) async {
    final dateKey = _formatDate(date ?? DateTime.now());
    await _completionsRef(_uid).doc(dateKey).set({
      'reminderIds': FieldValue.arrayRemove([reminderId]),
    }, SetOptions(merge: true));
    await _recalculateBestStreak();
  }

  /// Computes the current consecutive-day streak (any completion counts)
  /// for a given user by reading their completions collection.
  Future<int> getStreakCount({String? uid}) async {
    final targetUid = uid ?? _uid;
    final today = DateTime.now();
    final todayKey = _formatDate(today);
    final yesterdayKey = _formatDate(today.subtract(const Duration(days: 1)));

    final todayDoc = await _completionsRef(targetUid).doc(todayKey).get();
    final yesterdayDoc =
        await _completionsRef(targetUid).doc(yesterdayKey).get();

    bool hasCompletions(DocumentSnapshot<Map<String, dynamic>> d) {
      final ids = d.data()?['reminderIds'] as List<dynamic>?;
      return ids != null && ids.isNotEmpty;
    }

    DateTime startDay;
    if (todayDoc.exists && hasCompletions(todayDoc)) {
      startDay = today;
    } else if (yesterdayDoc.exists && hasCompletions(yesterdayDoc)) {
      startDay = today.subtract(const Duration(days: 1));
    } else {
      return 0;
    }

    int streak = 0;
    DateTime checkDay = startDay;
    while (true) {
      final doc =
          await _completionsRef(targetUid).doc(_formatDate(checkDay)).get();
      if (doc.exists && hasCompletions(doc)) {
        streak++;
        checkDay = checkDay.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  Future<void> _recalculateBestStreak() async {
    final current = await getStreakCount();
    final userDoc = _db.collection('users').doc(_uid);
    final snap = await userDoc.get();
    final best = snap.data()?['bestStreak'] as int? ?? 0;
    if (current > best) {
      await userDoc.set({'bestStreak': current}, SetOptions(merge: true));
    }
  }
}

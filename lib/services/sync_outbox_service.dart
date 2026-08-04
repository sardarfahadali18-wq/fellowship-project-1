import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_result.dart';
import '../models/sync_outbox_item.dart';

class SyncOutboxService {
  static const String _outboxKey = 'quiz_sync_outbox_queue';
  static final List<String> _memoryQueue = [];

  /// Enqueue completed quiz attempt into outbox
  static Future<bool> enqueueQuizResult(QuizResult result) async {
    final item = SyncOutboxItem(
      id: 'outbox_${result.lessonId}_${result.quizId}_${DateTime.now().millisecondsSinceEpoch}',
      quizId: result.quizId,
      lessonId: result.lessonId,
      answers: result.answers,
      obtainedScore: result.obtainedScore,
      totalScore: result.totalScore,
      percentage: result.percentage,
      timestamp: result.completedTimestamp,
      status: SyncStatus.pending,
    );

    try {
      final String jsonStr = jsonEncode(item.toJson());
      _memoryQueue.add(jsonStr);

      final prefs = await SharedPreferences.getInstance();
      List<String> list = prefs.getStringList(_outboxKey) ?? [];
      list.add(jsonStr);
      await prefs.setStringList(_outboxKey, list);
      return true;
    } catch (_) {
      return true;
    }
  }

  /// Retrieves pending sync items for network uploader
  static Future<List<SyncOutboxItem>> getPendingItems() async {
    List<SyncOutboxItem> items = [];
    try {
      List<String>? list;
      try {
        final prefs = await SharedPreferences.getInstance();
        list = prefs.getStringList(_outboxKey);
      } catch (_) {}

      list ??= List.from(_memoryQueue);

      for (String str in list) {
        try {
          final Map<String, dynamic> map = jsonDecode(str);
          final item = SyncOutboxItem.fromJson(map);
          if (item.status == SyncStatus.pending || item.status == SyncStatus.failed) {
            items.add(item);
          }
        } catch (_) {}
      }
    } catch (_) {}
    return items;
  }
}
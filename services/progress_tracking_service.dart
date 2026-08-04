import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lesson_progress.dart';

class ProgressTrackingService {
  static const String _progressPrefix = 'lesson_progress_';
  static final Map<String, String> _memoryCache = {};

  static String _getKey(String lessonId) => '$_progressPrefix$lessonId';

  /// Fetch progress for a lesson
  static Future<LessonProgress> getLessonProgress(String lessonId) async {
    final key = _getKey(lessonId);
    try {
      String? jsonStr;
      try {
        final prefs = await SharedPreferences.getInstance();
        jsonStr = prefs.getString(key);
      } catch (_) {}

      jsonStr ??= _memoryCache[key];

      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        return LessonProgress.fromJson(map);
      }
    } catch (_) {
      _memoryCache.remove(key);
    }

    return LessonProgress(
      lessonId: lessonId,
      isCompleted: false,
      progressPercentage: 0.0,
      completedQuizzes: const [],
      lastUpdated: DateTime.now(),
    );
  }

  /// Automatically update lesson progress when quiz is completed
  static Future<LessonProgress> updateProgressForQuizCompleted({
    required String lessonId,
    required String quizId,
    required int totalQuizzesInLesson,
  }) async {
    final currentProgress = await getLessonProgress(lessonId);
    final Set<String> completedSet = Set.from(currentProgress.completedQuizzes);
    completedSet.add(quizId);

    final int total = totalQuizzesInLesson > 0 ? totalQuizzesInLesson : 1;
    final double percentage = (completedSet.length / total) * 100.0;
    final double boundedPercentage = percentage > 100.0 ? 100.0 : percentage;

    final updatedProgress = LessonProgress(
      lessonId: lessonId,
      isCompleted: boundedPercentage >= 100.0,
      progressPercentage: double.parse(boundedPercentage.toStringAsFixed(2)),
      completedQuizzes: completedSet.toList(),
      lastUpdated: DateTime.now(),
    );

    try {
      final key = _getKey(lessonId);
      final jsonStr = jsonEncode(updatedProgress.toJson());
      _memoryCache[key] = jsonStr;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonStr);
    } catch (_) {}

    return updatedProgress;
  }
}
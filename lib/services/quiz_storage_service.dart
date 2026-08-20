import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_result.dart';

class QuizStorageService {
  static const String _quizResultsPrefix = 'quiz_result_store_';
  static const String _attemptsPrefix = 'quiz_attempts_count_';

  // Fallback in-memory cache if local device storage is uninitialized or fails
  static final Map<String, String> _memoryCache = {};

  static String _getResultKey(String lessonId, String quizId, int attempt) {
    return '${_quizResultsPrefix}${lessonId}_${quizId}_att_$attempt';
  }

  static String _getAttemptKey(String lessonId, String quizId) {
    return '${_attemptsPrefix}${lessonId}_$quizId';
  }

  /// Get current attempt count for quiz
  static Future<int> getAttemptCount(String lessonId, String quizId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_getAttemptKey(lessonId, quizId)) ?? 0;
    } catch (_) {
      final val = _memoryCache[_getAttemptKey(lessonId, quizId)];
      return val != null ? int.tryParse(val) ?? 0 : 0;
    }
  }

  /// Save completed quiz result
  static Future<bool> saveResult(QuizResult result) async {
    try {
      final jsonStr = jsonEncode(result.toJson());
      final key = _getResultKey(result.lessonId, result.quizId, result.attemptNumber);
      final attemptKey = _getAttemptKey(result.lessonId, result.quizId);

      _memoryCache[key] = jsonStr;
      _memoryCache[attemptKey] = result.attemptNumber.toString();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonStr);
      await prefs.setInt(attemptKey, result.attemptNumber);
      return true;
    } catch (e) {
      return true; // Graceful fallback
    }
  }

  /// Fetch specific attempt result
  static Future<QuizResult?> getResult(
    String lessonId,
    String quizId,
    int attemptNumber,
  ) async {
    final key = _getResultKey(lessonId, quizId, attemptNumber);
    try {
      String? jsonStr;
      try {
        final prefs = await SharedPreferences.getInstance();
        jsonStr = prefs.getString(key);
      } catch (_) {}

      jsonStr ??= _memoryCache[key];

      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        return QuizResult.fromJson(map);
      }
    } catch (e) {
      // Clear corrupt storage key
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(key);
      } catch (_) {}
      _memoryCache.remove(key);
    }
    return null;
  }
}
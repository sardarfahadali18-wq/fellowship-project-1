import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for managing medication and habit completion streaks.
///
/// Data is persisted locally using [SharedPreferences] in JSON format.
class StreakService {
  static const String _storageKey = 'streak_service_data';
  static StreakService? _instance;

  // Local cache of completions.
  // Key: Date string (format: YYYY-MM-DD), Value: Set of completed reminder IDs.
  Map<String, Set<String>> _completions = {};
  int _bestStreak = 0;

  final SharedPreferences _prefs;

  // Private constructor for Singleton pattern.
  StreakService._(this._prefs) {
    _loadData();
  }

  /// The singleton instance of [StreakService].
  ///
  /// Call [StreakService.init] before accessing this getter.
  static StreakService get instance {
    if (_instance == null) {
      throw StateError(
        'StreakService must be initialized by calling StreakService.init() first.',
      );
    }
    return _instance!;
  }

  /// Initializes the [StreakService] singleton.
  static Future<StreakService> init() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = StreakService._(prefs);
    }
    return _instance!;
  }

  /// Allows setting a mock/custom instance for testing.
  @visibleForTesting
  static void setMockInstance(StreakService mockInstance) {
    _instance = mockInstance;
  }

  /// Loads streak data from local storage.
  void _loadData() {
    final rawData = _prefs.getString(_storageKey);
    if (rawData != null) {
      try {
        final decoded = jsonDecode(rawData) as Map<String, dynamic>;

        // Parse completions map
        if (decoded['completions'] != null) {
          final rawCompletions = decoded['completions'] as Map<String, dynamic>;
          _completions = rawCompletions.map(
            (key, value) => MapEntry(key, List<String>.from(value).toSet()),
          );
        }

        // Parse best streak
        _bestStreak = decoded['bestStreak'] as int? ?? 0;
      } catch (e) {
        // Fail-safe defaults if data is corrupted
        _completions = {};
        _bestStreak = 0;
      }
    }
  }

  /// Saves current streak data to local storage.
  Future<bool> _saveData() async {
    final dataToSave = {
      'completions': _completions.map(
        (key, value) => MapEntry(key, value.toList()),
      ),
      'bestStreak': _bestStreak,
    };
    return _prefs.setString(_storageKey, jsonEncode(dataToSave));
  }

  /// Formats a [DateTime] into a YYYY-MM-DD string.
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Marks a specific reminder as completed for a given date.
  ///
  /// If no date is specified, it defaults to today.
  Future<void> completeReminder(String reminderId, {DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final dateKey = _formatDate(targetDate);

    _completions.putIfAbsent(dateKey, () => <String>{}).add(reminderId);

    // Update best streak if the current streak exceeds the historical best
    final currentStreak = getStreakCount(todayDate: targetDate);
    if (currentStreak > _bestStreak) {
      _bestStreak = currentStreak;
    }

    await _saveData();
  }

  /// Marks a specific reminder as incomplete for a given date.
  ///
  /// If no date is specified, it defaults to today.
  Future<void> uncompleteReminder(String reminderId, {DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final dateKey = _formatDate(targetDate);

    if (_completions.containsKey(dateKey)) {
      _completions[dateKey]!.remove(reminderId);
      if (_completions[dateKey]!.isEmpty) {
        _completions.remove(dateKey);
      }
    }

    // Recalculate best streak from history in case the current streak was broken
    _bestStreak = calculateBestStreakFromHistory();

    await _saveData();
  }

  /// Checks if a specific reminder was completed on a given date.
  ///
  /// If no date is specified, it defaults to today.
  bool isReminderCompleted(String reminderId, {DateTime? date}) {
    final targetDate = date ?? DateTime.now();
    final dateKey = _formatDate(targetDate);
    return _completions[dateKey]?.contains(reminderId) ?? false;
  }

  /// Returns all completed reminder IDs for a given date.
  ///
  /// If no date is specified, it defaults to today.
  Set<String> getCompletedReminders({DateTime? date}) {
    final targetDate = date ?? DateTime.now();
    final dateKey = _formatDate(targetDate);
    return Set<String>.from(_completions[dateKey] ?? <String>{});
  }

  /// Checks if a day has at least one completed reminder.
  bool isDayCompletedAny({DateTime? date}) {
    final targetDate = date ?? DateTime.now();
    final dateKey = _formatDate(targetDate);
    return _completions[dateKey]?.isNotEmpty ?? false;
  }

  /// Checks if a day has all specified active reminders completed.
  bool isDayCompletedAll(List<String> activeReminderIds, {DateTime? date}) {
    if (activeReminderIds.isEmpty) return false;
    final completed = getCompletedReminders(date: date);
    return activeReminderIds.every((id) => completed.contains(id));
  }

  /// Returns the current streak count.
  ///
  /// A streak represents consecutive days with at least one completion.
  /// If today has no completions, but yesterday did, the streak is still active.
  /// If yesterday also had no completions, the streak is broken (0).
  int getStreakCount({DateTime? todayDate}) {
    final today = todayDate ?? DateTime.now();
    final todayKey = _formatDate(today);
    final yesterdayKey = _formatDate(today.subtract(const Duration(days: 1)));

    // If there are no completions at all, streak is 0
    if (_completions.isEmpty) {
      return 0;
    }

    // Determine the start day of the streak calculation.
    // If today has completions, start counting back from today.
    // If today has no completions but yesterday does, start counting back from yesterday.
    // Otherwise, the streak is broken (0).
    DateTime startDay;
    if (_completions.containsKey(todayKey) && _completions[todayKey]!.isNotEmpty) {
      startDay = today;
    } else if (_completions.containsKey(yesterdayKey) && _completions[yesterdayKey]!.isNotEmpty) {
      startDay = today.subtract(const Duration(days: 1));
    } else {
      return 0;
    }

    int streak = 0;
    DateTime checkDay = startDay;

    while (true) {
      final checkKey = _formatDate(checkDay);
      if (_completions.containsKey(checkKey) && _completions[checkKey]!.isNotEmpty) {
        streak++;
        // Move back to the previous day (DST safe: subtract 24 hours, but we only format YYYY-MM-DD)
        checkDay = checkDay.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Calculates the best (longest) streak count based on completion history.
  ///
  /// This iterates over all completed dates in chronological order to find
  /// the longest consecutive run of days. It is DST-safe.
  int calculateBestStreakFromHistory() {
    final completedDates = _completions.keys
        .where((key) => _completions[key]!.isNotEmpty)
        .map((key) => DateTime.parse(key))
        .toList();

    if (completedDates.isEmpty) return 0;

    // Sort in ascending order
    completedDates.sort();

    int maxStreak = 0;
    int currentStreak = 0;
    DateTime? prevDate;

    for (final date in completedDates) {
      if (prevDate == null) {
        currentStreak = 1;
      } else {
        // Normalize to UTC noon to avoid timezone and DST shifts
        final prevDateNoon = DateTime.utc(
          prevDate.year,
          prevDate.month,
          prevDate.day,
          12,
        );
        final dateNoon = DateTime.utc(date.year, date.month, date.day, 12);
        final diffDays = dateNoon.difference(prevDateNoon).inDays;

        if (diffDays == 1) {
          currentStreak++;
        } else if (diffDays > 1) {
          if (currentStreak > maxStreak) {
            maxStreak = currentStreak;
          }
          currentStreak = 1;
        }
      }
      prevDate = date;
    }

    if (currentStreak > maxStreak) {
      maxStreak = currentStreak;
    }

    return maxStreak;
  }

  /// Returns the historical best streak count.
  int getBestStreakCount() {
    final currentStreak = getStreakCount();
    if (currentStreak > _bestStreak) {
      _bestStreak = currentStreak;
      _saveData();
    }
    return _bestStreak;
  }

  /// Returns the total number of unique days the user has completed at least one reminder.
  int getTotalCompletedDays() {
    return _completions.keys.where((key) => _completions[key]!.isNotEmpty).length;
  }

  /// Clears all completion records and resets streaks to zero.
  Future<void> clearAllData() async {
    _completions.clear();
    _bestStreak = 0;
    await _saveData();
  }
}

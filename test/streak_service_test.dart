import 'package:fellowship_project_1/services/streak_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StreakService Tests', () {
    late StreakService streakService;

    setUp(() async {
      // Setup mock values for SharedPreferences before initialization.
      SharedPreferences.setMockInitialValues({});
      streakService = await StreakService.init();
      await streakService.clearAllData();
    });

    test('Initial streak count and best streak should be 0', () {
      expect(streakService.getStreakCount(), equals(0));
      expect(streakService.getBestStreakCount(), equals(0));
      expect(streakService.getTotalCompletedDays(), equals(0));
    });

    test('Completing a reminder today should increase streak to 1', () async {
      final today = DateTime.now();
      await streakService.completeReminder('rem_1', date: today);

      expect(streakService.isReminderCompleted('rem_1', date: today), isTrue);
      expect(streakService.getStreakCount(todayDate: today), equals(1));
      expect(streakService.getBestStreakCount(), equals(1));
      expect(streakService.getTotalCompletedDays(), equals(1));
    });

    test('Completing reminders on consecutive days should increase streak', () async {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      await streakService.completeReminder('rem_1', date: twoDaysAgo);
      await streakService.completeReminder('rem_2', date: yesterday);
      await streakService.completeReminder('rem_3', date: today);

      expect(streakService.getStreakCount(todayDate: today), equals(3));
      expect(streakService.getBestStreakCount(), equals(3));
      expect(streakService.getTotalCompletedDays(), equals(3));
    });

    test('Streak should be active today even if not completed yet (yesterday completed)', () async {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      await streakService.completeReminder('rem_1', date: yesterday);

      // Today is not completed yet, but yesterday was, so streak should be 1
      expect(streakService.getStreakCount(todayDate: today), equals(1));
    });

    test('Streak should break (0) if there is a gap of 2 or more days', () async {
      final today = DateTime.now();
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      await streakService.completeReminder('rem_1', date: twoDaysAgo);

      // Yesterday and today have no completions
      expect(streakService.getStreakCount(todayDate: today), equals(0));
      // Best streak should still remember the max (which was 1)
      expect(streakService.getBestStreakCount(), equals(1));
    });

    test('Best streak should capture the maximum streak from history', () async {
      final today = DateTime.now();
      final day1 = today.subtract(const Duration(days: 10));
      final day2 = today.subtract(const Duration(days: 9));
      final day3 = today.subtract(const Duration(days: 8)); // 3 day streak

      final day5 = today.subtract(const Duration(days: 5));
      final day6 = today.subtract(const Duration(days: 4)); // 2 day streak

      await streakService.completeReminder('rem_1', date: day1);
      await streakService.completeReminder('rem_1', date: day2);
      await streakService.completeReminder('rem_1', date: day3);

      await streakService.completeReminder('rem_1', date: day5);
      await streakService.completeReminder('rem_1', date: day6);

      expect(streakService.getStreakCount(todayDate: today), equals(0)); // Current is 0 (broken)
      expect(streakService.calculateBestStreakFromHistory(), equals(3));
      expect(streakService.getBestStreakCount(), equals(3));
    });

    test('Uncompleting a reminder should recalculate streak and best streak correctly', () async {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      await streakService.completeReminder('rem_1', date: yesterday);
      await streakService.completeReminder('rem_1', date: today);

      expect(streakService.getStreakCount(todayDate: today), equals(2));

      // Uncomplete today's reminder
      await streakService.uncompleteReminder('rem_1', date: today);

      expect(streakService.isReminderCompleted('rem_1', date: today), isFalse);
      expect(streakService.getStreakCount(todayDate: today), equals(1)); // Falls back to yesterday's streak
      expect(streakService.getBestStreakCount(), equals(1));
    });
  });
}

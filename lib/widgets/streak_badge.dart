import 'package:flutter/material.dart';
import '../services/streak_service.dart';

/// Compact pill showing the user's current streak, e.g. "🔥 5-day streak".
///
/// Falls back to an encouraging empty state when the streak is 0.
///
/// This reads [StreakService] synchronously at build time, so the parent must
/// rebuild (e.g. `setState`) after `completeReminder`/`uncompleteReminder` for
/// the badge to refresh.
class StreakBadge extends StatelessWidget {
  /// Optional tap handler, used on the home screen to reveal [StreakStatsCard].
  final VoidCallback? onTap;

  const StreakBadge({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final streak = StreakService.instance.getStreakCount();
    final hasStreak = streak > 0;

    final background = hasStreak
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    final foreground = hasStreak
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasStreak ? '🔥' : '✨',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(
              hasStreak
                  ? '$streak-day streak'
                  : 'Start your streak today!',
              style: theme.textTheme.labelLarge?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

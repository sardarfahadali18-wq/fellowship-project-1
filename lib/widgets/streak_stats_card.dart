import 'package:flutter/material.dart';
import '../services/streak_service.dart';

/// Card summarising streak history: current streak, best streak and the total
/// number of days with at least one completed reminder.
///
/// Like [StreakBadge], this reads [StreakService] at build time and relies on
/// the parent rebuilding to stay current.
class StreakStatsCard extends StatelessWidget {
  const StreakStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final streaks = StreakService.instance;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your progress',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StreakStat(
                    icon: Icons.local_fire_department,
                    label: 'Current',
                    value: streaks.getStreakCount(),
                    highlighted: true,
                  ),
                  const VerticalDivider(width: 1),
                  _StreakStat(
                    icon: Icons.emoji_events_outlined,
                    label: 'Best',
                    value: streaks.getBestStreakCount(),
                  ),
                  const VerticalDivider(width: 1),
                  _StreakStat(
                    icon: Icons.event_available_outlined,
                    label: 'Total days',
                    value: streaks.getTotalCompletedDays(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single labelled figure inside [StreakStatsCard].
class _StreakStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final bool highlighted;

  const _StreakStat({
    required this.icon,
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueColor = highlighted
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: valueColor),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

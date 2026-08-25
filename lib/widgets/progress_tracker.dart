import 'package:flutter/material.dart';

enum LessonStatus { done, inProgress, locked }

class ProgressTracker extends StatelessWidget {
  final String title;
  final String subtitle;
  final LessonStatus status;
  final VoidCallback? onTap;

  const ProgressTracker({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    IconData badgeIcon;
    String statusLabel;

    switch (status) {
      case LessonStatus.done:
        badgeColor = const Color(0xFF4CAF50);
        badgeIcon = Icons.check_circle;
        statusLabel = 'Completed';
        break;
      case LessonStatus.inProgress:
        badgeColor = const Color(0xFFFF9800);
        badgeIcon = Icons.play_circle_fill;
        statusLabel = 'In Progress';
        break;
      case LessonStatus.locked:
        badgeColor = Colors.grey.shade400;
        badgeIcon = Icons.lock;
        statusLabel = 'Locked';
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: status == LessonStatus.locked ? null : onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(badgeIcon, color: badgeColor, size: 36),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: status == LessonStatus.locked ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitle),
            const SizedBox(height: 6),
            // Progress pill tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: status != LessonStatus.locked
            ? const Icon(Icons.arrow_forward_ios, size: 16)
            : null,
      ),
    );
  }
}
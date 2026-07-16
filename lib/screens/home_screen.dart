import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/streak_service.dart';
import '../widgets/streak_badge.dart';
import '../widgets/streak_stats_card.dart';
import 'add_edit_reminder_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Reminder> reminders = [
    Reminder(
      id: '1',
      title: 'Paracetamol - 9:00 AM',
      time: DateTime.now(),
      frequency: 'Daily',
    ),
    Reminder(
      id: '2',
      title: 'Morning Walk - 7:00 AM',
      time: DateTime.now(),
      frequency: 'Daily',
    ),
    Reminder(
      id: '3',
      title: 'Drink Water - Every 2 hours',
      time: DateTime.now(),
      frequency: 'Daily',
    ),
  ];

  void _openAddReminder([Reminder? r]) async {
    final result = await Navigator.of(context).push<Reminder>(
      MaterialPageRoute(builder: (_) => AddEditReminderScreen(reminder: r)),
    );

    if (result != null) {
      setState(() {
        final index = reminders.indexWhere((e) => e.id == result.id);
        if (index >= 0)
          reminders[index] = result;
        else
          reminders.add(result);
      });
    }
  }

  void _showStreakStats() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 12, 24),
        child: StreakStatsCard(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreakBadge(onTap: _showStreakStats),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: reminders.length,
                itemBuilder: (ctx, i) {
                  final r = reminders[i];
                  final isCompleted =
                      StreakService.instance.isReminderCompleted(r.id);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: isCompleted ? 1 : 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: IconButton(
                        icon: Icon(
                          isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isCompleted ? Colors.green : Colors.grey[400],
                          size: 28,
                        ),
                        onPressed: () async {
                          if (isCompleted) {
                            await StreakService.instance
                                .uncompleteReminder(r.id);
                          } else {
                            await StreakService.instance.completeReminder(r.id);
                          }
                          setState(() {});
                        },
                      ),
                      title: Text(
                        r.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? Colors.grey : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        r.frequency,
                        style: TextStyle(
                          color:
                              isCompleted ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _openAddReminder(r),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddReminder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

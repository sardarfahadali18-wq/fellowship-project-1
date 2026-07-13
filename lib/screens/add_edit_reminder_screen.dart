import 'package:flutter/material.dart';
import '../models/reminder.dart';

class AddEditReminderScreen extends StatefulWidget {
  final Reminder? reminder;
  const AddEditReminderScreen({Key? key, this.reminder}) : super(key: key);

  @override
  State<AddEditReminderScreen> createState() => _AddEditReminderScreenState();
}

class _AddEditReminderScreenState extends State<AddEditReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  TimeOfDay _time = TimeOfDay.now();
  String _frequency = 'Daily';

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.reminder?.title ?? '');
    if (widget.reminder != null) {
      final dt = widget.reminder!.time;
      _time = TimeOfDay(hour: dt.hour, minute: dt.minute);
      _frequency = widget.reminder!.frequency;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, _time.hour, _time.minute);
    final r = Reminder(
      id:
          widget.reminder?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text,
      time: dt,
      frequency: _frequency,
    );
    Navigator.of(context).pop(r);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reminder == null ? 'Add Reminder' : 'Edit Reminder'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Medicine/Habit name',
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text('Time: ${_time.format(context)}'),
                  trailing: TextButton(
                    onPressed: _pickTime,
                    child: const Text('Pick'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _frequency,
                items: const [
                  DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                ],
                onChanged: (v) => setState(() => _frequency = v ?? 'Daily'),
                decoration: const InputDecoration(labelText: 'Frequency'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _save, child: const Text('Save')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Reminder {
  final String id;
  final String title;
  final DateTime time;
  final String frequency; // 'Daily' or 'Weekly' or custom

  Reminder({required this.id, required this.title, required this.time, required this.frequency});
}

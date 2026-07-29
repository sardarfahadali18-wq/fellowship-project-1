import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  final String id;
  final String title;
  final DateTime time;
  final String frequency; // 'Daily' or 'Weekly' or custom

  Reminder({
    required this.id,
    required this.title,
    required this.time,
    required this.frequency,
  });

  factory Reminder.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Reminder(
      id: doc.id,
      title: data['title'] as String? ?? '',
      time: (data['time'] as Timestamp?)?.toDate() ?? DateTime.now(),
      frequency: data['frequency'] as String? ?? 'Daily',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'time': Timestamp.fromDate(time),
      'frequency': frequency,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

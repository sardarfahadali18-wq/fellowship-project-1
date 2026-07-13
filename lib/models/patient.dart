class Patient {
  final String id;
  final String name;
  final String medicineName;
  final bool medicineTaken;
  final String reminderTime;

  Patient({
    required this.id,
    required this.name,
    required this.medicineName,
    required this.medicineTaken,
    required this.reminderTime,
  });
}

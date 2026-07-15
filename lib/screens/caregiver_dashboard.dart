import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/notifications_service.dart';

class CaregiverDashboard extends StatelessWidget {
  const CaregiverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Patient> patients = [
      Patient(
        id: '1',
        name: 'Ali Raza',
        medicineName: 'Paracetamol',
        medicineTaken: true,
        reminderTime: '9:16 PM',
      ),
      Patient(
        id: '2',
        name: 'Ayesha Khan',
        medicineName: 'Insulin',
        medicineTaken: false,
        reminderTime: '9:58 PM',
      ),
      Patient(
        id: '3',
        name: 'Bilal Ahmed',
        medicineName: 'Vitamin D',
        medicineTaken: false,
        reminderTime: '8:00 PM',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Dashboard'),
      ),
      body: Column(
        children: [
          // Test Notification Button
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await NotificationService.showTestNotification();
                },
                icon: const Icon(Icons.notifications_active),
                label: const Text("Test Notification"),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];

                return Card(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(
                      patient.medicineTaken
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: patient.medicineTaken
                          ? Colors.green
                          : Colors.red,
                    ),
                    title: Text(patient.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${patient.medicineName} - ${patient.reminderTime}',
                        ),
                        const SizedBox(height: 8),

                        ElevatedButton.icon(
                          onPressed: () async {
                            int hour;
                            int minute;

                            // Convert "9:00 AM" into 24-hour format
                            final parts = patient.reminderTime.split(' ');
                            final time = parts[0].split(':');

                            hour = int.parse(time[0]);
                            minute = int.parse(time[1]);

                            if (parts[1].toUpperCase() == 'PM' &&
                                hour != 12) {
                              hour += 12;
                            }

                            if (parts[1].toUpperCase() == 'AM' &&
                                hour == 12) {
                              hour = 0;
                            }

                            await NotificationService.scheduleMedicationReminder(
                              id: int.parse(patient.id),
                              patientName: patient.name,
                              medicineName: patient.medicineName,
                              targetHour: hour,
                              targetMinute: minute,
                            );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Reminder set for ${patient.name} at ${patient.reminderTime}',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.notification_add, size: 18),
                          label: const Text("Set Daily Reminder"),
                        ),
                      ],
                    ),
                    trailing: Text(
                      patient.medicineTaken ? 'Taken' : 'Missed',
                      style: TextStyle(
                        color: patient.medicineTaken
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

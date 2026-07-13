import 'package:flutter/material.dart';
import '../models/patient.dart';

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
        reminderTime: '9:00 AM',
      ),
      Patient(
        id: '2',
        name: 'Ayesha Khan',
        medicineName: 'Insulin',
        medicineTaken: false,
        reminderTime: '2:00 PM',
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
      body: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: Icon(
                patient.medicineTaken ? Icons.check_circle : Icons.cancel,
                color: patient.medicineTaken ? Colors.green : Colors.red,
              ),
              title: Text(patient.name),
              subtitle: Text(patient.medicineName + ' - ' + patient.reminderTime),
              trailing: Text(
                patient.medicineTaken ? 'Taken' : 'Missed',
                style: TextStyle(
                  color: patient.medicineTaken ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

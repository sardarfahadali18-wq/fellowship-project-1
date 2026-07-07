import 'package:flutter/material.dart';

class CaregiverDashboard extends StatelessWidget {
  const CaregiverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Dashboard'),
      ),
      body: const Center(
        child: Text(
          'Patient list will appear here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

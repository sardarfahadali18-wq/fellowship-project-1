import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'caregiver_dashboard.dart';
import 'home_screen.dart';

/// Decides where a signed-in user lands based on their role/linking status
/// stored in Firestore under users/{uid}.
class RoleGate extends StatelessWidget {
  const RoleGate({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final data = snapshot.data?.data();
        final role = data?['role'] as String?;

        if (role == 'patient') {
          return const HomeScreen();
        }

        // Default: no role yet, or role == 'caregiver'.
        // CaregiverDashboard also exposes the Invite/Link menu for
        // brand-new users who haven't picked a role yet.
        return const CaregiverDashboard();
      },
    );
  }
}

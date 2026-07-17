import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CaregiverLinkService {
  final _db = FirebaseFirestore.instance;

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  /// Called by the patient to generate a fresh invite code.
  Future<String> generateInviteCode() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not signed in');

    final code = _generateCode();

    await _db.collection('invites').doc(code).set({
      'patientId': user.uid,
      'patientEmail': user.email,
      'createdAt': FieldValue.serverTimestamp(),
      'used': false,
    });

    return code;
  }

  /// Called by the caregiver to redeem an invite code and link accounts.
  Future<String?> redeemInviteCode(String code) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Not signed in';

    final inviteRef = _db.collection('invites').doc(code.trim().toUpperCase());
    final inviteSnap = await inviteRef.get();

    if (!inviteSnap.exists) return 'Invalid invite code';

    final data = inviteSnap.data()!;
    if (data['used'] == true) return 'This invite code has already been used';

    final patientId = data['patientId'] as String;

    // Link caregiver -> patient
    await _db.collection('users').doc(user.uid).set({
      'role': 'caregiver',
      'linkedPatientId': patientId,
    }, SetOptions(merge: true));

    // Link patient -> caregiver
    await _db.collection('users').doc(patientId).set({
      'role': 'patient',
      'linkedCaregiverId': user.uid,
    }, SetOptions(merge: true));

    // Mark invite as used
    await inviteRef.update({'used': true, 'caregiverId': user.uid});

    return null; // null = success
  }

  /// Returns the linked patient ID for the current caregiver, if any.
  Future<String?> getLinkedPatientId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.data()?['linkedPatientId'] as String?;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/sos_alert.dart';
import '../models/trusted_contact.dart';

/// Fans an SOS alert out to every trusted contact over Cloud Messaging.
///
/// The client can't push straight to another user's device without a server
/// key, so the real delivery hop is a Cloud Function (see
/// `functions/sendSosAlert.js`) that triggers off new `sos_alerts` documents
/// and forwards them as FCM pushes using each contact's stored token. This
/// service writes that alert doc plus a per-contact `incoming_alerts` entry
/// so a contact's app also gets the alert in real time even before the push
/// arrives (or if the push send fails).
class AlertMessagingService {
  AlertMessagingService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> newAlertRef() {
    return _firestore.collection('sos_alerts').doc();
  }

  Future<void> sendAlert({
    required DocumentReference<Map<String, dynamic>> alertRef,
    required SosAlert alert,
    required List<TrustedContact> contacts,
    required String message,
  }) async {
    final batch = _firestore.batch();
    batch.set(alertRef, alert.toMap());

    for (final contact in contacts) {
      final inboxRef = _firestore
          .collection('users')
          .doc(contact.id)
          .collection('incoming_alerts')
          .doc(alertRef.id);
      batch.set(inboxRef, {
        ...alert.toMap(),
        'fromUserId': alert.userId,
        'message': message,
      });
    }

    await batch.commit();
  }

  Future<void> updateStatus(String alertId, SosStatus status) {
    return _firestore.collection('sos_alerts').doc(alertId).update({
      'status': status.name,
    });
  }

  /// Registers this device's FCM token so trusted contacts' alerts can reach
  /// it, and keeps it fresh when it rotates.
  Future<void> registerDeviceToken() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final messaging = FirebaseMessaging.instance;
    final token = await messaging.getToken();
    if (token != null) {
      await _saveToken(uid, token);
    }
    messaging.onTokenRefresh.listen((newToken) => _saveToken(uid, newToken));
  }

  Future<void> _saveToken(String uid, String token) {
    return _firestore.collection('users').doc(uid).set({
      'fcmToken': token,
    }, SetOptions(merge: true));
  }
}

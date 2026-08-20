import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '../models/sos_alert.dart';
import '../models/trusted_contact.dart';
import 'alert_messaging_service.dart';
import 'siren_flashlight_service.dart';
import 'sms_fallback_service.dart';

/// Coordinates the whole SOS/panic flow: grabs the user's location, starts
/// the siren + flashlight, and gets the alert to every trusted contact
/// either via Cloud Messaging (online) or SMS (offline fallback).
class SosService {
  SosService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    Connectivity? connectivity,
    SirenFlashlightService? sirenFlashlight,
    SmsFallbackService? smsFallback,
    AlertMessagingService? alertMessaging,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _connectivity = connectivity ?? Connectivity(),
       _sirenFlashlight = sirenFlashlight ?? SirenFlashlightService(),
       _smsFallback = smsFallback ?? SmsFallbackService(),
       _alertMessaging = alertMessaging ?? AlertMessagingService();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Connectivity _connectivity;
  final SirenFlashlightService _sirenFlashlight;
  final SmsFallbackService _smsFallback;
  final AlertMessagingService _alertMessaging;

  SosAlert? _activeAlert;
  SosAlert? get activeAlert => _activeAlert;

  bool get isSirenActive => _sirenFlashlight.isRunning;

  Future<SosAlert> triggerSos() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Cannot trigger SOS: no signed-in user.');
    }

    unawaited(_sirenFlashlight.start());

    final position = await _tryGetCurrentPosition();
    final contacts = await _fetchTrustedContacts(uid);
    final alertRef = _alertMessaging.newAlertRef();

    var alert = SosAlert(
      id: alertRef.id,
      userId: uid,
      triggeredAt: DateTime.now(),
      latitude: position?.latitude,
      longitude: position?.longitude,
      notifiedContactIds: contacts.map((c) => c.id).toList(),
    );

    final message = _buildMessage(alert);

    if (await _isOnline()) {
      await _alertMessaging.sendAlert(
        alertRef: alertRef,
        alert: alert,
        contacts: contacts,
        message: message,
      );
    } else {
      await _smsFallback.sendToAll(contacts, message);
    }

    _activeAlert = alert;
    return alert;
  }

  Future<void> resolveSos() => _endSos(SosStatus.resolved);

  Future<void> cancelSos() => _endSos(SosStatus.cancelled);

  Future<void> _endSos(SosStatus status) async {
    await _sirenFlashlight.stop();
    final alert = _activeAlert;
    if (alert == null) return;

    if (await _isOnline()) {
      try {
        await _alertMessaging.updateStatus(alert.id, status);
      } catch (_) {
        // Best-effort: the alert already reached contacts, a failed status
        // update shouldn't block the user from ending their own SOS.
      }
    }
    _activeAlert = null;
  }

  Future<List<TrustedContact>> _fetchTrustedContacts(String uid) async {
    final snapshot =
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('trusted_contacts')
            .get();
    return snapshot.docs
        .map((d) => TrustedContact.fromMap(d.id, d.data()))
        .toList();
  }

  String _buildMessage(SosAlert alert) {
    final location =
        alert.hasLocation ? ' My location: ${alert.googleMapsLink}' : '';
    return 'SOS! I need help right now.$location';
  }

  Future<bool> _isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  Future<Position?> _tryGetCurrentPosition() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      if (!await Geolocator.isLocationServiceEnabled()) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      // Send the alert without a location rather than blocking it.
      return null;
    }
  }
}

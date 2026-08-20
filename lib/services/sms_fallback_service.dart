import 'package:url_launcher/url_launcher.dart';

import '../models/trusted_contact.dart';

/// Sends the SOS message over SMS when there is no data connection to reach
/// Cloud Messaging. Opens the device's SMS app pre-filled with the alert so
/// the user just has to hit send — silent background sending isn't an
/// option here since iOS never allows it and Android restricts it to the
/// user's default SMS app.
class SmsFallbackService {
  Future<void> sendToAll(
    List<TrustedContact> contacts,
    String message,
  ) async {
    for (final contact in contacts) {
      if (contact.phoneNumber.isEmpty) continue;
      await _sendOne(contact.phoneNumber, message);
    }
  }

  Future<void> _sendOne(String phoneNumber, String message) async {
    final uri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': message},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

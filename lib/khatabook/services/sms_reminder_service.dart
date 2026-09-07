import 'package:url_launcher/url_launcher.dart';

import 'whatsapp_reminder_service.dart';

class SmsReminderService {
  static Uri? buildUri({
    required String customerName,
    required String? phone,
    required double balance,
  }) {
    final normalizedPhone = WhatsAppReminderService.normalizePhone(phone);
    if (normalizedPhone == null || balance <= 0) return null;

    return Uri(
      scheme: 'sms',
      path: normalizedPhone,
      queryParameters: {
        'body': WhatsAppReminderService.message(
          customerName: customerName,
          balance: balance,
        ),
      },
    );
  }

  static Future<bool> launch({
    required String customerName,
    required String? phone,
    required double balance,
  }) async {
    final uri = buildUri(
      customerName: customerName,
      phone: phone,
      balance: balance,
    );
    if (uri == null) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

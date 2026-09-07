import 'package:url_launcher/url_launcher.dart';

class WhatsAppReminderService {
  static String? normalizePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return null;

    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00')) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0')) {
      digits = '92${digits.substring(1)}';
    }

    if (digits.length < 8 || digits.length > 15) return null;
    return digits;
  }

  static String message({
    required String customerName,
    required double balance,
  }) {
    final amount = balance.toStringAsFixed(balance % 1 == 0 ? 0 : 2);
    return 'Assalam o Alaikum $customerName, this is a friendly reminder regarding '
        'your pending amount of Rs. $amount. Please clear the outstanding amount '
        'at your convenience. Thank you.';
  }

  static Uri? buildUri({
    required String customerName,
    required String? phone,
    required double balance,
  }) {
    final normalizedPhone = normalizePhone(phone);
    if (normalizedPhone == null || balance <= 0) return null;

    return Uri.https('wa.me', '/$normalizedPhone', {
      'text': message(customerName: customerName, balance: balance),
    });
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

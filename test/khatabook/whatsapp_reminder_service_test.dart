import 'package:fellowship_project_1/khatabook/services/whatsapp_reminder_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WhatsAppReminderService', () {
    test('builds a Pakistan WhatsApp URI with an encoded reminder', () {
      final uri = WhatsAppReminderService.buildUri(
        customerName: 'Ali Khan',
        phone: '0300-1234567',
        balance: 1250,
      );

      expect(uri?.host, 'wa.me');
      expect(uri?.path, '/923001234567');
      expect(uri?.queryParameters['text'], contains('Ali Khan'));
      expect(uri?.queryParameters['text'], contains('Rs. 1250'));
    });

    test('rejects missing or invalid phone numbers', () {
      expect(
        WhatsAppReminderService.buildUri(
          customerName: 'Ali',
          phone: null,
          balance: 100,
        ),
        isNull,
      );
      expect(WhatsAppReminderService.normalizePhone('123'), isNull);
    });

    test('does not build reminders for settled or credit balances', () {
      expect(
        WhatsAppReminderService.buildUri(
          customerName: 'Ali',
          phone: '03001234567',
          balance: 0,
        ),
        isNull,
      );
      expect(
        WhatsAppReminderService.buildUri(
          customerName: 'Ali',
          phone: '03001234567',
          balance: -50,
        ),
        isNull,
      );
    });
  });
}

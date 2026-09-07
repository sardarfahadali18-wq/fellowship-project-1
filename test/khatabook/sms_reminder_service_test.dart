import 'package:fellowship_project_1/khatabook/services/sms_reminder_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmsReminderService', () {
    test('builds an SMS URI with the normalized phone and reminder body', () {
      final uri = SmsReminderService.buildUri(
        customerName: 'Ali Khan',
        phone: '0300-1234567',
        balance: 1250,
      );

      expect(uri?.scheme, 'sms');
      expect(uri?.path, '923001234567');
      expect(uri?.queryParameters['body'], contains('Ali Khan'));
      expect(uri?.queryParameters['body'], contains('Rs. 1250'));
    });

    test('does not build an SMS URI without a usable phone or balance', () {
      expect(
        SmsReminderService.buildUri(
          customerName: 'Ali',
          phone: null,
          balance: 100,
        ),
        isNull,
      );
      expect(
        SmsReminderService.buildUri(
          customerName: 'Ali',
          phone: '03001234567',
          balance: 0,
        ),
        isNull,
      );
    });
  });
}

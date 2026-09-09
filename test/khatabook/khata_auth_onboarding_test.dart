import 'package:fellowship_project_1/khatabook/localization/khata_localizations.dart';
import 'package:fellowship_project_1/khatabook/screens/auth/phone_auth_screen.dart';
import 'package:fellowship_project_1/khatabook/screens/onboarding/onboarding_screen.dart';
import 'package:fellowship_project_1/khatabook/widgets/language_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Auth & Onboarding Validation & Logic Tests (Faizan)', () {
    // Phone validation helper matching PhoneAuthScreen logic
    bool isValidPakistaniPhone(String input) {
      final raw = input.replaceAll(RegExp(r'\D'), '');
      if (raw.length == 10 && raw.startsWith('3')) return true;
      if (raw.length == 11 && raw.startsWith('03')) return true;
      if (raw.length == 12 && raw.startsWith('923')) return true;
      return false;
    }

    String formatFullPhone(String input) {
      var raw = input.replaceAll(RegExp(r'\D'), '');
      if (raw.startsWith('92')) return '+$raw';
      if (raw.startsWith('0')) raw = raw.substring(1);
      return '+92$raw';
    }

    test('validates Pakistani mobile phone numbers accurately', () {
      // Valid Pakistani formats
      expect(isValidPakistaniPhone('03001234567'), isTrue);
      expect(isValidPakistaniPhone('0300 1234567'), isTrue);
      expect(isValidPakistaniPhone('0321-9876543'), isTrue);
      expect(isValidPakistaniPhone('3001234567'), isTrue);
      expect(isValidPakistaniPhone('+923001234567'), isTrue);
      expect(isValidPakistaniPhone('923001234567'), isTrue);
      expect(isValidPakistaniPhone('03451122334'), isTrue);

      // Invalid formats
      expect(isValidPakistaniPhone(''), isFalse);
      expect(isValidPakistaniPhone('12345'), isFalse);
      expect(isValidPakistaniPhone('0211234567'), isFalse); // Landline prefix
      expect(isValidPakistaniPhone('04212345678'), isFalse); // Lahore landline prefix
      expect(isValidPakistaniPhone('030012345'), isFalse); // Too short
      expect(isValidPakistaniPhone('030012345678'), isFalse); // Too long
      expect(isValidPakistaniPhone('abcdefghijk'), isFalse); // Letters
    });

    test('formats valid Pakistani numbers to standardized E.164 international format', () {
      expect(formatFullPhone('03001234567'), '+923001234567');
      expect(formatFullPhone('0300 1234567'), '+923001234567');
      expect(formatFullPhone('3001234567'), '+923001234567');
      expect(formatFullPhone('923001234567'), '+923001234567');
      expect(formatFullPhone('+923001234567'), '+923001234567');
    });

    test('verifies OTP code requirements', () {
      bool isValidOtp(String otp) => otp.trim().length == 6 && RegExp(r'^\d{6}$').hasMatch(otp.trim());

      expect(isValidOtp('123456'), isTrue);
      expect(isValidOtp('000000'), isTrue);
      expect(isValidOtp('12345'), isFalse); // 5 digits
      expect(isValidOtp('1234567'), isFalse); // 7 digits
      expect(isValidOtp('12345a'), isFalse); // alphanumeric
      expect(isValidOtp(''), isFalse);
    });

    test('confirms SharedPreferences persistence key names', () {
      expect(OnboardingScreen.prefCompletedKey, 'khatabook.onboarding_completed');
      expect(PhoneAuthScreen.prefIsLoggedInKey, 'khatabook.is_logged_in');
      expect(PhoneAuthScreen.prefVendorPhoneKey, 'khatabook.vendor_phone');
      expect(KhataLocaleController.prefKey, 'khatabook.selected_language');
    });
  });

  group('Auth & Onboarding Widget Tests (Faizan)', () {
    testWidgets('OnboardingScreen renders 3-screen tutorial with skip button & language selector', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );

      // Verify Skip button exists
      expect(find.text('Skip'), findsOneWidget);

      // Verify Language selector button exists
      expect(find.byIcon(Icons.language), findsOneWidget);

      // Verify PageView exists
      expect(find.byType(PageView), findsOneWidget);

      // Verify Next button exists
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('LanguagePickerSheet renders Urdu, English, Punjabi, and Sindhi options', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LanguagePickerSheet(),
          ),
        ),
      );

      expect(find.text('اردو'), findsOneWidget);
      expect(find.text('English'), findsWidgets);
      expect(find.text('پنجابی'), findsOneWidget);
      expect(find.text('سنڌي'), findsOneWidget);
    });
  });
}

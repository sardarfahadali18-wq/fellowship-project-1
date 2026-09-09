import 'package:fellowship_project_1/khatabook/localization/khata_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KhataLanguage & Localization Tests (Faizan)', () {
    test('supports Urdu, English, Punjabi, and Sindhi languages with correct directionality', () {
      expect(KhataLanguage.values.length, 4);

      final urdu = KhataLanguage.fromCode('ur');
      expect(urdu, KhataLanguage.urdu);
      expect(urdu.direction, TextDirection.rtl);
      expect(urdu.nativeName, 'اردو');
      expect(urdu.englishName, 'Urdu');

      final english = KhataLanguage.fromCode('en');
      expect(english, KhataLanguage.english);
      expect(english.direction, TextDirection.ltr);
      expect(english.nativeName, 'English');

      final punjabi = KhataLanguage.fromCode('pa');
      expect(punjabi, KhataLanguage.punjabi);
      expect(punjabi.direction, TextDirection.rtl);
      expect(punjabi.nativeName, 'پنجابی');
      expect(punjabi.englishName, 'Punjabi');

      final sindhi = KhataLanguage.fromCode('sd');
      expect(sindhi, KhataLanguage.sindhi);
      expect(sindhi.direction, TextDirection.rtl);
      expect(sindhi.nativeName, 'سنڌي');
      expect(sindhi.englishName, 'Sindhi');
    });

    test('defaults to Urdu for unknown or null language codes', () {
      final fallbackUnknown = KhataLanguage.fromCode('unknown');
      expect(fallbackUnknown, KhataLanguage.urdu);

      final fallbackNull = KhataLanguage.fromCode(null);
      expect(fallbackNull, KhataLanguage.urdu);
    });

    test('retrieves onboarding translations across all 4 languages', () {
      for (final lang in KhataLanguage.values) {
        expect(KhataStrings.get('onboarding_title_1', lang), isNotEmpty);
        expect(KhataStrings.get('onboarding_desc_1', lang), isNotEmpty);
        expect(KhataStrings.get('onboarding_title_2', lang), isNotEmpty);
        expect(KhataStrings.get('onboarding_desc_2', lang), isNotEmpty);
        expect(KhataStrings.get('onboarding_title_3', lang), isNotEmpty);
        expect(KhataStrings.get('onboarding_desc_3', lang), isNotEmpty);
        expect(KhataStrings.get('skip', lang), isNotEmpty);
        expect(KhataStrings.get('next', lang), isNotEmpty);
        expect(KhataStrings.get('get_started', lang), isNotEmpty);
      }
    });

    test('retrieves phone auth translations across all 4 languages', () {
      for (final lang in KhataLanguage.values) {
        expect(KhataStrings.get('vendor_signup', lang), isNotEmpty);
        expect(KhataStrings.get('enter_phone', lang), isNotEmpty);
        expect(KhataStrings.get('phone_number', lang), isNotEmpty);
        expect(KhataStrings.get('send_otp', lang), isNotEmpty);
        expect(KhataStrings.get('enter_otp', lang), isNotEmpty);
        expect(KhataStrings.get('verify_continue', lang), isNotEmpty);
        expect(KhataStrings.get('resend_otp', lang), isNotEmpty);
        expect(KhataStrings.get('demo_login', lang), isNotEmpty);
        expect(KhataStrings.get('invalid_phone', lang), isNotEmpty);
        expect(KhataStrings.get('invalid_otp', lang), isNotEmpty);
      }
    });

    test('returns exact Urdu and English strings for core actions', () {
      expect(KhataStrings.get('skip', KhataLanguage.urdu), 'چھوڑیں');
      expect(KhataStrings.get('skip', KhataLanguage.english), 'Skip');

      expect(KhataStrings.get('next', KhataLanguage.urdu), 'آگے');
      expect(KhataStrings.get('next', KhataLanguage.english), 'Next');

      expect(KhataStrings.get('get_started', KhataLanguage.urdu), 'شروع کریں');
      expect(KhataStrings.get('get_started', KhataLanguage.english), 'Get Started');

      expect(KhataStrings.get('select_language', KhataLanguage.urdu), 'زبان منتخب کریں');
      expect(KhataStrings.get('select_language', KhataLanguage.english), 'Select Language');
    });

    test('returns key fallback when string is missing in dictionary', () {
      expect(KhataStrings.get('missing_random_key_123', KhataLanguage.urdu), 'missing_random_key_123');
    });
  });
}

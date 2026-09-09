import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported languages in KhataBook Lite.
/// (Faizan — Auth & Onboarding module)
enum KhataLanguage {
  urdu('ur', 'اردو', 'Urdu', TextDirection.rtl),
  english('en', 'English', 'English', TextDirection.ltr),
  punjabi('pa', 'پنجابی', 'Punjabi', TextDirection.rtl),
  sindhi('sd', 'سنڌي', 'Sindhi', TextDirection.rtl);

  const KhataLanguage(this.code, this.nativeName, this.englishName, this.direction);

  final String code;
  final String nativeName;
  final String englishName;
  final TextDirection direction;

  static KhataLanguage fromCode(String? code) {
    return KhataLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => KhataLanguage.urdu, // Default to Urdu for Pakistani street vendors
    );
  }
}

/// App-wide localization controller with persistence and reactive updates.
/// (Faizan — Auth & Onboarding module)
class KhataLocaleController extends ChangeNotifier {
  KhataLocaleController._();
  static final KhataLocaleController instance = KhataLocaleController._();

  static const String prefKey = 'khatabook.selected_language';
  KhataLanguage _currentLanguage = KhataLanguage.urdu;

  KhataLanguage get currentLanguage => _currentLanguage;
  Locale get locale => Locale(_currentLanguage.code);
  TextDirection get textDirection => _currentLanguage.direction;
  bool get isRtl => _currentLanguage.direction == TextDirection.rtl;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(prefKey);
      if (savedCode != null) {
        _currentLanguage = KhataLanguage.fromCode(savedCode);
      }
    } catch (_) {
      _currentLanguage = KhataLanguage.urdu;
    }
    notifyListeners();
  }

  Future<void> setLanguage(KhataLanguage language) async {
    if (_currentLanguage == language) return;
    _currentLanguage = language;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefKey, language.code);
    } catch (_) {}
  }

  String t(String key) {
    return KhataStrings.get(key, _currentLanguage);
  }

  static String tr(String key) {
    return instance.t(key);
  }
}

/// Localization strings for KhataBook Lite across Urdu, English, Punjabi, and Sindhi.
/// (Faizan — Auth & Onboarding module)
class KhataStrings {
  static const Map<String, Map<String, String>> _strings = {
    // App & Navigation
    'app_title': {
      'en': 'KhataBook Lite',
      'ur': 'کھاتہ بک لائیٹ',
      'pa': 'کھاتہ بک لائیٹ',
      'sd': 'کاتي ڪتاب لائيٽ',
    },
    'tagline': {
      'en': 'Digital Ledger for Vendors & Shopkeepers',
      'ur': 'دکانداروں اور ریڑھی والوں کے لیے ڈیجیٹل کھاتہ',
      'pa': 'دکانداراں لئی ڈیجیٹل کھاتہ',
      'sd': 'دڪاندارن لاءِ ڊجيٽل کاتو',
    },

    // Onboarding (3 Screens for Pakistani vendors)
    'onboarding_title_1': {
      'en': 'Safe & Permanent Digital Khata',
      'ur': 'محفوظ اور مستقل ڈیجیٹل کھاتہ',
      'pa': 'محفوظ تے پکا ڈیجیٹل کھاتہ',
      'sd': 'محفوظ ۽ پڪو ڊجيٽل کاتو',
    },
    'onboarding_desc_1': {
      'en': 'No more lost, torn, or wet paper diaries. Keep your customer credit (udhaar) safe forever.',
      'ur': 'کاپیوں اور ڈائریوں کے پھٹنے، گم ہونے یا خراب ہونے سے نجات۔ اپنے گاہکوں کا ادھار محفوظ رکھیں۔',
      'pa': 'رجسٹراں دے گم ہون توں جان چھڑاؤ۔ اپنے ادھار دا مکمل حساب محفوظ رکھو۔',
      'sd': 'رجسٽر ۽ ڪاپيون گم ٿيڻ کان نجات. پنهنجو ادھار هميشه محفوظ رکو.',
    },
    'onboarding_title_2': {
      'en': 'Simple Gave & Got in Seconds',
      'ur': 'دیے اور لیے کا آسان اندراج',
      'pa': 'دتے تے لئے دا آسان حساب',
      'sd': 'ڏنا ۽ ورتا جو آسان حساب',
    },
    'onboarding_desc_2': {
      'en': 'Big numeric keypad, fast entry, photo receipts, and voice typing designed for quick busy market use.',
      'ur': 'بڑا عددی کی پیڈ، فوری اندراج، بل کی تصویر اور آواز سے اندراج جو بازار کی مصروفیت کے لیے آسان ہے۔',
      'pa': 'وڈے بٹناں والا کی پیڈ، بل دی تصویر تے بول کے کھاتہ لکھن دی سہولت۔',
      'sd': 'وڏو ڪي پيڊ، تڪڙو داخل، رسيد جي تصوير ۽ ڳالهائي کاتو لکڻ جي سهولت.',
    },
    'onboarding_title_3': {
      'en': '100% Offline with WhatsApp Reminders',
      'ur': 'بغیر انٹرنیٹ اور واٹس ایپ یاد دہانی',
      'pa': 'بغیر انٹرنیٹ تے واٹس ایپ میسج',
      'sd': 'انٽرنيٽ کانسواءِ ۽ واٽس ايپ ميسج',
    },
    'onboarding_desc_3': {
      'en': 'Works fully without internet. Send balance reminders via WhatsApp/SMS with one tap, and auto-sync when online.',
      'ur': 'انٹرنیٹ کے بغیر 100% کام کرے گا۔ ایک کلک پر گاہک کو یاد دہانی بھیجیں اور آن لائن ہوتے ہی خودکار بیک اپ۔',
      'pa': 'انٹرنیٹ توں بغیر وی کم کردا اے۔ اک بٹن نال یاد دہانی بھیجو۔',
      'sd': 'انٽرنيٽ کانسواءِ به ڪم ڪندو. گراهڪن کي واٽس ايپ ميسج موڪليو.',
    },
    'skip': {
      'en': 'Skip',
      'ur': 'چھوڑیں',
      'pa': 'چھڈو',
      'sd': 'ڇڏيو',
    },
    'next': {
      'en': 'Next',
      'ur': 'آگے',
      'pa': 'اگے',
      'sd': 'اڳيان',
    },
    'get_started': {
      'en': 'Get Started',
      'ur': 'شروع کریں',
      'pa': 'شروع کرو',
      'sd': 'شروع ڪريو',
    },

    // Auth & Phone OTP (Firebase Auth)
    'vendor_signup': {
      'en': 'Vendor Sign In / Register',
      'ur': 'دکاندار لاگ ان / اندراج',
      'pa': 'دکاندار لاگ ان',
      'sd': 'دڪاندار لاگ ان / رجسٽر',
    },
    'enter_phone': {
      'en': 'Enter your mobile number to get started',
      'ur': 'اپنے ڈیجیٹل کھاتے کے لیے اپنا موبائل نمبر درج کریں',
      'pa': 'کھاتہ شروع کرن لئی اپنا موبائل نمبر لکھو',
      'sd': 'کاتي جي شروعات لاءِ پنهنجو موبائل نمبر لکو',
    },
    'phone_number': {
      'en': 'Mobile Number',
      'ur': 'موبائل نمبر',
      'pa': 'موبائل نمبر',
      'sd': 'موبائل نمبر',
    },
    'send_otp': {
      'en': 'Send OTP Code',
      'ur': 'تصدیقی کوڈ حاصل کریں',
      'pa': 'کوڈ بھیجو',
      'sd': 'تصديقي ڪوڊ موڪليو',
    },
    'enter_otp': {
      'en': 'Enter 6-Digit Verification Code',
      'ur': '6 ہندسوں کا تصدیقی کوڈ درج کریں',
      'pa': '6 نمبراں دا کوڈ لکھو',
      'sd': '6 انگن جو تصديقي ڪوڊ لکو',
    },
    'verify_continue': {
      'en': 'Verify & Continue',
      'ur': 'تصدیق کریں اور داخل ہوں',
      'pa': 'تصدیق کرو تے اگے ودھو',
      'sd': 'تصديق ڪريو ۽ اڳتي وڌو',
    },
    'resend_otp': {
      'en': 'Resend Code',
      'ur': 'دوبارہ کوڈ بھیجیں',
      'pa': 'دوبارہ کوڈ بھیجو',
      'sd': 'ٻيهر ڪوڊ موڪليو',
    },
    'demo_login': {
      'en': 'Instant Demo / Offline Login',
      'ur': 'فوری ٹیسٹ / آف لائن لاگ ان',
      'pa': 'فوری ٹیسٹ لاگ ان',
      'sd': 'فوري ٽيسٽ لاگ ان',
    },
    'demo_login_sub': {
      'en': 'Log in instantly without waiting for SMS OTP',
      'ur': 'ایس ایم ایس کا انتظار کیے بغیر فوراً کھاتہ کھولیں',
      'pa': 'بغیر ایس ایم ایس انتظار دے فوری کھاتہ کھولو',
      'sd': 'ايس ايم ايس بنا فوري طور کاتو کوليو',
    },
    'invalid_phone': {
      'en': 'Please enter a valid Pakistani mobile number (e.g. 0300 1234567)',
      'ur': 'درست پاکستانی موبائل نمبر درج کریں (مثلاً 03001234567)',
      'pa': 'صحیح موبائل نمبر لکھو',
      'sd': 'صحيح موبائل نمبر داخل ڪريو',
    },
    'invalid_otp': {
      'en': 'Please enter the complete 6-digit code',
      'ur': 'برائے مہربانی مکمل 6 ہندسوں کا کوڈ درج کریں',
      'pa': 'پورا 6 ہندسیاں دا کوڈ لکھو',
      'sd': 'مهرباني ڪري پورو 6 انگن جو ڪوڊ داخل ڪريو',
    },
    'phone_required': {
      'en': 'Mobile number is required',
      'ur': 'موبائل نمبر ضروری ہے',
      'pa': 'موبائل نمبر ضروری اے',
      'sd': 'موبائل نمبر ضروري آهي',
    },
    'otp_sent_to': {
      'en': 'Verification code sent to',
      'ur': 'تصدیقی کوڈ بھیج دیا گیا ہے',
      'pa': 'کوڈ بھیج دتا گیا اے',
      'sd': 'تصديقي ڪوڊ موڪليو ويو',
    },
    'change_number': {
      'en': 'Change Number',
      'ur': 'نمبر تبدیل کریں',
      'pa': 'نمبر بدلو',
      'sd': 'نمبر تبديل ڪريو',
    },
    'logged_in_as': {
      'en': 'Logged in as',
      'ur': 'لاگ ان بطور',
      'pa': 'لاگ ان بطور',
      'sd': 'لاگ ان بطور',
    },

    // Language Picker
    'select_language': {
      'en': 'Select Language',
      'ur': 'زبان منتخب کریں',
      'pa': 'زبان چنو',
      'sd': 'ٻولي چونڊيو',
    },

    // Customer & Ledger
    'dashboard': {
      'en': 'Dashboard',
      'ur': 'ڈیش بورڈ',
      'pa': 'ڈیش بورڈ',
      'sd': 'ڊيش بورڊ',
    },
    'you_will_get': {
      'en': 'You Will Get',
      'ur': 'آپ لیں گے',
      'pa': 'تسیں لوو گے',
      'sd': 'توهان وٺندا',
    },
    'you_will_give': {
      'en': 'You Will Give',
      'ur': 'آپ دیں گے',
      'pa': 'تسیں دیو گے',
      'sd': 'توهان ڏيندا',
    },
    'net_balance': {
      'en': 'Net Balance',
      'ur': 'کل بقایا رقم',
      'pa': 'کل بقایا',
      'sd': 'ڪل بقايا رقم',
    },
    'all_customers': {
      'en': 'All Customers',
      'ur': 'تمام گاہک',
      'pa': 'سارے گاہک',
      'sd': 'سمورا گراهڪ',
    },
    'overdue_customers': {
      'en': 'Overdue',
      'ur': 'واجب الادا',
      'pa': 'باقی دار',
      'sd': 'واجب الادا',
    },
    'search_customers': {
      'en': 'Search by name or phone...',
      'ur': 'نام یا فون نمبر سے تلاش کریں...',
      'pa': 'ناں یا فون نال لبھو...',
      'sd': 'نالي يا فون نمبر سان ڳوليو...',
    },
    'no_customers_found': {
      'en': 'No customers found',
      'ur': 'کوئی گاہک نہیں ملا',
      'pa': 'کوئی گاہک نئیں لبھیا',
      'sd': 'ڪو گراهڪ نه مليو',
    },
    'no_customers_yet': {
      'en': 'No customers added yet. Tap + to add your first customer.',
      'ur': 'ابھی تک کوئی گاہک موجود نہیں۔ پہلا گاہک شامل کرنے کے لیے + دبائیں۔',
      'pa': 'حالے کوئی گاہک نئیں ہے۔ پہلا گاہک جوڑن لئی + دباؤ۔',
      'sd': 'اڃا تائين ڪو گراهڪ شامل ناهي ڪيو ويو. گراهڪ شامل ڪرڻ لاءِ + دٻايو.',
    },
    'add_customer': {
      'en': 'Add Customer',
      'ur': 'گاہک شامل کریں',
      'pa': 'گاہک جوڑو',
      'sd': 'گراهڪ شامل ڪريو',
    },
    'customer_name': {
      'en': 'Customer Name',
      'ur': 'گاہک کا نام',
      'pa': 'گاہک دا ناں',
      'sd': 'گراهڪ جو نالو',
    },
    'customer_phone': {
      'en': 'Mobile Number (Optional)',
      'ur': 'موبائل نمبر (اختیاری)',
      'pa': 'موبائل نمبر (مرضی نال)',
      'sd': 'موبائل نمبر (اختياري)',
    },
    'name_required': {
      'en': 'Customer name is required',
      'ur': 'گاہک کا نام ضروری ہے',
      'pa': 'گاہک دا ناں ضروری اے',
      'sd': 'گراهڪ جو نالو ضروري آهي',
    },
    'import_contacts': {
      'en': 'Import from Contacts',
      'ur': 'فون کے رابطوں سے لائیں',
      'pa': 'فون رابطیاں چوں لیاؤ',
      'sd': 'فون مان چونڊيو',
    },
    'save': {
      'en': 'Save',
      'ur': 'محفوظ کریں',
      'pa': 'محفوظ کرو',
      'sd': 'محفوظ ڪريو',
    },
    'saving': {
      'en': 'Saving...',
      'ur': 'محفوظ ہو رہا ہے...',
      'pa': 'محفوظ ہو رہیا اے...',
      'sd': 'محفوظ ٿي رهيو آهي...',
    },
    'owes_you': {
      'en': 'Owes you',
      'ur': 'آپ کو دینا ہے',
      'pa': 'تہانوں دیݨا اے',
      'sd': 'توهان کي ڏيڻو آهي',
    },
    'you_owe': {
      'en': 'You owe',
      'ur': 'آپ نے دینا ہے',
      'pa': 'تساں دیݨا اے',
      'sd': 'توهان ڏيڻو آهي',
    },
    'settled': {
      'en': 'Settled',
      'ur': 'حساب برابر',
      'pa': 'حساب برابر',
      'sd': 'حساب برابر',
    },
    'customer_ledger': {
      'en': 'Customer Ledger',
      'ur': 'گاہک کا کھاتہ',
      'pa': 'گاہک دا کھاتہ',
      'sd': 'گراهڪ جو کاتو',
    },
    'transaction_history': {
      'en': 'Transaction History',
      'ur': 'لین دین کی تفصیل',
      'pa': 'لین دین دا ویروا',
      'sd': 'ٽرانزيڪشن جي تفصيل',
    },
    'no_transactions': {
      'en': 'No transactions recorded yet.',
      'ur': 'ابھی تک کوئی لین دین نہیں ہوا۔',
      'pa': 'اجے کوئی لین دین نئیں ہویا۔',
      'sd': 'اڃا تائين ڪا به ٽرانزيڪشن رڪارڊ ناهي ٿي.',
    },
    'record_transaction': {
      'en': 'Record Transaction',
      'ur': 'لین دین درج کریں',
      'pa': 'لین دین درج کرو',
      'sd': 'ٽرانزيڪشن درج ڪريو',
    },
    'gave_credit': {
      'en': 'Gave (Credit)',
      'ur': 'دیے (ادھار)',
      'pa': 'دتے (ادھار)',
      'sd': 'ڏنا (ادھار)',
    },
    'got_payment': {
      'en': 'Got (Payment)',
      'ur': 'لیے (وصولی)',
      'pa': 'لئے (وصولی)',
      'sd': 'ورتا (وصولي)',
    },
    'enter_amount': {
      'en': 'Enter Amount',
      'ur': 'رقم درج کریں',
      'pa': 'رقم درج کرو',
      'sd': 'رقم لکو',
    },
    'add_note_optional': {
      'en': 'Add note (optional)',
      'ur': 'تفصیل لکھیں (اختیاری)',
      'pa': 'تفصیل لکھو (مرضی نال)',
      'sd': 'وضاحت لکو (اختياري)',
    },
    'tutorial': {
      'en': 'How to Use (Tutorial)',
      'ur': 'ایپ کے استعمال کا طریقہ',
      'pa': 'ورتن دا طریقہ',
      'sd': 'واپرائڻ جو طريقو',
    },
    'logout': {
      'en': 'Log Out',
      'ur': 'لاگ آؤٹ',
      'pa': 'لاگ آؤٹ',
      'sd': 'لاگ آئوٽ',
    },
    'logout_confirm': {
      'en': 'Are you sure you want to log out?',
      'ur': 'کیا آپ واقعی لاگ آؤٹ کرنا چاہتے ہیں؟',
      'pa': 'کی تسیں لاگ آؤٹ کرنا چاہندے او؟',
      'sd': 'ڇا توهان لاگ آئوٽ ڪرڻ چاهيو ٿا؟',
    },
    'cancel': {
      'en': 'Cancel',
      'ur': 'منسوخ',
      'pa': 'منسوخ',
      'sd': 'منسوخ',
    },
  };

  static String get(String key, KhataLanguage language) {
    final map = _strings[key];
    if (map == null) return key;
    return map[language.code] ?? map['en'] ?? key;
  }
}

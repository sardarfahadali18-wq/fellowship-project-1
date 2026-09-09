import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localization/khata_localizations.dart';
import '../../services/khata_ledger_repository.dart';
import '../../services/ledger_repository.dart';
import '../../widgets/language_picker_sheet.dart';
import '../khata_customers_screen.dart';

/// Phone number OTP signup / login screen using Firebase Auth.
/// (Faizan — Auth & Onboarding module)
class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({
    super.key,
    this.nextScreen,
    this.onSuccess,
    this.repository,
  });

  final Widget? nextScreen;
  final VoidCallback? onSuccess;
  final LedgerRepository? repository;

  static const String prefVendorPhoneKey = 'khatabook.vendor_phone';
  static const String prefIsLoggedInKey = 'khatabook.is_logged_in';

  /// Helper to check if vendor is currently logged in.
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(prefIsLoggedInKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Helper to get the logged-in vendor's phone number.
  static Future<String?> getVendorPhone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(prefVendorPhoneKey);
    } catch (_) {
      return null;
    }
  }

  /// Helper to sign out vendor and clear session.
  static Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(prefIsLoggedInKey);
      await prefs.remove(prefVendorPhoneKey);
    } catch (_) {}
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
  }

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isOtpSent = false;
  bool _isLoading = false;
  String? _verificationId;
  int? _resendToken;
  String? _errorMessage;

  Timer? _timer;
  int _countdown = 60;
  bool _canResend = false;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdown = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        setState(() => _canResend = true);
      }
    });
  }

  String _formatFullPhone(String input) {
    var raw = input.replaceAll(RegExp(r'\D'), '');
    if (raw.startsWith('92')) {
      return '+$raw';
    }
    if (raw.startsWith('0')) {
      raw = raw.substring(1);
    }
    return '+92$raw';
  }

  bool _isValidPakistaniPhone(String input) {
    final raw = input.replaceAll(RegExp(r'\D'), '');
    // Standard Pakistani numbers: 03XX XXXXXXX (11 digits) or 3XX XXXXXXX (10 digits) or 923XX XXXXXXX (12 digits)
    if (raw.length == 10 && raw.startsWith('3')) return true;
    if (raw.length == 11 && raw.startsWith('03')) return true;
    if (raw.length == 12 && raw.startsWith('923')) return true;
    return false;
  }

  Future<void> _sendOtp() async {
    final rawInput = _phoneController.text.trim();
    if (!_isValidPakistaniPhone(rawInput)) {
      setState(() {
        _errorMessage = KhataLocaleController.instance.t('invalid_phone');
      });
      return;
    }

    final fullPhoneNumber = _formatFullPhone(rawInput);
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution (e.g. Android SMS retriever)
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            await _onLoginSuccess(fullPhoneNumber);
          } catch (e) {
            if (mounted) setState(() => _errorMessage = e.toString());
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _errorMessage = e.message ?? 'Verification failed (${e.code}). You can use Demo Login.';
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _isOtpSent = true;
            _isLoading = false;
          });
          _startCountdown();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error initiating phone verification: $e';
      });
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      setState(() {
        _errorMessage = KhataLocaleController.instance.t('invalid_otp');
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_verificationId != null) {
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: code,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
      final phone = _formatFullPhone(_phoneController.text.trim());
      await _onLoginSuccess(phone);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message ?? 'Invalid OTP code. Please try again.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Verification error: $e';
      });
    }
  }

  Future<void> _loginWithDemo() async {
    setState(() => _isLoading = true);
    const demoPhone = '+92 300 1234567';
    await _onLoginSuccess(demoPhone);
  }

  Future<void> _onLoginSuccess(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(PhoneAuthScreen.prefIsLoggedInKey, true);
      await prefs.setString(PhoneAuthScreen.prefVendorPhoneKey, phone);
    } catch (_) {}

    if (!mounted) return;

    if (widget.onSuccess != null) {
      widget.onSuccess!();
      return;
    }

    final targetScreen = widget.nextScreen ??
        KhataCustomersScreen(
          repository: widget.repository ?? KhataLedgerRepository(),
        );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => targetScreen),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = KhataLocaleController.instance;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(controller.t('app_title')),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.language, size: 20),
            label: Text(
              controller.currentLanguage.nativeName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => LanguagePickerSheet.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // App Icon & Header
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green.shade200, width: 2),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 48,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                controller.t('vendor_signup'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _isOtpSent
                    ? '${controller.t('enter_otp')} (${_phoneController.text})'
                    : controller.t('enter_phone'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),

              // Error banner if any
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: colorScheme.error),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: colorScheme.onErrorContainer,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // View 1: Phone Input
              if (!_isOtpSent) ...[
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                  style: const TextStyle(fontSize: 18, letterSpacing: 1.2),
                  decoration: InputDecoration(
                    labelText: controller.t('phone_number'),
                    hintText: '0300 1234567',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🇵🇰 +92',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          SizedBox(
                            height: 24,
                            child: VerticalDivider(thickness: 1.5),
                          ),
                        ],
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.sms_outlined),
                            const SizedBox(width: 8),
                            Text(
                              controller.t('send_otp'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ] else ...[
                // View 2: OTP Verification
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatFullPhone(_phoneController.text),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      tooltip: controller.t('change_number'),
                      onPressed: () {
                        setState(() {
                          _isOtpSent = false;
                          _errorMessage = null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 26,
                    letterSpacing: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '••••••',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          controller.t('verify_continue'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: _canResend
                      ? TextButton(
                          onPressed: _sendOtp,
                          child: Text(
                            controller.t('resend_otp'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        )
                      : Text(
                          '${controller.t('resend_otp')} in ${_countdown}s',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                ),
              ],

              const SizedBox(height: 36),
              const Divider(),
              const SizedBox(height: 16),

              // Instant Demo / Offline login card
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _loginWithDemo,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: BorderSide(color: Colors.green.shade300),
                ),
                icon: const Icon(Icons.flash_on, color: Colors.green),
                label: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.t('demo_login'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      controller.t('demo_login_sub'),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

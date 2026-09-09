import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'khatabook/data/khatabook_isar_service.dart';
import 'khatabook/localization/khata_localizations.dart';
import 'khatabook/screens/auth/phone_auth_screen.dart';
import 'khatabook/screens/khata_customers_screen.dart';
import 'khatabook/screens/onboarding/onboarding_screen.dart';
import 'khatabook/services/khata_ledger_repository.dart';
import 'khatabook/services/ledger_repository.dart';
import 'khatabook/widgets/language_picker_sheet.dart';

/// Standalone entry point to run and demo the KhataBook Lite Auth & Onboarding
/// module (Faizan): `flutter run -t lib/main_khatabook_auth_demo.dart`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize localization
  await KhataLocaleController.instance.init();

  // Initialize local-first Isar storage
  await KhataBookIsarService.getInstance();
  final repository = KhataLedgerRepository();

  // Initialize Firebase (safely handles offline / unconfigured environments)
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (_) {}

  // Check persistent onboarding and authentication states
  final onboardingDone = await OnboardingScreen.isCompleted();
  final isLoggedIn = await PhoneAuthScreen.isLoggedIn();
  final vendorPhone = await PhoneAuthScreen.getVendorPhone();

  runApp(
    KhataBookAuthDemoApp(
      repository: repository,
      onboardingDone: onboardingDone,
      isLoggedIn: isLoggedIn,
      vendorPhone: vendorPhone,
    ),
  );
}

class KhataBookAuthDemoApp extends StatefulWidget {
  const KhataBookAuthDemoApp({
    super.key,
    required this.repository,
    required this.onboardingDone,
    required this.isLoggedIn,
    this.vendorPhone,
  });

  final LedgerRepository repository;
  final bool onboardingDone;
  final bool isLoggedIn;
  final String? vendorPhone;

  @override
  State<KhataBookAuthDemoApp> createState() => _KhataBookAuthDemoAppState();
}

class _KhataBookAuthDemoAppState extends State<KhataBookAuthDemoApp> {
  late bool _onboardingDone;
  late bool _isLoggedIn;
  String? _vendorPhone;

  @override
  void initState() {
    super.initState();
    _onboardingDone = widget.onboardingDone;
    _isLoggedIn = widget.isLoggedIn;
    _vendorPhone = widget.vendorPhone;
  }

  void _onOnboardingFinished() {
    setState(() => _onboardingDone = true);
  }

  void _onLoginSuccess() async {
    final phone = await PhoneAuthScreen.getVendorPhone();
    setState(() {
      _isLoggedIn = true;
      _vendorPhone = phone;
    });
  }

  Future<void> _logout() async {
    await PhoneAuthScreen.signOut();
    setState(() {
      _isLoggedIn = false;
      _vendorPhone = null;
    });
  }

  Future<void> _replayOnboarding() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const OnboardingScreen(isReplay: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = KhataLocaleController.instance;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return MaterialApp(
          title: controller.t('app_title'),
          debugShowCheckedModeBanner: false,
          locale: controller.locale,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.green,
            brightness: Brightness.light,
            fontFamily: controller.isRtl ? 'sans-serif' : null,
            appBarTheme: AppBarTheme(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.green.shade50,
              foregroundColor: Colors.green.shade900,
            ),
          ),
          builder: (context, child) {
            return Directionality(
              textDirection: controller.textDirection,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: Builder(
            builder: (ctx) {
              if (!_onboardingDone) {
                return OnboardingScreen(
                  onFinish: _onOnboardingFinished,
                  nextScreen: PhoneAuthScreen(
                    repository: widget.repository,
                    onSuccess: _onLoginSuccess,
                  ),
                );
              }
              if (!_isLoggedIn) {
                return PhoneAuthScreen(
                  repository: widget.repository,
                  onSuccess: _onLoginSuccess,
                );
              }
              // Logged in: Show Khata Customers screen with Auth & Language Top Bar
              return Scaffold(
                appBar: AppBar(
                  title: Text(controller.t('app_title')),
                  actions: [
                    // Language picker
                    TextButton.icon(
                      icon: const Icon(Icons.language, size: 20),
                      label: Text(
                        controller.currentLanguage.nativeName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => LanguagePickerSheet.show(ctx),
                    ),
                    // Overflow menu for replay onboarding & logout
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (val) {
                        if (val == 'replay') _replayOnboarding();
                        if (val == 'logout') _logout();
                        if (val == 'lang') LanguagePickerSheet.show(ctx);
                      },
                      itemBuilder: (c) => [
                        if (_vendorPhone != null)
                          PopupMenuItem(
                            enabled: false,
                            child: Text(
                              '${controller.t('logged_in_as')}: $_vendorPhone',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        PopupMenuItem(
                          value: 'lang',
                          child: Row(
                            children: [
                              const Icon(Icons.translate, size: 18),
                              const SizedBox(width: 8),
                              Text(controller.t('select_language')),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'replay',
                          child: Row(
                            children: [
                              const Icon(Icons.help_outline, size: 18),
                              const SizedBox(width: 8),
                              Text(controller.t('tutorial')),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              const Icon(Icons.logout, color: Colors.red, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                controller.t('logout'),
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                body: KhataCustomersScreen(repository: widget.repository),
              );
            },
          ),
        );
      },
    );
  }
}

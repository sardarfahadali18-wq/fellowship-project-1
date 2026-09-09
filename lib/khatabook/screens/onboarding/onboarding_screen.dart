import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localization/khata_localizations.dart';
import '../../widgets/language_picker_sheet.dart';
import '../auth/phone_auth_screen.dart';

/// Skip-able, illustration-heavy onboarding tutorial (3 screens) for Pakistani vendors.
/// (Faizan — Auth & Onboarding module)
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    this.isReplay = false,
    this.nextScreen,
    this.onFinish,
  });

  final bool isReplay;
  final Widget? nextScreen;
  final VoidCallback? onFinish;

  static const String prefCompletedKey = 'khatabook.onboarding_completed';

  /// Helper to check if the vendor has already completed onboarding.
  static Future<bool> isCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(prefCompletedKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Helper to reset onboarding status for re-testing or tutorial replay.
  static Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(prefCompletedKey);
    } catch (_) {}
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(OnboardingScreen.prefCompletedKey, true);
    } catch (_) {}

    if (!mounted) return;

    if (widget.isReplay) {
      Navigator.of(context).pop();
      return;
    }

    if (widget.onFinish != null) {
      widget.onFinish!();
      return;
    }

    final targetScreen = widget.nextScreen ?? const PhoneAuthScreen();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => targetScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = KhataLocaleController.instance;
    final colorScheme = Theme.of(context).colorScheme;

    final pages = [
      _OnboardingData(
        icon: Icons.menu_book_rounded,
        title: controller.t('onboarding_title_1'),
        description: controller.t('onboarding_desc_1'),
        badgeText: '100% Secure',
        accentColor: Colors.teal,
      ),
      _OnboardingData(
        icon: Icons.calculate_rounded,
        title: controller.t('onboarding_title_2'),
        description: controller.t('onboarding_desc_2'),
        badgeText: 'Gave & Got',
        accentColor: Colors.green,
      ),
      _OnboardingData(
        icon: Icons.send_to_mobile_rounded,
        title: controller.t('onboarding_title_3'),
        description: controller.t('onboarding_desc_3'),
        badgeText: 'WhatsApp + SMS',
        accentColor: Colors.indigo,
      ),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isReplay
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        actions: [
          // Quick Language switcher button
          TextButton.icon(
            icon: const Icon(Icons.language, size: 20),
            label: Text(
              controller.currentLanguage.nativeName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => LanguagePickerSheet.show(context),
          ),
          if (!widget.isReplay)
            TextButton(
              onPressed: _finishOnboarding,
              child: Text(
                controller.t('skip'),
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) {
                  final data = pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration / Graphic Container
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: data.accentColor.withAlpha(30),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: data.accentColor.withAlpha(70),
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              data.icon,
                              size: 100,
                              color: data.accentColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: data.accentColor.withAlpha(40),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            data.badgeText,
                            style: TextStyle(
                              color: data.accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Title
                        Text(
                          data.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                        ),
                        const SizedBox(height: 14),
                        // Description
                        Text(
                          data.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Smooth Dots Indicator
                  Row(
                    children: List.generate(
                      pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? colorScheme.primary
                              : colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Next / Get Started Button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finishOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentPage == pages.length - 1
                              ? controller.t('get_started')
                              : controller.t('next'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          controller.isRtl
                              ? Icons.arrow_back_rounded
                              : Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.badgeText,
    required this.accentColor,
  });

  final IconData icon;
  final String title;
  final String description;
  final String badgeText;
  final Color accentColor;
}

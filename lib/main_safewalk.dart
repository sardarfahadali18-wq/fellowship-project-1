import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/safewalk_main_shell.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (e) {
    debugPrint('Firebase not initialized with live keys ($e). Running in test demo mode.');
  }

  runApp(SafeWalkApp(firebaseReady: firebaseReady));
}

class SafeWalkApp extends StatelessWidget {
  const SafeWalkApp({super.key, this.firebaseReady = true});

  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6750A4);
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    return MaterialApp(
      title: 'SafeWalk - Women\'s Safety Companion',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: firebaseReady ? const _SafeWalkAuthGate() : const SafeWalkMainShell(initialUserId: 'demo_user_faizan'),
    );
  }
}

class _SafeWalkAuthGate extends StatelessWidget {
  const _SafeWalkAuthGate();

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading SafeWalk...'),
                ],
              ),
            ),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          return SafeWalkMainShell(initialUserId: user.uid);
        }

        return LoginScreen(
          authService: authService,
        );
      },
    );
  }
}

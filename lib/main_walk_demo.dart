import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/walk_start_screen.dart';
import 'services/fake_location_service.dart';
import 'services/walk_session_service.dart';
import 'services/walk_session_store.dart';

ThemeData walkDemoTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 2,
      backgroundColor: scheme.primary,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final location = FakeLocationService(tick: const Duration(seconds: 2));
  final store = PrefsWalkSessionStore(await SharedPreferences.getInstance());
  WalkSessionService.init(WalkSessionService(location: location, store: store));
  runApp(MaterialApp(
    title: 'SafeWalk Demo',
    debugShowCheckedModeBanner: false,
    theme: walkDemoTheme(),
    home: WalkStartScreen(location: location, store: store),
  ));
}

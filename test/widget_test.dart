// Basic smoke test for the reminders home screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fellowship_project_1/screens/home_screen.dart';
import 'package:fellowship_project_1/services/streak_service.dart';

void main() {
  testWidgets(
    'Home screen shows the reminders list and SOS/Alerts actions',
    (WidgetTester tester) async {
      // Mock SharedPreferences before app startup.
      SharedPreferences.setMockInitialValues({});
      await StreakService.init();

      // Pump the home screen directly: MyApp's root now gates on
      // FirebaseAuth.instance.authStateChanges(), which needs a real
      // Firebase app and isn't relevant to what this screen renders.
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.text('Reminders'), findsOneWidget);
      expect(find.text('Paracetamol - 9:00 AM'), findsOneWidget);
      expect(find.text('Morning Walk - 7:00 AM'), findsOneWidget);
      expect(find.byIcon(Icons.sos), findsOneWidget);
      expect(find.byIcon(Icons.notifications_active_outlined), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    },
  );
}

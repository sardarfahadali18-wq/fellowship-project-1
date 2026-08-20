// Basic smoke test for the app's home screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fellowship_project_1/main.dart';

void main() {
  testWidgets('Home screen shows the reminders list and SOS/Alerts actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Reminders'), findsOneWidget);
    expect(find.byIcon(Icons.sos), findsOneWidget);
    expect(find.byIcon(Icons.notifications_active_outlined), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}

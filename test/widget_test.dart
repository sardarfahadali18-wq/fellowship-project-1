import 'package:flutter_test/flutter_test.dart';
import 'package:fellowship_project_1/main.dart';
import 'package:fellowship_project_1/services/streak_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App loads and displays reminders smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences before app startup
    SharedPreferences.setMockInitialValues({});
    await StreakService.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title "Reminders" is present.
    expect(find.text('Reminders'), findsOneWidget);

    // Verify that default reminders are listed.
    expect(find.text('Paracetamol - 9:00 AM'), findsOneWidget);
    expect(find.text('Morning Walk - 7:00 AM'), findsOneWidget);
  });
}


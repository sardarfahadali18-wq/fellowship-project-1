import 'package:flutter_test/flutter_test.dart';
import 'package:fellowship_project_1/main.dart';
import 'package:fellowship_project_1/services/streak_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App loads and displays caregiver dashboard smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences before app startup
    SharedPreferences.setMockInitialValues({});
    await StreakService.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title "Caregiver Dashboard" is present.
    expect(find.text('Caregiver Dashboard'), findsOneWidget);

    // Verify that patients are listed.
    expect(find.text('Ali Raza'), findsOneWidget);
    expect(find.text('Ayesha Khan'), findsOneWidget);
  });
}

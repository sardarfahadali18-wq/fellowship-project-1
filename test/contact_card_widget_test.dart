import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fellowship_project_1/models/trusted_contact.dart';
import 'package:fellowship_project_1/widgets/contact_card.dart';

void main() {
  group('ContactCard Widget Tests', () {
    testWidgets('renders contact information correctly', (tester) async {
      const contact = TrustedContact(
        id: 'c1',
        name: 'Amna Sheikh',
        phoneNumber: '+92 300 1234567',
        relationship: 'Sister',
        isEmergency: false,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ContactCard(contact: contact),
          ),
        ),
      );

      expect(find.text('Amna Sheikh'), findsOneWidget);
      expect(find.text('+92 300 1234567'), findsOneWidget);
      expect(find.text('Sister'), findsOneWidget);
      expect(find.text('AS'), findsOneWidget); // Initials
      expect(find.text('PRIMARY'), findsNothing);
    });

    testWidgets('shows PRIMARY emergency badge when isEmergency is true', (tester) async {
      const emergencyContact = TrustedContact(
        id: 'c2',
        name: 'Father (Tariq)',
        phoneNumber: '+92 321 7654321',
        relationship: 'Father',
        isEmergency: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ContactCard(contact: emergencyContact),
          ),
        ),
      );

      expect(find.text('Father (Tariq)'), findsOneWidget);
      expect(find.text('PRIMARY'), findsOneWidget);
    });

    testWidgets('calls onCall and onSms callbacks when clicked', (tester) async {
      bool calledPhone = false;
      bool sentSms = false;

      const contact = TrustedContact(
        id: 'c3',
        name: 'Hassan',
        phoneNumber: '03001234567',
        relationship: 'Friend',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactCard(
              contact: contact,
              onCall: () => calledPhone = true,
              onSms: () => sentSms = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Call'));
      await tester.pump();
      expect(calledPhone, true);

      await tester.tap(find.text('Message'));
      await tester.pump();
      expect(sentSms, true);
    });
  });
}

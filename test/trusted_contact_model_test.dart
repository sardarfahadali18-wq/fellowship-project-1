import 'package:flutter_test/flutter_test.dart';
import 'package:fellowship_project_1/models/trusted_contact.dart';

void main() {
  group('TrustedContact Model Tests', () {
    test('creates TrustedContact with correct attributes', () {
      const contact = TrustedContact(
        id: 'contact_01',
        name: 'Fatima Zahra',
        phoneNumber: '+92 300 9876543',
        relationship: 'Mother',
        isEmergency: true,
        notes: 'Primary contact for alerts',
      );

      expect(contact.id, 'contact_01');
      expect(contact.name, 'Fatima Zahra');
      expect(contact.phoneNumber, '+92 300 9876543');
      expect(contact.relationship, 'Mother');
      expect(contact.isEmergency, true);
      expect(contact.initials, 'FZ');
    });

    test('correctly converts to WalkContact for Hamza\'s Walk With Me integration', () {
      const contact = TrustedContact(
        id: 'c_abc',
        name: 'Bilal Ahmed',
        phoneNumber: '+92 321 1122334',
        relationship: 'Friend',
      );

      final walkContact = contact.toWalkContact();
      expect(walkContact.id, 'c_abc');
      expect(walkContact.name, 'Bilal Ahmed');
      expect(walkContact.phoneNumber, '+92 321 1122334');
    });

    test('serializes and deserializes from Map correctly', () {
      final now = DateTime.utc(2026, 8, 26, 10, 0, 0);
      final contact = TrustedContact(
        id: 'doc_123',
        name: 'Sana Malik',
        phoneNumber: '+923005544332',
        relationship: 'Sister',
        email: 'sana@example.com',
        isEmergency: true,
        priorityOrder: 1,
        notes: 'Available on WhatsApp',
        createdAt: now,
        updatedAt: now,
      );

      final map = contact.toMap(forServer: false);
      expect(map[TrustedContact.keyName], 'Sana Malik');
      expect(map[TrustedContact.keyPhoneNumber], '+923005544332');
      expect(map[TrustedContact.keyRelationship], 'Sister');
      expect(map[TrustedContact.keyEmail], 'sana@example.com');
      expect(map[TrustedContact.keyIsEmergency], true);
      expect(map[TrustedContact.keyPriorityOrder], 1);
      expect(map[TrustedContact.keyNotes], 'Available on WhatsApp');

      final deserialized = TrustedContact.fromMap('doc_123', map);
      expect(deserialized.id, 'doc_123');
      expect(deserialized.name, 'Sana Malik');
      expect(deserialized.phoneNumber, '+923005544332');
      expect(deserialized.relationship, 'Sister');
      expect(deserialized.email, 'sana@example.com');
      expect(deserialized.isEmergency, true);
    });

    test('initials formatting handles edge cases', () {
      const c1 = TrustedContact(id: '1', name: 'Zainab', phoneNumber: '123');
      expect(c1.initials, 'Z');

      const c2 = TrustedContact(id: '2', name: 'Dr. John Doe', phoneNumber: '123');
      expect(c2.initials, 'DJ');

      const c3 = TrustedContact(id: '3', name: '', phoneNumber: '123');
      expect(c3.initials, '?');
    });
  });
}

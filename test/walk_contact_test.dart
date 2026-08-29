import 'package:fellowship_project_1/models/walk_contact.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads a well formed contact', () {
    final contact = WalkContact.fromMap('c1', const {
      WalkContact.keyName: 'Ayesha',
      WalkContact.keyPhoneNumber: '+923001234567',
    });

    expect(contact.id, 'c1');
    expect(contact.name, 'Ayesha');
    expect(contact.phoneNumber, '+923001234567');
  });

  test('survives a missing field', () {
    final contact = WalkContact.fromMap('c2', const {});

    expect(contact.id, 'c2');
    expect(contact.name, '');
    expect(contact.phoneNumber, '');
  });

  test('survives a wrong type', () {
    final contact = WalkContact.fromMap('c3', const {
      WalkContact.keyName: 42,
      WalkContact.keyPhoneNumber: ['not', 'a', 'string'],
    });

    expect(contact.name, '');
    expect(contact.phoneNumber, '');
  });
}

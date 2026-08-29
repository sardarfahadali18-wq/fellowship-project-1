import 'package:flutter_test/flutter_test.dart';
import 'package:fellowship_project_1/models/user_profile.dart';

void main() {
  group('UserProfile Model Tests', () {
    test('creates UserProfile with default values', () {
      const profile = UserProfile(
        uid: 'user_123',
        email: 'faizan@example.com',
        displayName: 'Faizan Ali',
      );

      expect(profile.uid, 'user_123');
      expect(profile.email, 'faizan@example.com');
      expect(profile.displayName, 'Faizan Ali');
      expect(profile.phoneNumber, '');
      expect(profile.emergencyNote, '');
      expect(profile.initials, 'FA');
    });

    test('correctly calculates initials for single word or empty names', () {
      const p1 = UserProfile(uid: '1', email: 's@test.com', displayName: 'Sarah');
      expect(p1.initials, 'S');

      const p2 = UserProfile(uid: '2', email: 'test@example.com', displayName: '');
      expect(p2.initials, 'T');

      const p3 = UserProfile(uid: '3', email: '', displayName: '');
      expect(p3.initials, 'U');
    });

    test('serializes to and from Map', () {
      final now = DateTime.utc(2026, 8, 26, 12, 0, 0);
      final profile = UserProfile(
        uid: 'uid_999',
        email: 'test@safewalk.org',
        displayName: 'Ayesha Khan',
        phoneNumber: '+923001234567',
        emergencyNote: 'Asthma, carry inhaler',
        createdAt: now,
        updatedAt: now,
      );

      final map = profile.toMap(forServer: false);
      expect(map[UserProfile.keyUid], 'uid_999');
      expect(map[UserProfile.keyEmail], 'test@safewalk.org');
      expect(map[UserProfile.keyDisplayName], 'Ayesha Khan');
      expect(map[UserProfile.keyPhoneNumber], '+923001234567');
      expect(map[UserProfile.keyEmergencyNote], 'Asthma, carry inhaler');

      final reconstructed = UserProfile.fromMap('uid_999', map);
      expect(reconstructed.uid, profile.uid);
      expect(reconstructed.email, profile.email);
      expect(reconstructed.displayName, profile.displayName);
      expect(reconstructed.phoneNumber, profile.phoneNumber);
      expect(reconstructed.emergencyNote, profile.emergencyNote);
    });

    test('copyWith updates specified fields correctly', () {
      const original = UserProfile(
        uid: 'u1',
        email: 'original@test.com',
        displayName: 'Original Name',
      );

      final updated = original.copyWith(
        displayName: 'New Name',
        phoneNumber: '+923331122334',
      );

      expect(updated.uid, 'u1');
      expect(updated.email, 'original@test.com');
      expect(updated.displayName, 'New Name');
      expect(updated.phoneNumber, '+923331122334');
    });
  });
}

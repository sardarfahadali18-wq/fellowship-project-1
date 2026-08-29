import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a SafeWalk user's profile stored in Firestore `users/{uid}`.
class UserProfile {
  static const keyUid = 'uid';
  static const keyEmail = 'email';
  static const keyDisplayName = 'displayName';
  static const keyPhoneNumber = 'phoneNumber';
  static const keyEmergencyNote = 'emergencyNote';
  static const keyCreatedAt = 'createdAt';
  static const keyUpdatedAt = 'updatedAt';

  final String uid;
  final String email;
  final String displayName;
  final String phoneNumber;
  final String emergencyNote;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.phoneNumber = '',
    this.emergencyNote = '',
    this.createdAt,
    this.updatedAt,
  });

  /// Get user initials (e.g. "Faizan Ali" -> "FA")
  String get initials {
    if (displayName.trim().isEmpty) {
      if (email.isNotEmpty) return email[0].toUpperCase();
      return 'U';
    }
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    DateTime? parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return UserProfile(
      uid: uid,
      email: map[keyEmail] is String ? map[keyEmail] as String : '',
      displayName:
          map[keyDisplayName] is String ? map[keyDisplayName] as String : '',
      phoneNumber:
          map[keyPhoneNumber] is String ? map[keyPhoneNumber] as String : '',
      emergencyNote: map[keyEmergencyNote] is String
          ? map[keyEmergencyNote] as String
          : '',
      createdAt: parseDateTime(map[keyCreatedAt]),
      updatedAt: parseDateTime(map[keyUpdatedAt]),
    );
  }

  Map<String, dynamic> toMap({bool forServer = true}) {
    return {
      keyUid: uid,
      keyEmail: email,
      keyDisplayName: displayName,
      keyPhoneNumber: phoneNumber,
      keyEmergencyNote: emergencyNote,
      if (forServer) ...{
        keyUpdatedAt: FieldValue.serverTimestamp(),
      } else ...{
        if (updatedAt != null) keyUpdatedAt: updatedAt!.toIso8601String(),
      },
      if (createdAt != null)
        keyCreatedAt: forServer
            ? Timestamp.fromDate(createdAt!)
            : createdAt!.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? emergencyNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emergencyNote: emergencyNote ?? this.emergencyNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          displayName == other.displayName &&
          phoneNumber == other.phoneNumber &&
          emergencyNote == other.emergencyNote;

  @override
  int get hashCode =>
      uid.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      phoneNumber.hashCode ^
      emergencyNote.hashCode;

  @override
  String toString() =>
      'UserProfile(uid: $uid, email: $email, displayName: $displayName, phone: $phoneNumber)';
}

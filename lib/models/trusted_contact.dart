import 'package:cloud_firestore/cloud_firestore.dart';
import 'walk_contact.dart';

/// Represents a Trusted Contact for the SafeWalk app.
/// Stored in Firestore at `users/{uid}/trusted_contacts/{contactId}`.
///
/// Designed to be 100% compatible with [WalkContact] used by Walk-With-Me,
/// SOS alerts, and check-in timer features.
class TrustedContact {
  static const keyName = 'name';
  static const keyPhoneNumber = 'phoneNumber';
  static const keyRelationship = 'relationship';
  static const keyEmail = 'email';
  static const keyIsEmergency = 'isEmergency';
  static const keyPriorityOrder = 'priorityOrder';
  static const keyNotes = 'notes';
  static const keyCreatedAt = 'createdAt';
  static const keyUpdatedAt = 'updatedAt';

  final String id;
  final String name;
  final String phoneNumber;
  final String relationship;
  final String email;
  final bool isEmergency;
  final int priorityOrder;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TrustedContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.relationship = 'Other',
    this.email = '',
    this.isEmergency = false,
    this.priorityOrder = 0,
    this.notes = '',
    this.createdAt,
    this.updatedAt,
  });

  /// Contact initials for avatars (e.g., "Sarah Connor" -> "SC")
  String get initials {
    final clean = name.trim();
    if (clean.isEmpty) return '?';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  /// Converts this [TrustedContact] into a lightweight [WalkContact]
  WalkContact toWalkContact() => WalkContact(
        id: id,
        name: name,
        phoneNumber: phoneNumber,
      );

  factory TrustedContact.fromMap(String id, Map<String, dynamic> map) {
    DateTime? parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return TrustedContact(
      id: id,
      name: map[keyName] is String ? map[keyName] as String : '',
      phoneNumber:
          map[keyPhoneNumber] is String ? map[keyPhoneNumber] as String : '',
      relationship:
          map[keyRelationship] is String ? map[keyRelationship] as String : 'Other',
      email: map[keyEmail] is String ? map[keyEmail] as String : '',
      isEmergency: map[keyIsEmergency] is bool ? map[keyIsEmergency] as bool : false,
      priorityOrder: map[keyPriorityOrder] is num
          ? (map[keyPriorityOrder] as num).toInt()
          : 0,
      notes: map[keyNotes] is String ? map[keyNotes] as String : '',
      createdAt: parseDateTime(map[keyCreatedAt]),
      updatedAt: parseDateTime(map[keyUpdatedAt]),
    );
  }

  Map<String, dynamic> toMap({bool forServer = true}) {
    return {
      keyName: name,
      keyPhoneNumber: phoneNumber,
      keyRelationship: relationship,
      keyEmail: email,
      keyIsEmergency: isEmergency,
      keyPriorityOrder: priorityOrder,
      keyNotes: notes,
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

  TrustedContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? relationship,
    String? email,
    bool? isEmergency,
    int? priorityOrder,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrustedContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      email: email ?? this.email,
      isEmergency: isEmergency ?? this.isEmergency,
      priorityOrder: priorityOrder ?? this.priorityOrder,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrustedContact &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          phoneNumber == other.phoneNumber &&
          relationship == other.relationship &&
          email == other.email &&
          isEmergency == other.isEmergency &&
          priorityOrder == other.priorityOrder &&
          notes == other.notes;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      phoneNumber.hashCode ^
      relationship.hashCode ^
      email.hashCode ^
      isEmergency.hashCode ^
      priorityOrder.hashCode ^
      notes.hashCode;

  @override
  String toString() =>
      'TrustedContact(id: $id, name: $name, phone: $phoneNumber, relation: $relationship, emergency: $isEmergency)';
}

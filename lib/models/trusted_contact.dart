class TrustedContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String? fcmToken;

  const TrustedContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.fcmToken,
  });

  factory TrustedContact.fromMap(String id, Map<String, dynamic> map) {
    return TrustedContact(
      id: id,
      name: map['name'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      fcmToken: map['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }
}

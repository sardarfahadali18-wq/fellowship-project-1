class WalkContact {
  static const keyName = 'name';
  static const keyPhoneNumber = 'phoneNumber';

  final String id;
  final String name;
  final String phoneNumber;

  const WalkContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
  });

  factory WalkContact.fromMap(String id, Map<String, dynamic> map) =>
      WalkContact(
        id: id,
        name: map[keyName] is String ? map[keyName] as String : '',
        phoneNumber:
            map[keyPhoneNumber] is String ? map[keyPhoneNumber] as String : '',
      );
}

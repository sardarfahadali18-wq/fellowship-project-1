import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/walk_contact.dart';
import 'trusted_contacts_service.dart';

class TrustedContactReader {
  TrustedContactReader({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    TrustedContactsService? contactsService,
  })  : _injectedDb = firestore,
        _injectedAuth = auth,
        _contactsService = contactsService ?? TrustedContactsService();

  static const usersCollection = 'users';
  static const contactsCollection = 'trusted_contacts';
  static const maxContacts = 50;

  final FirebaseFirestore? _injectedDb;
  final FirebaseAuth? _injectedAuth;
  final TrustedContactsService _contactsService;

  FirebaseFirestore get _db => _injectedDb ?? FirebaseFirestore.instance;
  FirebaseAuth get _auth => _injectedAuth ?? FirebaseAuth.instance;

  Future<List<WalkContact>> forCurrentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const [];

    // 1. Try from TrustedContactsService (MongoDB Atlas + Local Cache)
    try {
      final contacts = await _contactsService.getContacts(uid);
      if (contacts.isNotEmpty) {
        return contacts.map((c) => c.toWalkContact()).toList();
      }
    } catch (_) {}

    // 2. Fallback to Firestore if available
    try {
      final snapshot = await _db
          .collection(usersCollection)
          .doc(uid)
          .collection(contactsCollection)
          .limit(maxContacts)
          .get();
      return snapshot.docs
          .map((d) => WalkContact.fromMap(d.id, d.data()))
          .where((c) => c.name.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }
}

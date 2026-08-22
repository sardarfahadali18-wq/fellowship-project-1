import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/walk_contact.dart';

class TrustedContactReader {
  TrustedContactReader({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _injectedDb = firestore,
        _injectedAuth = auth;

  static const usersCollection = 'users';
  static const contactsCollection = 'trusted_contacts';
  static const maxContacts = 50;

  final FirebaseFirestore? _injectedDb;
  final FirebaseAuth? _injectedAuth;

  FirebaseFirestore get _db => _injectedDb ?? FirebaseFirestore.instance;

  FirebaseAuth get _auth => _injectedAuth ?? FirebaseAuth.instance;

  Future<List<WalkContact>> forCurrentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const [];
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
  }
}

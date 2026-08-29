import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trusted_contact.dart';
import 'mongodb_service.dart';

/// Service responsible for managing Trusted Contacts in SafeWalk.
///
/// Supports MongoDB Atlas backend, local SharedPreferences persistence,
/// and Firestore fallback.
class TrustedContactsService {
  TrustedContactsService({
    MongoDbService? mongoDb,
    FirebaseFirestore? firestore,
    SharedPreferences? prefs,
  })  : _mongoDb = mongoDb ?? MongoDbService(),
        _injectedDb = firestore,
        _injectedPrefs = prefs;

  static const usersCollection = 'users';
  static const contactsCollection = 'trusted_contacts';
  static const maxContacts = 50;
  static const prefCachePrefix = 'safewalk_cached_contacts_';

  final MongoDbService _mongoDb;
  final FirebaseFirestore? _injectedDb;
  final SharedPreferences? _injectedPrefs;

  final _streamControllers = <String, StreamController<List<TrustedContact>>>{};

  StreamController<List<TrustedContact>> _getController(String uid) {
    return _streamControllers.putIfAbsent(
      uid,
      () => StreamController<List<TrustedContact>>.broadcast(),
    );
  }

  /// Streams trusted contacts in real time for [uid].
  Stream<List<TrustedContact>> streamContacts(String uid) {
    if (uid.isEmpty) return Stream.value(const []);

    final controller = _getController(uid);

    // 1. Emit cached contacts immediately for zero-delay startup
    getCachedContacts(uid).then((cached) {
      if (!controller.isClosed && cached.isNotEmpty) {
        controller.add(cached);
      }
    });

    // 2. Fetch fresh data from MongoDB Atlas / Firestore
    _refreshContacts(uid);

    return controller.stream;
  }

  Future<void> _refreshContacts(String uid) async {
    final contacts = await getContacts(uid);
    final controller = _getController(uid);
    if (!controller.isClosed) {
      controller.add(contacts);
    }
  }

  /// Fetches the list of trusted contacts for [uid] from MongoDB Atlas / Firestore / Cache.
  Future<List<TrustedContact>> getContacts(String uid) async {
    if (uid.isEmpty) return const [];

    List<TrustedContact> contacts = [];

    // Try MongoDB Atlas first
    if (_mongoDb.isConfigured) {
      try {
        contacts = await _mongoDb.getContacts(uid);
      } catch (e) {
        debugPrint('[TrustedContacts] MongoDB fetch error: $e');
      }
    }

    // If empty or MongoDB not configured, try Firestore if available
    if (contacts.isEmpty) {
      try {
        final db = _injectedDb ?? FirebaseFirestore.instance;
        final snapshot = await db
            .collection(usersCollection)
            .doc(uid)
            .collection(contactsCollection)
            .limit(maxContacts)
            .get();

        contacts = snapshot.docs
            .map((doc) => TrustedContact.fromMap(doc.id, doc.data()))
            .where((c) => c.name.trim().isNotEmpty)
            .toList();
      } catch (_) {}
    }

    // If still empty or offline, fallback to local cache
    if (contacts.isEmpty) {
      contacts = await getCachedContacts(uid);
    } else {
      // Sort and update cache
      contacts.sort((a, b) {
        if (a.isEmergency != b.isEmergency) {
          return a.isEmergency ? -1 : 1;
        }
        if (a.priorityOrder != b.priorityOrder) {
          return a.priorityOrder.compareTo(b.priorityOrder);
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      await _cacheContacts(uid, contacts);
    }

    return contacts;
  }

  /// Get only emergency contacts for SOS and check-in alerts.
  Future<List<TrustedContact>> getEmergencyContacts(String uid) async {
    final all = await getContacts(uid);
    final emergencyOnly = all.where((c) => c.isEmergency).toList();
    return emergencyOnly.isNotEmpty ? emergencyOnly : all;
  }

  /// Add a new trusted contact for user [uid].
  Future<String> addContact(String uid, TrustedContact contact) async {
    if (uid.isEmpty) {
      throw StateError('Cannot add contact: user ID is empty.');
    }
    if (contact.name.trim().isEmpty) {
      throw ArgumentError('Contact name cannot be empty.');
    }
    if (contact.phoneNumber.trim().isEmpty) {
      throw ArgumentError('Contact phone number cannot be empty.');
    }

    final newId = contact.id.isNotEmpty
        ? contact.id
        : 'contact_${DateTime.now().millisecondsSinceEpoch}';
    final toSave = contact.copyWith(
      id: newId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save to MongoDB Atlas
    if (_mongoDb.isConfigured) {
      await _mongoDb.addContact(uid, toSave);
    }

    // Save to Firestore if available
    try {
      final db = _injectedDb ?? FirebaseFirestore.instance;
      await db
          .collection(usersCollection)
          .doc(uid)
          .collection(contactsCollection)
          .doc(newId)
          .set(toSave.toMap(forServer: true));
    } catch (_) {}

    // Save to local cache immediately
    final existing = await getCachedContacts(uid);
    existing.removeWhere((c) => c.id == newId);
    existing.add(toSave);
    await _cacheContacts(uid, existing);

    // Broadcast change
    _notify(uid, existing);
    return newId;
  }

  /// Update an existing trusted contact.
  Future<void> updateContact(String uid, TrustedContact contact) async {
    if (uid.isEmpty || contact.id.isEmpty) {
      throw StateError('Cannot update contact: missing user ID or contact ID.');
    }

    final updated = contact.copyWith(updatedAt: DateTime.now());

    // Update MongoDB Atlas
    if (_mongoDb.isConfigured) {
      await _mongoDb.updateContact(uid, updated);
    }

    // Update Firestore if available
    try {
      final db = _injectedDb ?? FirebaseFirestore.instance;
      await db
          .collection(usersCollection)
          .doc(uid)
          .collection(contactsCollection)
          .doc(updated.id)
          .set(updated.toMap(forServer: true), SetOptions(merge: true));
    } catch (_) {}

    // Update local cache
    final existing = await getCachedContacts(uid);
    final idx = existing.indexWhere((c) => c.id == updated.id);
    if (idx != -1) {
      existing[idx] = updated;
    } else {
      existing.add(updated);
    }
    await _cacheContacts(uid, existing);
    _notify(uid, existing);
  }

  /// Delete a trusted contact by ID.
  Future<void> deleteContact(String uid, String contactId) async {
    if (uid.isEmpty || contactId.isEmpty) {
      throw StateError('Cannot delete contact: missing user ID or contact ID.');
    }

    // Delete from MongoDB Atlas
    if (_mongoDb.isConfigured) {
      await _mongoDb.deleteContact(uid, contactId);
    }

    // Delete from Firestore if available
    try {
      final db = _injectedDb ?? FirebaseFirestore.instance;
      await db
          .collection(usersCollection)
          .doc(uid)
          .collection(contactsCollection)
          .doc(contactId)
          .delete();
    } catch (_) {}

    // Update local cache
    final existing = await getCachedContacts(uid);
    existing.removeWhere((c) => c.id == contactId);
    await _cacheContacts(uid, existing);
    _notify(uid, existing);
  }

  /// Toggle emergency alert status for a contact.
  Future<void> toggleEmergencyStatus(
    String uid,
    String contactId,
    bool isEmergency,
  ) async {
    final contacts = await getCachedContacts(uid);
    final idx = contacts.indexWhere((c) => c.id == contactId);
    if (idx != -1) {
      final updated = contacts[idx].copyWith(isEmergency: isEmergency);
      await updateContact(uid, updated);
    }
  }

  /// Sets a contact as the primary emergency contact.
  Future<void> setPrimaryEmergencyContact(String uid, String contactId) async {
    final contacts = await getCachedContacts(uid);
    final idx = contacts.indexWhere((c) => c.id == contactId);
    if (idx != -1) {
      final updated = contacts[idx].copyWith(
        isEmergency: true,
        priorityOrder: 0,
      );
      await updateContact(uid, updated);
    }
  }

  // ==================== LOCAL CACHE & BROADCAST ====================

  void _notify(String uid, List<TrustedContact> contacts) {
    contacts.sort((a, b) {
      if (a.isEmergency != b.isEmergency) {
        return a.isEmergency ? -1 : 1;
      }
      if (a.priorityOrder != b.priorityOrder) {
        return a.priorityOrder.compareTo(b.priorityOrder);
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    final controller = _getController(uid);
    if (!controller.isClosed) {
      controller.add(contacts);
    }
  }

  Future<void> _cacheContacts(String uid, List<TrustedContact> contacts) async {
    try {
      final prefs = _injectedPrefs ?? await SharedPreferences.getInstance();
      final key = '$prefCachePrefix$uid';
      final jsonList = contacts.map((c) => {
            'id': c.id,
            'name': c.name,
            'phoneNumber': c.phoneNumber,
            'relationship': c.relationship,
            'email': c.email,
            'isEmergency': c.isEmergency,
            'priorityOrder': c.priorityOrder,
            'notes': c.notes,
            'createdAt': c.createdAt?.toIso8601String(),
            'updatedAt': c.updatedAt?.toIso8601String(),
          }).toList();
      await prefs.setString(key, jsonEncode(jsonList));
    } catch (_) {}
  }

  /// Retrieves contacts from offline local storage.
  Future<List<TrustedContact>> getCachedContacts(String uid) async {
    try {
      final prefs = _injectedPrefs ?? await SharedPreferences.getInstance();
      final key = '$prefCachePrefix$uid';
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) return const [];
      final list = jsonDecode(raw) as List<dynamic>;
      final contacts = list
          .map((item) => TrustedContact.fromMap(
                item['id'] as String? ?? '',
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();

      contacts.sort((a, b) {
        if (a.isEmergency != b.isEmergency) {
          return a.isEmergency ? -1 : 1;
        }
        if (a.priorityOrder != b.priorityOrder) {
          return a.priorityOrder.compareTo(b.priorityOrder);
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return contacts;
    } catch (_) {
      return const [];
    }
  }
}

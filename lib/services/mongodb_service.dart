import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../config/app_credentials.dart';
import '../models/trusted_contact.dart';
import '../models/user_profile.dart';

/// Direct MongoDB Atlas database connection and service for SafeWalk.
///
/// Connects securely to MongoDB Atlas cluster via `mongodb+srv://` protocol.
class MongoDbService {
  MongoDbService({String? uri})
      : _uri = uri ?? AppCredentials.mongoDbUri;

  final String _uri;
  Db? _db;
  bool _isConnecting = false;

  static const collectionUsers = 'users';
  static const collectionContacts = 'trusted_contacts';
  static const collectionWalkSessions = 'walk_sessions';

  bool get isConfigured => AppCredentials.isMongoDbConfigured;

  /// Ensures active connection to MongoDB Atlas.
  Future<Db?> _getDatabase() async {
    if (!isConfigured) return null;

    if (_db != null && _db!.state == State.open) {
      return _db;
    }

    if (_isConnecting) {
      while (_isConnecting) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (_db != null && _db!.state == State.open) return _db;
    }

    _isConnecting = true;
    try {
      _db = await Db.create(_uri);
      await _db!.open();
      debugPrint('[MongoDB Atlas] Connected successfully to ${_db?.databaseName}');
      return _db;
    } catch (e) {
      debugPrint('[MongoDB Atlas Connection Error] $e');
      _db = null;
      return null;
    } finally {
      _isConnecting = false;
    }
  }

  // ==================== USERS COLLECTION ====================

  /// Save or update user profile in MongoDB Atlas `users` collection.
  Future<bool> saveUserProfile(UserProfile profile) async {
    try {
      final db = await _getDatabase();
      if (db == null) return false;

      final coll = db.collection(collectionUsers);
      await coll.modernUpdate(
        where.eq('uid', profile.uid),
        modify
          ..set('uid', profile.uid)
          ..set('email', profile.email)
          ..set('displayName', profile.displayName)
          ..set('phoneNumber', profile.phoneNumber)
          ..set('emergencyNote', profile.emergencyNote)
          ..set('updatedAt', DateTime.now().toIso8601String())
          ..setOnInsert(
            'createdAt',
            profile.createdAt?.toIso8601String() ??
                DateTime.now().toIso8601String(),
          ),
        upsert: true,
      );
      debugPrint('[MongoDB Atlas] User profile saved for ${profile.uid}');
      return true;
    } catch (e) {
      debugPrint('[MongoDB Atlas saveUserProfile error] $e');
      return false;
    }
  }

  /// Get user profile from MongoDB Atlas `users` collection.
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final db = await _getDatabase();
      if (db == null) return null;

      final coll = db.collection(collectionUsers);
      final doc = await coll.findOne(where.eq('uid', uid));
      if (doc != null) {
        return UserProfile.fromMap(uid, Map<String, dynamic>.from(doc));
      }
      return null;
    } catch (e) {
      debugPrint('[MongoDB Atlas getUserProfile error] $e');
      return null;
    }
  }

  // ==================== TRUSTED CONTACTS COLLECTION ====================

  /// Fetch all trusted contacts for [uid] from MongoDB Atlas `trusted_contacts` collection.
  Future<List<TrustedContact>> getContacts(String uid) async {
    try {
      final db = await _getDatabase();
      if (db == null) return const [];

      final coll = db.collection(collectionContacts);
      final cursor = coll.find(
        where
            .eq('userId', uid)
            .sortBy('isEmergency', descending: true)
            .sortBy('priorityOrder', descending: false)
            .sortBy('name', descending: false),
      );

      final list = await cursor.toList();
      return list.map((doc) {
        final map = Map<String, dynamic>.from(doc);
        final id = map['_id']?.toString() ?? map['id']?.toString() ?? '';
        return TrustedContact.fromMap(id, map);
      }).toList();
    } catch (e) {
      debugPrint('[MongoDB Atlas getContacts error] $e');
      return const [];
    }
  }

  /// Add a new trusted contact in MongoDB Atlas.
  Future<String?> addContact(String uid, TrustedContact contact) async {
    try {
      final db = await _getDatabase();
      if (db == null) return null;

      final coll = db.collection(collectionContacts);
      final docId = contact.id.isNotEmpty
          ? contact.id
          : 'tc_${DateTime.now().millisecondsSinceEpoch}';

      final data = {
        '_id': docId,
        'userId': uid,
        'name': contact.name,
        'phoneNumber': contact.phoneNumber,
        'relationship': contact.relationship,
        'email': contact.email,
        'isEmergency': contact.isEmergency,
        'priorityOrder': contact.priorityOrder,
        'notes': contact.notes,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await coll.insertOne(data);
      debugPrint('[MongoDB Atlas] Added trusted contact $docId for user $uid');
      return docId;
    } catch (e) {
      debugPrint('[MongoDB Atlas addContact error] $e');
      return null;
    }
  }

  /// Update an existing trusted contact in MongoDB Atlas.
  Future<bool> updateContact(String uid, TrustedContact contact) async {
    try {
      final db = await _getDatabase();
      if (db == null) return false;

      final coll = db.collection(collectionContacts);
      await coll.modernUpdate(
        where.eq('_id', contact.id).eq('userId', uid),
        modify
          ..set('name', contact.name)
          ..set('phoneNumber', contact.phoneNumber)
          ..set('relationship', contact.relationship)
          ..set('email', contact.email)
          ..set('isEmergency', contact.isEmergency)
          ..set('priorityOrder', contact.priorityOrder)
          ..set('notes', contact.notes)
          ..set('updatedAt', DateTime.now().toIso8601String()),
      );
      debugPrint('[MongoDB Atlas] Updated contact ${contact.id}');
      return true;
    } catch (e) {
      debugPrint('[MongoDB Atlas updateContact error] $e');
      return false;
    }
  }

  /// Delete a trusted contact in MongoDB Atlas.
  Future<bool> deleteContact(String uid, String contactId) async {
    try {
      final db = await _getDatabase();
      if (db == null) return false;

      final coll = db.collection(collectionContacts);
      await coll.deleteOne(where.eq('_id', contactId).eq('userId', uid));
      debugPrint('[MongoDB Atlas] Deleted contact $contactId');
      return true;
    } catch (e) {
      debugPrint('[MongoDB Atlas deleteContact error] $e');
      return false;
    }
  }

  /// Close database connection if needed.
  Future<void> close() async {
    if (_db != null && _db!.state == State.open) {
      await _db!.close();
      _db = null;
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import 'mongodb_service.dart';

/// Service responsible for managing user authentication (Firebase Auth)
/// and user profile storage (MongoDB Atlas + Local Persistence).
class AuthService {
  AuthService({
    FirebaseAuth? auth,
    MongoDbService? mongoDb,
    FirebaseFirestore? firestore,
    SharedPreferences? prefs,
  })  : _injectedAuth = auth,
        _mongoDb = mongoDb ?? MongoDbService(),
        _injectedDb = firestore,
        _injectedPrefs = prefs;

  static const prefProfilePrefix = 'safewalk_cached_profile_';

  final FirebaseAuth? _injectedAuth;
  final MongoDbService _mongoDb;
  final FirebaseFirestore? _injectedDb;
  final SharedPreferences? _injectedPrefs;

  final _profileControllers = <String, StreamController<UserProfile?>>{};

  FirebaseAuth get _auth => _injectedAuth ?? FirebaseAuth.instance;

  StreamController<UserProfile?> _getController(String uid) {
    return _profileControllers.putIfAbsent(
      uid,
      () => StreamController<UserProfile?>.broadcast(),
    );
  }

  /// Stream of user authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently logged in user (or null if not logged in)
  User? get currentUser => _auth.currentUser;

  /// Get current user ID (or null)
  String? get currentUserId => _auth.currentUser?.uid;

  /// Sign up a new user with Email, Password, Full Name, and optional Phone Number.
  /// Saves user profile directly into MongoDB Atlas and local storage.
  Future<String?> signUp({
    required String email,
    required String password,
    String displayName = '',
    String phoneNumber = '',
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = cred.user;
      if (user != null) {
        if (displayName.trim().isNotEmpty) {
          try {
            await user.updateDisplayName(displayName.trim());
          } catch (_) {}
        }

        final profile = UserProfile(
          uid: user.uid,
          email: user.email ?? email.trim(),
          displayName: displayName.trim().isNotEmpty
              ? displayName.trim()
              : (user.displayName ?? ''),
          phoneNumber: phoneNumber.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Save to MongoDB Atlas
        if (_mongoDb.isConfigured) {
          await _mongoDb.saveUserProfile(profile);
        }

        // Save to local cache
        await _cacheProfile(profile);
        _notify(profile);
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return _humanizeAuthError(e);
    } catch (e) {
      return 'Sign up failed: ${e.toString()}';
    }
  }

  /// Sign in an existing user with Email and Password.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = cred.user;
      if (user != null) {
        // Fetch or initialize profile
        final profile = await getUserProfile(user.uid);
        if (profile != null) {
          _notify(profile);
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _humanizeAuthError(e);
    } catch (e) {
      return 'Sign in failed: ${e.toString()}';
    }
  }

  /// Send password reset email.
  Future<String?> sendPasswordResetEmail(String email) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return 'Please enter a valid email address.';
    }

    try {
      await _auth.sendPasswordResetEmail(email: cleanEmail);
      return null;
    } on FirebaseAuthException catch (e) {
      return _humanizeAuthError(e);
    } catch (e) {
      return 'Password reset failed: ${e.toString()}';
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Fetch the [UserProfile] for a given user ID from MongoDB Atlas / Cache / Auth.
  Future<UserProfile?> getUserProfile(String uid) async {
    // 1. Try MongoDB Atlas
    if (_mongoDb.isConfigured) {
      try {
        final profile = await _mongoDb.getUserProfile(uid);
        if (profile != null) {
          await _cacheProfile(profile);
          return profile;
        }
      } catch (e) {
        debugPrint('[AuthService] MongoDB fetch profile error: $e');
      }
    }

    // 2. Try Local Cache
    final cached = await _getCachedProfile(uid);
    if (cached != null) return cached;

    // 3. Fallback to Firebase Auth user metadata
    final authUser = _auth.currentUser;
    if (authUser != null && authUser.uid == uid) {
      final fallbackProfile = UserProfile(
        uid: uid,
        email: authUser.email ?? '',
        displayName: authUser.displayName ?? '',
        phoneNumber: authUser.phoneNumber ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _cacheProfile(fallbackProfile);
      return fallbackProfile;
    }

    return null;
  }

  /// Stream of [UserProfile] updates for real-time profile syncing.
  Stream<UserProfile?> userProfileStream(String uid) {
    final controller = _getController(uid);

    // Emit cached profile immediately
    _getCachedProfile(uid).then((cached) {
      if (!controller.isClosed && cached != null) {
        controller.add(cached);
      }
    });

    // Refresh in background
    getUserProfile(uid).then((fresh) {
      if (!controller.isClosed && fresh != null) {
        controller.add(fresh);
      }
    });

    return controller.stream;
  }

  /// Update the current user's profile in MongoDB Atlas and local storage.
  Future<String?> updateUserProfile(UserProfile profile) async {
    try {
      final updated = profile.copyWith(updatedAt: DateTime.now());

      // Save to MongoDB Atlas
      if (_mongoDb.isConfigured) {
        await _mongoDb.saveUserProfile(updated);
      }

      // Update Firebase Auth display name
      final authUser = _auth.currentUser;
      if (authUser != null &&
          authUser.uid == updated.uid &&
          authUser.displayName != updated.displayName) {
        try {
          await authUser.updateDisplayName(updated.displayName);
        } catch (_) {}
      }

      // Update local cache & notify
      await _cacheProfile(updated);
      _notify(updated);
      return null;
    } catch (e) {
      return 'Failed to update profile: ${e.toString()}';
    }
  }

  // ==================== LOCAL CACHE & NOTIFICATION ====================

  void _notify(UserProfile profile) {
    final controller = _getController(profile.uid);
    if (!controller.isClosed) {
      controller.add(profile);
    }
  }

  Future<void> _cacheProfile(UserProfile profile) async {
    try {
      final prefs = _injectedPrefs ?? await SharedPreferences.getInstance();
      final key = '$prefProfilePrefix${profile.uid}';
      await prefs.setString(key, jsonEncode(profile.toMap(forServer: false)));
    } catch (_) {}
  }

  Future<UserProfile?> _getCachedProfile(String uid) async {
    try {
      final prefs = _injectedPrefs ?? await SharedPreferences.getInstance();
      final key = '$prefProfilePrefix$uid';
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserProfile.fromMap(uid, map);
    } catch (_) {
      return null;
    }
  }

  String _humanizeAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again in a few minutes.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet connection.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}

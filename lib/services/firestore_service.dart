import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:klaro/models/app_user.dart';
import 'package:klaro/models/user_profile.dart';

/// ============================================================
/// Firestore Service
/// ============================================================
/// Manages user profile data in Cloud Firestore.
/// Collection: users/{uid}

class FirestoreService {
  FirebaseFirestore? get _firestore {
    try {
      if (Firebase.apps.isEmpty) return null;
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Create user profile after registration
  Future<void> createUserProfile(AppUser user) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore not available, skipping profile creation');
      return;
    }

    try {
      final profile = UserProfile(
        uid: user.uid,
        email: user.email,
        role: user.role == UserRole.teacher ? 'teacher' : 'student',
        isFirstLogin: true,
        preferredLanguage: 'en',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await firestore.collection('users').doc(user.uid).set(profile.toMap());
      debugPrint('Created Firestore profile for ${user.email}');
    } on FirebaseException catch (e) {
      debugPrint('Firestore error creating profile: ${e.code} - ${e.message}');
      throw FirestoreErrorHandler.getErrorMessage(e);
    } catch (e) {
      debugPrint('Error creating profile: $e');
      throw 'Failed to create user profile. Please try again.';
    }
  }

  /// Get user profile by UID
  Future<UserProfile?> getUserProfile(String uid) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore not available');
      return null;
    }

    try {
      final doc = await firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        debugPrint('User profile not found for uid: $uid');
        return null;
      }

      return UserProfile.fromMap(doc.data()!);
    } on FirebaseException catch (e) {
      debugPrint('Firestore error getting profile: ${e.code} - ${e.message}');
      throw FirestoreErrorHandler.getErrorMessage(e);
    } catch (e) {
      debugPrint('Error getting profile: $e');
      throw 'Failed to load user profile. Please try again.';
    }
  }

  /// Update user profile fields
  Future<void> updateUserProfile(
      String uid, Map<String, dynamic> updates) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore not available, skipping profile update');
      return;
    }

    try {
      updates['updatedAt'] = DateTime.now().toIso8601String();
      await firestore.collection('users').doc(uid).update(updates);
      debugPrint('Updated Firestore profile for uid: $uid');
    } on FirebaseException catch (e) {
      debugPrint('Firestore error updating profile: ${e.code} - ${e.message}');
      throw FirestoreErrorHandler.getErrorMessage(e);
    } catch (e) {
      debugPrint('Error updating profile: $e');
      throw 'Failed to update user profile. Please try again.';
    }
  }

  /// Update language preference
  Future<void> updateLanguagePreference(
      String uid, String languageCode) async {
    await updateUserProfile(uid, {'preferredLanguage': languageCode});
  }

  /// Mark first login as complete
  Future<void> completeFirstLogin(String uid) async {
    await updateUserProfile(uid, {'isFirstLogin': false});
  }
}

/// Firestore Error Handler
class FirestoreErrorHandler {
  static String getErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Access denied. Please sign in again.';
      case 'not-found':
        return 'User profile not found. Please contact support.';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again.';
      case 'deadline-exceeded':
        return 'Request timed out. Please check your connection.';
      case 'already-exists':
        return 'User profile already exists.';
      default:
        return 'An error occurred: ${e.message ?? "Unknown error"}';
    }
  }
}

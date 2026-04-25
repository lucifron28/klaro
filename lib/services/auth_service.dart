import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:klaro/models/app_user.dart';
import 'package:klaro/services/firestore_service.dart';
import 'package:klaro/services/local_storage_service.dart';
import 'package:klaro/utils/constants.dart';

/// ============================================================
/// Auth Service
/// ============================================================
/// Handles Firebase Authentication and user session management.
/// Enhanced with Firestore integration for user profiles.

class AuthService {
  final LocalStorageService _localStorage = LocalStorageService();
  final FirestoreService _firestoreService = FirestoreService();

  FirebaseAuth? get _auth {
    try {
      if (Firebase.apps.isEmpty) return null;
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  /// Get the currently signed-in user
  User? get currentFirebaseUser => _auth?.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges =>
      _auth?.authStateChanges() ?? const Stream<User?>.empty();

  /// Sign in with email and password (enhanced with Firestore)
  Future<AppUser?> signIn(String email, String password) async {
    // Check for demo user first
    final demoUser = _demoUserForCredentials(email, password);
    if (demoUser != null) {
      await _localStorage.saveUser(demoUser);
      return demoUser;
    }

    final auth = _auth;
    if (auth == null) {
      throw 'Firebase is not configured for this build. Use the quick demo login buttons or add android/app/google-services.json.';
    }

    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Fetch user profile from Firestore
        final profile =
            await _firestoreService.getUserProfile(credential.user!.uid);

        if (profile != null) {
          // Create AppUser from Firestore profile
          final appUser = AppUser(
            uid: profile.uid,
            name: _getNameFromEmail(profile.email),
            email: profile.email,
            role: profile.role == 'teacher'
                ? UserRole.teacher
                : UserRole.student,
            isFirstLogin: profile.isFirstLogin,
            preferredLanguage: profile.preferredLanguage,
            createdAt: profile.createdAt,
          );

          // Save user locally
          await _localStorage.saveUser(appUser);
          return appUser;
        } else {
          // Profile doesn't exist, create one
          final role = email.contains('teacher')
              ? UserRole.teacher
              : UserRole.student;

          final appUser = AppUser(
            uid: credential.user!.uid,
            name: _getNameFromEmail(email),
            email: email,
            role: role,
            isFirstLogin: true,
            preferredLanguage: 'en',
            createdAt: DateTime.now(),
          );

          await _firestoreService.createUserProfile(appUser);
          await _localStorage.saveUser(appUser);
          return appUser;
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Create a new account (for setup only)
  Future<AppUser?> signUp(
      String email, String password, String name, UserRole role) async {
    final auth = _auth;
    if (auth == null) {
      throw 'Firebase is not configured for this build.';
    }

    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final appUser = AppUser(
          uid: credential.user!.uid,
          name: name,
          email: email,
          role: role,
          isFirstLogin: true,
          preferredLanguage: 'en',
          createdAt: DateTime.now(),
        );

        // Create Firestore profile
        await _firestoreService.createUserProfile(appUser);

        // Save locally
        await _localStorage.saveUser(appUser);
        return appUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth?.signOut();
    await _localStorage.clearUser();
  }

  /// Get the current AppUser from local storage
  Future<AppUser?> getCurrentUser() async {
    return _localStorage.getUser();
  }

  /// Check if user needs onboarding
  Future<bool> needsOnboarding(String uid) async {
    try {
      final profile = await _firestoreService.getUserProfile(uid);
      return profile?.isFirstLogin ?? true;
    } catch (e) {
      debugPrint('Error checking onboarding status: $e');
      return true; // Default to showing onboarding if error
    }
  }

  /// Extract a display name from email (hackathon shortcut)
  String _getNameFromEmail(String email) {
    final localPart = email.split('@').first;
    // Capitalize first letter
    if (localPart.isEmpty) return 'User';
    return localPart[0].toUpperCase() + localPart.substring(1);
  }

  AppUser? _demoUserForCredentials(String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail == AppConstants.testStudentEmail &&
        password == AppConstants.testStudentPassword) {
      return AppUser(
        uid: 'demo-student',
        name: 'Student',
        email: AppConstants.testStudentEmail,
        role: UserRole.student,
        isFirstLogin: true, // DEVELOPMENT: Show language selector
        preferredLanguage: 'en',
      );
    }

    if (normalizedEmail == AppConstants.testTeacherEmail &&
        password == AppConstants.testTeacherPassword) {
      return AppUser(
        uid: 'demo-teacher',
        name: 'Teacher',
        email: AppConstants.testTeacherEmail,
        role: UserRole.teacher,
        isFirstLogin: true, // DEVELOPMENT: Show language selector
        preferredLanguage: 'en',
      );
    }

    return null;
  }

  /// Convert Firebase auth errors to user-friendly messages
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email. Please check your email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. Please contact support.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      // Removed 'too-many-requests' to allow development testing
      default:
        return 'Login failed: ${e.message ?? "Unknown error"}. Please try again.';
    }
  }
}

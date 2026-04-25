import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:klaro/models/app_user.dart';
import 'package:klaro/services/local_storage_service.dart';
import 'package:klaro/utils/constants.dart';

/// ============================================================
/// Auth Service
/// ============================================================
/// Handles Firebase Authentication and user session management.
/// For the hackathon demo, we use hardcoded test accounts.

class AuthService {
  final LocalStorageService _localStorage = LocalStorageService();

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

  /// Sign in with email and password
  Future<AppUser?> signIn(String email, String password) async {
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
        // Determine role based on email (hackathon shortcut)
        final role =
            email.contains('teacher') ? UserRole.teacher : UserRole.student;

        final appUser = AppUser(
          uid: credential.user!.uid,
          name: _getNameFromEmail(email),
          email: email,
          role: role,
        );

        // Save user locally
        await _localStorage.saveUser(appUser);
        return appUser;
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
        );

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
      );
    }

    if (normalizedEmail == AppConstants.testTeacherEmail &&
        password == AppConstants.testTeacherPassword) {
      return AppUser(
        uid: 'demo-teacher',
        name: 'Teacher',
        email: AppConstants.testTeacherEmail,
        role: UserRole.teacher,
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
      default:
        return 'Login failed. Please try again.';
    }
  }
}

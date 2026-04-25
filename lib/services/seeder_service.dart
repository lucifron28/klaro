import 'package:flutter/foundation.dart';
import 'package:klaro/models/app_user.dart';
import 'package:klaro/services/auth_service.dart';

/// ============================================================
/// Seeder Service
/// ============================================================
/// Automatically creates test accounts in Firebase for development.
/// Test accounts:
/// - teacher@test.com / password123
/// - student@test.com / password123

class SeederService {
  final AuthService _authService = AuthService();

  /// Seed all test accounts
  Future<void> seedTestAccounts() async {
    debugPrint('🌱 Starting test account seeding...');

    await _createTestAccount(
      'teacher@test.com',
      'password123',
      'Teacher',
      UserRole.teacher,
    );

    await _createTestAccount(
      'student@test.com',
      'password123',
      'Student',
      UserRole.student,
    );

    debugPrint('🌱 Test account seeding completed');
  }

  /// Create individual test account
  Future<void> _createTestAccount(
    String email,
    String password,
    String name,
    UserRole role,
  ) async {
    try {
      // Check if account already exists by attempting to sign in
      final exists = await _accountExists(email, password);

      if (exists) {
        _logSeedingResult(email, true, 'Account already exists, skipped');
        return;
      }

      // Create the account
      final user = await _authService.signUp(email, password, name, role);

      if (user != null) {
        _logSeedingResult(email, true, null);
        // Sign out after creating the account
        await _authService.signOut();
      } else {
        _logSeedingResult(email, false, 'Failed to create account');
      }
    } catch (e) {
      _logSeedingResult(email, false, e.toString());
    }
  }

  /// Check if account already exists
  Future<bool> _accountExists(String email, String password) async {
    try {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        // Account exists, sign out
        await _authService.signOut();
        return true;
      }
      return false;
    } catch (e) {
      // If sign-in fails, account doesn't exist or password is wrong
      // For seeding purposes, we'll assume it doesn't exist
      return false;
    }
  }

  /// Log seeding results
  void _logSeedingResult(String email, bool success, String? error) {
    if (success) {
      if (error != null) {
        debugPrint('✅ $email: $error');
      } else {
        debugPrint('✅ $email: Created successfully');
      }
    } else {
      debugPrint('❌ $email: Failed - ${error ?? "Unknown error"}');
    }
  }
}

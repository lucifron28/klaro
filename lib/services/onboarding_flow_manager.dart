import 'package:flutter/material.dart';
import 'package:klaro/models/app_user.dart';
import 'package:klaro/screens/language_selector_screen.dart';
import 'package:klaro/screens/student_home_screen.dart';
import 'package:klaro/screens/teacher_dashboard_screen.dart';
import 'package:klaro/services/firestore_service.dart';
import 'package:klaro/services/local_storage_service.dart';

/// ============================================================
/// Onboarding Flow Manager
/// ============================================================
/// Orchestrates the first-time user experience.
/// Checks if user needs onboarding and navigates accordingly.

class OnboardingFlowManager {
  final FirestoreService _firestoreService = FirestoreService();
  final LocalStorageService _localStorage = LocalStorageService();

  /// Check if user needs onboarding
  Future<bool> shouldShowOnboarding(AppUser user) async {
    return user.needsOnboarding;
  }

  /// Navigate to appropriate screen based on onboarding status
  Future<void> navigateAfterLogin(AppUser user, BuildContext context) async {
    if (!context.mounted) return;

    if (await shouldShowOnboarding(user)) {
      // First-time user: show language selector
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LanguageSelectorScreen(user: user),
        ),
      );
    } else {
      // Returning user: go directly to dashboard
      final screen = user.isTeacher
          ? TeacherDashboardScreen()
          : StudentHomeScreen(user: user);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );
    }
  }

  /// Complete onboarding and navigate to dashboard
  Future<void> completeOnboarding(
    AppUser user,
    String selectedLanguage,
    BuildContext context,
  ) async {
    // Update Firestore
    await _firestoreService.updateLanguagePreference(user.uid, selectedLanguage);
    await _firestoreService.completeFirstLogin(user.uid);

    // Save language preference to local storage
    await _localStorage.saveLanguagePreference(selectedLanguage);

    // Update local user object
    final updatedUser = user.copyWith(
      isFirstLogin: false,
      preferredLanguage: selectedLanguage,
    );
    await _localStorage.saveUser(updatedUser);

    if (!context.mounted) return;

    // Navigate to role-based dashboard
    final screen = user.isTeacher
        ? TeacherDashboardScreen()
        : StudentHomeScreen(user: updatedUser);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

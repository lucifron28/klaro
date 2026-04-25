import 'package:flutter/material.dart';
import 'package:klaro/models/app_user.dart';
import 'package:klaro/models/translation_models.dart';
import 'package:klaro/services/local_storage_service.dart';
import 'package:klaro/screens/student_home_screen.dart';
import 'package:klaro/screens/teacher_dashboard_screen.dart';
import 'package:klaro/utils/theme.dart';

/// ============================================================
/// Language Selector Screen
/// ============================================================
/// Allows users to select their preferred language during onboarding.
/// Displays all 9 Philippine languages.

class LanguageSelectorScreen extends StatefulWidget {
  final AppUser user;

  const LanguageSelectorScreen({super.key, required this.user});

  @override
  State<LanguageSelectorScreen> createState() =>
      _LanguageSelectorScreenState();
}

class _LanguageSelectorScreenState extends State<LanguageSelectorScreen> {
  final LocalStorageService _localStorage = LocalStorageService();

  SupportedLanguage? _selectedLanguage;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KlaroTheme.surfaceLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              Center(
                child: Image.asset(
                  'assets/images/Klaro-logo.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Text(
                'Choose Your Language',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: KlaroTheme.primaryBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Pumili ng iyong wika',
                style: TextStyle(
                  fontSize: 16,
                  color: KlaroTheme.textMuted,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Language Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: SupportedLanguage.all.length,
                  itemBuilder: (context, index) {
                    final language = SupportedLanguage.all[index];
                    final isSelected = _selectedLanguage == language;

                    return InkWell(
                      onTap: () => setState(() => _selectedLanguage = language),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? KlaroTheme.primaryBlue
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? KlaroTheme.primaryBlue
                                : KlaroTheme.borderLight,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color:
                                        KlaroTheme.primaryBlue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            language.displayName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : KlaroTheme.textDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Confirm Button
              ElevatedButton(
                onPressed: _selectedLanguage == null || _isLoading
                    ? null
                    : _confirmLanguageSelection,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Continue', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLanguageSelection() async {
    if (_selectedLanguage == null) return;

    setState(() => _isLoading = true);

    try {
      // Save language preference to local storage only
      await _localStorage.saveLanguagePreference(_selectedLanguage!.code);

      if (mounted) {
        // Navigate to role-based dashboard
        final screen = widget.user.isTeacher
            ? TeacherDashboardScreen(user: widget.user)
            : StudentHomeScreen(user: widget.user);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving language preference: $e'),
            backgroundColor: KlaroTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

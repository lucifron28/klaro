import 'package:flutter/material.dart';
import 'package:klaro/models/app_user.dart';
import 'package:klaro/screens/login_screen.dart';
import 'package:klaro/services/auth_service.dart';
import 'package:klaro/services/firestore_service.dart';
import 'package:klaro/services/local_storage_service.dart';
import 'package:klaro/utils/theme.dart';
import 'package:klaro/widgets/translatable_text.dart';

/// ============================================================
/// Student Settings Screen
/// ============================================================
/// Allows students to manage their account settings

class StudentSettingsScreen extends StatefulWidget {
  final AppUser user;

  const StudentSettingsScreen({
    super.key,
    required this.user,
  });

  @override
  State<StudentSettingsScreen> createState() => _StudentSettingsScreenState();
}

class _StudentSettingsScreenState extends State<StudentSettingsScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _localStorage = LocalStorageService();

  String _currentLanguage = 'en';
  bool _isLoading = true;

  bool get _isDemoUser =>
      widget.user.uid == 'demo-student' || widget.user.uid == 'demo-teacher';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final languageCode = await _localStorage.getLanguagePreference() ?? 'en';
      if (mounted) {
        setState(() {
          _currentLanguage = languageCode;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KlaroTheme.surfaceLight,
      appBar: AppBar(
        title: TranslatableText('Settings'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(20),
              children: [
                // Profile Section
                _buildSectionHeader('Profile'),
                _buildProfileCard(),
                SizedBox(height: 24),

                // Dialect Section
                _buildSectionHeader('Dialect'),
                _buildLanguageCard(),
                SizedBox(height: 24),

                // Security Section
                _buildSectionHeader('Security'),
                _buildSecurityCard(),
                SizedBox(height: 24),

                // Data Section
                _buildSectionHeader('Data & Privacy'),
                _buildDataCard(),
                SizedBox(height: 24),

                // About Section
                _buildSectionHeader('About'),
                _buildAboutCard(),
                SizedBox(height: 24),

                // Logout Button
                _buildLogoutButton(),
                SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: TranslatableText(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: KlaroTheme.textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Name',
            subtitle: widget.user.name,
            onTap: () => _showEditNameDialog(),
          ),
          Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: widget.user.email,
            onTap: null, // Email cannot be changed
            trailing:
                Icon(Icons.lock_outline, size: 16, color: KlaroTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard() {
    final languageName = _getLanguageName(_currentLanguage);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: _buildSettingsTile(
        icon: Icons.language,
        title: 'App Dialect',
        subtitle: languageName,
        onTap: () => _showLanguageDialog(),
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: _buildSettingsTile(
        icon: Icons.lock_outline,
        title: 'Change Password',
        subtitle: 'Update your password',
        onTap: () => _showChangePasswordDialog(),
      ),
    );
  }

  Widget _buildDataCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.delete_outline,
            title: 'Clear Progress Data',
            subtitle: 'Remove all quiz and assessment results',
            onTap: () => _showClearDataDialog(),
            iconColor: KlaroTheme.warning,
          ),
          Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.download_outlined,
            title: 'Export My Data',
            subtitle: 'Download your learning data',
            onTap: () => _showExportDataDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: '1.0.0',
            onTap: null,
          ),
          Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'Read our terms',
            onTap: () => _showTermsDialog(),
          ),
          Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'How we protect your data',
            onTap: () => _showPrivacyDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Widget? trailing,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? KlaroTheme.primaryBlue).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor ?? KlaroTheme.primaryBlue,
          size: 20,
        ),
      ),
      title: TranslatableText(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: KlaroTheme.textDark,
        ),
      ),
      subtitle: TranslatableText(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: KlaroTheme.textMuted,
        ),
      ),
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right, color: KlaroTheme.textMuted)
              : null),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: () => _showLogoutDialog(),
      icon: Icon(Icons.logout),
      label: TranslatableText('Logout'),
      style: ElevatedButton.styleFrom(
        backgroundColor: KlaroTheme.error,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // Dialogs
  // ══════════════════════════════════════════════════════════

  Future<void> _showEditNameDialog() async {
    final controller = TextEditingController(text: widget.user.name);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TranslatableText('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TranslatableText('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Name cannot be empty')),
                );
                return;
              }

              try {
                // Update in Firestore (skip for demo users)
                if (!_isDemoUser) {
                  await _firestoreService.updateUserProfile(
                    widget.user.uid,
                    {'name': newName},
                  );
                }

                // Update local user
                final updatedUser = widget.user.copyWith(name: newName);
                await _localStorage.saveUser(updatedUser);

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Name updated successfully!'),
                      backgroundColor: KlaroTheme.success,
                    ),
                  );
                  setState(() {}); // Refresh UI
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: KlaroTheme.error,
                    ),
                  );
                }
              }
            },
            child: TranslatableText('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguageDialog() async {
    final languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'tl', 'name': 'Tagalog'},
      {'code': 'ceb', 'name': 'Cebuano'},
      {'code': 'ilo', 'name': 'Ilocano'},
      {'code': 'hil', 'name': 'Hiligaynon'},
      {'code': 'war', 'name': 'Waray'},
      {'code': 'pam', 'name': 'Kapampangan'},
      {'code': 'bik', 'name': 'Bikol'},
      {'code': 'pag', 'name': 'Pangasinan'},
    ];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TranslatableText('Select Dialect'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((lang) {
              final isSelected = _currentLanguage == lang['code'];
              return RadioListTile<String>(
                value: lang['code']!,
                groupValue: _currentLanguage,
                title: Text(lang['name']!),
                activeColor: KlaroTheme.primaryBlue,
                selected: isSelected,
                onChanged: (value) async {
                  if (value != null) {
                    try {
                      // Save dialect preference locally
                      await _localStorage.saveLanguagePreference(value);

                      // Update in Firestore only for non-demo users
                      if (!_isDemoUser) {
                        await _firestoreService.updateLanguagePreference(
                          widget.user.uid,
                          value,
                        );
                      }

                      if (mounted) {
                        setState(() => _currentLanguage = value);
                        Navigator.pop(context); // Close dialect dialog

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Dialect changed to ${lang['name']}. Returning to home...'),
                            backgroundColor: KlaroTheme.success,
                            duration: Duration(seconds: 2),
                          ),
                        );

                        // Wait a moment for the snackbar to show, then pop back to home
                        await Future.delayed(Duration(milliseconds: 500));
                        if (mounted) {
                          Navigator.pop(this.context,
                              true); // Close settings screen and notify home
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error changing dialect: $e'),
                            backgroundColor: KlaroTheme.error,
                          ),
                        );
                      }
                    }
                  }
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TranslatableText('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: TranslatableText('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(obscureCurrent
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setDialogState(
                          () => obscureCurrent = !obscureCurrent),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                          obscureNew ? Icons.visibility : Icons.visibility_off),
                      onPressed: () =>
                          setDialogState(() => obscureNew = !obscureNew),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setDialogState(
                          () => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: TranslatableText('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final current = currentPasswordController.text;
                final newPass = newPasswordController.text;
                final confirm = confirmPasswordController.text;

                if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                if (newPass != confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('New passwords do not match')),
                  );
                  return;
                }

                if (newPass.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Password must be at least 6 characters')),
                  );
                  return;
                }

                // For demo users, show message
                if (widget.user.uid == 'demo-student') {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Password change not available for demo accounts'),
                      backgroundColor: KlaroTheme.warning,
                    ),
                  );
                  return;
                }

                // TODO: Implement password change with Firebase Auth
                // This requires re-authentication first
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Password change feature coming soon!'),
                    backgroundColor: KlaroTheme.primaryBlue,
                  ),
                );
              },
              child: TranslatableText('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showClearDataDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TranslatableText('Clear Progress Data'),
        content: TranslatableText(
          'This will permanently delete all your quiz results and AI assessments. This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TranslatableText('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Clear from local storage
                await _localStorage.clearAllProgress();

                // Clear from Firestore (if available)
                // Note: This would need additional methods in FirestoreService

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Progress data cleared successfully'),
                      backgroundColor: KlaroTheme.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: KlaroTheme.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: KlaroTheme.error,
            ),
            child: TranslatableText('Clear Data'),
          ),
        ],
      ),
    );
  }

  Future<void> _showExportDataDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TranslatableText('Export Data'),
        content: TranslatableText(
          'This feature will allow you to download all your learning data in JSON format. Coming soon!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TranslatableText('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTermsDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TranslatableText('Terms of Service'),
        content: SingleChildScrollView(
          child: TranslatableText(
            'By using Klaro, you agree to our terms of service. This app is designed to help Filipino students learn better through AI-powered assistance and multilingual support.\n\nFor the full terms, please visit our website.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TranslatableText('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPrivacyDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TranslatableText('Privacy Policy'),
        content: SingleChildScrollView(
          child: TranslatableText(
            'We take your privacy seriously. Your learning data is stored securely and is only used to improve your learning experience. We do not share your personal information with third parties.\n\nFor the full privacy policy, please visit our website.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TranslatableText('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TranslatableText('Logout'),
        content: TranslatableText('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TranslatableText('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: KlaroTheme.error,
            ),
            child: TranslatableText('Logout'),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    final names = {
      'en': 'English',
      'tl': 'Tagalog',
      'ceb': 'Cebuano',
      'ilo': 'Ilocano',
      'hil': 'Hiligaynon',
      'war': 'Waray',
      'pam': 'Kapampangan',
      'bik': 'Bikol',
      'pag': 'Pangasinan',
    };
    return names[code] ?? 'English';
  }
}

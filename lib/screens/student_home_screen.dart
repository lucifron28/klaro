import 'package:flutter/material.dart';
import 'package:klaro/data/sample_lessons.dart';
import 'package:klaro/models/app_user.dart';
import 'package:klaro/models/curriculum.dart';
import 'package:klaro/screens/login_screen.dart';
import 'package:klaro/screens/my_progress_screen.dart';
import 'package:klaro/screens/subject_modules_screen.dart';
import 'package:klaro/screens/student_settings_screen.dart';
import 'package:klaro/services/auth_service.dart';
import 'package:klaro/services/local_storage_service.dart';
import 'package:klaro/utils/theme.dart';
import 'package:klaro/utils/translations.dart';
import 'package:klaro/widgets/translatable_text.dart';

/// ============================================================
/// Student Home Screen
/// ============================================================
/// Shows the Grade 7 subject list and navigation to progress tabs.

class StudentHomeScreen extends StatefulWidget {
  final AppUser user;
  final int initialTab;

  const StudentHomeScreen({
    super.key,
    required this.user,
    this.initialTab = 0,
  });

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  late int _currentIndex;
  String _currentLanguageCode = 'en';
  String _subjectsLabel = 'Subjects';
  String _progressLabel = 'My Progress';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    final localStorage = LocalStorageService();
    final languageCode = await localStorage.getLanguagePreference() ?? 'en';

    final subjects = AppTranslations.translate('Subjects', languageCode);
    final progress = AppTranslations.translate('My Progress', languageCode);

    if (mounted) {
      setState(() {
        _currentLanguageCode = languageCode;
        _subjectsLabel = subjects;
        _progressLabel = progress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KlaroTheme.surfaceLight,
      body: _currentIndex == 0
          ? _buildSubjectsTab()
          : MyProgressScreen(user: widget.user),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: _subjectsLabel,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined),
            label: _progressLabel,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsTab() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/Klaro-logo.png',
                  width: 52,
                  height: 52,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          TranslatableText(
                            'Kumusta',
                            languageCode: _currentLanguageCode,
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              color: KlaroTheme.textDark,
                            ),
                          ),
                          Text(
                            ', ${widget.user.name}!',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              color: KlaroTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      TranslatableText(
                        'Choose a Grade 7 subject to start.',
                        languageCode: _currentLanguageCode,
                        style: TextStyle(
                          fontSize: 14,
                          color: KlaroTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final languageChanged = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            StudentSettingsScreen(user: widget.user),
                      ),
                    );

                    if (languageChanged == true && mounted) {
                      await _loadTranslations();
                    }
                  },
                  icon: Icon(Icons.settings_outlined,
                      color: KlaroTheme.textMuted),
                  tooltip: 'Settings',
                ),
                IconButton(
                  onPressed: () async {
                    await AuthService().signOut();
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                      );
                    }
                  },
                  icon: Icon(Icons.logout, color: KlaroTheme.textMuted),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TranslatableText(
              'Grade 7 Subjects',
              languageCode: _currentLanguageCode,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: KlaroTheme.textDark,
              ),
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: SampleLessons.subjects.length,
              itemBuilder: (context, index) {
                return _buildSubjectCard(
                  SampleLessons.subjects[index],
                  index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(CurriculumSubject subject, int index) {
    final colors = [
      KlaroTheme.primaryBlue,
      Color(0xFF0F766E),
      Color(0xFF7C3AED),
    ];
    final color = colors[index % colors.length];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubjectModulesScreen(subject: subject),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 14),
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _subjectIcon(subject.title),
                color: color,
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TranslatableText(
                        subject.title,
                        languageCode: _currentLanguageCode,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: KlaroTheme.textDark,
                        ),
                      ),
                      Text(
                        ' ${subject.gradeLevel.split(' ').last}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: KlaroTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  TranslatableText(
                    subject.description,
                    languageCode: _currentLanguageCode,
                    style: TextStyle(
                      fontSize: 13,
                      color: KlaroTheme.textMuted,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    children: [
                      Text(
                        '${subject.modules.length} ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      TranslatableText(
                        'modules',
                        languageCode: _currentLanguageCode,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      Text(
                        ' - ${subject.lessonCount} ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      TranslatableText(
                        'lessons',
                        languageCode: _currentLanguageCode,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: KlaroTheme.textMuted),
          ],
        ),
      ),
    );
  }

  IconData _subjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'science':
        return Icons.science_rounded;
      case 'english':
        return Icons.forum_rounded;
      case 'mathematics':
        return Icons.calculate_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }
}

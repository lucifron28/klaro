import 'package:flutter/material.dart';
import 'package:klaro/models/app_user.dart';
import 'package:klaro/models/lesson.dart';
import 'package:klaro/data/sample_lessons.dart';
import 'package:klaro/screens/lesson_reading_screen.dart';
import 'package:klaro/screens/student_dashboard_screen.dart';
import 'package:klaro/screens/login_screen.dart';
import 'package:klaro/services/auth_service.dart';
import 'package:klaro/services/local_storage_service.dart';
import 'package:klaro/utils/theme.dart';

/// ============================================================
/// Student Home Screen
/// ============================================================
/// Shows the list of available lessons and navigation to dashboard.

class StudentHomeScreen extends StatefulWidget {
  final AppUser user;

  const StudentHomeScreen({super.key, required this.user});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentIndex = 0;
  final _localStorage = LocalStorageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KlaroTheme.surfaceLight,
      body: _currentIndex == 0 ? _buildLessonsTab() : StudentDashboardScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Lessons',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'My Progress',
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsTab() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kumusta, ${widget.user.name}!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: KlaroTheme.textDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ready to learn something new?',
                        style: TextStyle(
                          fontSize: 14,
                          color: KlaroTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Logout button
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

          // Lessons list
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Your Lessons',
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
              itemCount: SampleLessons.lessons.length,
              itemBuilder: (context, index) {
                final lesson = SampleLessons.lessons[index];
                return _buildLessonCard(lesson, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(Lesson lesson, int index) {
    final colors = [KlaroTheme.primaryBlue, Color(0xFF6366F1)];
    final color = colors[index % colors.length];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LessonReadingScreen(lesson: lesson),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.science_rounded,
                color: color,
                size: 28,
              ),
            ),
            SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: KlaroTheme.textDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      _buildTag(lesson.subject, color),
                      SizedBox(width: 6),
                      _buildTag(lesson.gradeLevel, KlaroTheme.textMuted),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    '${lesson.keyTerms.length} key terms to learn',
                    style: TextStyle(
                      fontSize: 12,
                      color: KlaroTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.chevron_right,
              color: KlaroTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

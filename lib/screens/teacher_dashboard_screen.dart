import 'package:flutter/material.dart';
import 'package:klaro/data/sample_students.dart';
import 'package:klaro/screens/login_screen.dart';
import 'package:klaro/services/auth_service.dart';
import 'package:klaro/utils/theme.dart';
import 'package:klaro/widgets/translatable_text.dart';

/// ============================================================
/// Teacher Dashboard Screen
/// ============================================================
/// Hardcoded dashboard showing student performance data.
/// In production, this would pull from Firestore.

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final students = SampleStudents.students;
    final avgScore =
        students.map((s) => s.overallPercent).reduce((a, b) => a + b) ~/
            students.length;
    final completedCount =
        students.where((s) => s.status != 'Needs Review').length;

    return Scaffold(
      backgroundColor: KlaroTheme.surfaceLight,
      appBar: AppBar(
        title: TranslatableText('Teacher Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService().signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
            icon: Icon(Icons.logout, color: KlaroTheme.textMuted),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            TranslatableText(
              'Class Overview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: KlaroTheme.textDark,
              ),
            ),
            SizedBox(height: 4),
            TranslatableText(
              'The Water Cycle - Grade 8 Science',
              style: TextStyle(
                fontSize: 14,
                color: KlaroTheme.textMuted,
              ),
            ),
            SizedBox(height: 20),

            // Summary stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Students',
                    '${students.length}',
                    Icons.people_rounded,
                    KlaroTheme.primaryBlue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Avg Score',
                    '$avgScore%',
                    Icons.bar_chart_rounded,
                    KlaroTheme.success,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    '$completedCount/${students.length}',
                    Icons.check_circle_rounded,
                    KlaroTheme.accentYellow.withRed(200),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Student list header
            Row(
              children: [
                TranslatableText(
                  'Student Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: KlaroTheme.textDark,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: KlaroTheme.accentYellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt, size: 12, color: KlaroTheme.warning),
                      SizedBox(width: 4),
                      TranslatableText(
                        'Demo Data',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: KlaroTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Student cards
            ...students.map((student) => _buildStudentCard(student)),

            SizedBox(height: 24),

            // Lesson info
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: KlaroTheme.primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: KlaroTheme.primaryBlue.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: KlaroTheme.primaryBlue),
                      SizedBox(width: 8),
                      TranslatableText(
                        'About This Dashboard',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: KlaroTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  TranslatableText(
                    'This dashboard shows hardcoded demo data for the hackathon presentation. '
                    'In the full version, teachers will be able to upload lessons, '
                    'view real-time student progress, and generate class reports.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: KlaroTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          SizedBox(height: 8),
          TranslatableText(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          SizedBox(height: 2),
          TranslatableText(
            label,
            style: TextStyle(
              fontSize: 11,
              color: KlaroTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(SampleStudent student) {
    Color statusColor;
    IconData statusIcon;

    switch (student.status) {
      case 'Excellent':
        statusColor = KlaroTheme.success;
        statusIcon = Icons.star_rounded;
        break;
      case 'Needs Review':
        statusColor = KlaroTheme.error;
        statusIcon = Icons.warning_rounded;
        break;
      default:
        statusColor = KlaroTheme.primaryBlue;
        statusIcon = Icons.check_circle_outline;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: KlaroTheme.lightBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                student.name.split(' ').map((n) => n[0]).join(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: KlaroTheme.primaryBlue,
                ),
              ),
            ),
          ),
          SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: KlaroTheme.textDark,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    TranslatableText(
                      'Quiz: ${student.quizScore}/${student.quizTotal}',
                      style:
                          TextStyle(fontSize: 12, color: KlaroTheme.textMuted),
                    ),
                    SizedBox(width: 12),
                    TranslatableText(
                      'AI: ${student.aiScore}/5',
                      style:
                          TextStyle(fontSize: 12, color: KlaroTheme.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Score & Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${student.overallPercent}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
              ),
              SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 12, color: statusColor),
                  SizedBox(width: 4),
                  Text(
                    student.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

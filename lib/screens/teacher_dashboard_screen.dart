import 'package:flutter/material.dart';
import 'package:klaro/models/app_user.dart';
import 'package:klaro/models/teacher_student.dart';
import 'package:klaro/screens/login_screen.dart';
import 'package:klaro/screens/teacher_students_screen.dart';
import 'package:klaro/screens/teacher_modules_screen.dart';
import 'package:klaro/screens/teacher_student_detail_screen.dart';
import 'package:klaro/services/auth_service.dart';
import 'package:klaro/services/firestore_service.dart';
import 'package:klaro/services/demo_data_seeder.dart';
import 'package:klaro/utils/theme.dart';
import 'package:klaro/widgets/translatable_text.dart';

/// ============================================================
/// Teacher Dashboard Screen
/// ============================================================
/// Main dashboard for teachers showing students and modules

class TeacherDashboardScreen extends StatefulWidget {
  final AppUser user;

  const TeacherDashboardScreen({
    super.key,
    required this.user,
  });

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final _firestoreService = FirestoreService();
  List<StudentProgressSummary> _recentStudents = [];
  bool _isLoading = true;
  bool _isSettingUpDemo = false;

  @override
  void initState() {
    super.initState();
    _setupDemoDataIfNeeded();
    _loadDashboardData();
  }

  /// Setup demo data for demo teacher
  Future<void> _setupDemoDataIfNeeded() async {
    // Only run for demo teacher
    if (widget.user.uid != 'demo-teacher') return;

    try {
      final seeder = DemoDataSeeder();
      await seeder.setupDemoData();
    } catch (e) {
      debugPrint('Demo data setup skipped: $e');
    }
  }

  /// Manual demo setup (triggered by button)
  Future<void> _manualSetupDemo() async {
    setState(() => _isSettingUpDemo = true);

    try {
      final seeder = DemoDataSeeder();

      // Check if already added
      final isAdded = await seeder.isDemoStudentAdded();

      if (isAdded) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Demo student is already added!'),
              backgroundColor: KlaroTheme.primaryBlue,
            ),
          );
        }
      } else {
        await seeder.addDemoStudentToTeacher();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Demo student added successfully!'),
              backgroundColor: KlaroTheme.success,
            ),
          );

          // Reload dashboard
          _loadDashboardData();
        }
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
    } finally {
      if (mounted) {
        setState(() => _isSettingUpDemo = false);
      }
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // Load teacher's students
      final students =
          await _firestoreService.getTeacherStudents(widget.user.uid);

      debugPrint(
          '📊 Loaded ${students.length} students for teacher ${widget.user.uid}');

      // Load progress for recent students (limit to 5)
      final recentProgress = <StudentProgressSummary>[];
      for (final student in students.take(5)) {
        debugPrint('📈 Loading progress for student: ${student.studentId}');
        final progress = await _firestoreService
            .getStudentProgressSummary(student.studentId);
        if (progress != null) {
          debugPrint(
              '✅ Progress loaded: ${progress.studentName} - ${progress.overallProgress.toStringAsFixed(1)}%');
          recentProgress.add(progress);
        } else {
          debugPrint('⚠️ No progress data for: ${student.studentName}');
          // Create a summary with zero progress for students without data
          recentProgress.add(StudentProgressSummary(
            studentId: student.studentId,
            studentName: student.studentName,
            studentEmail: student.studentEmail,
            totalLessonsCompleted: 0,
            totalQuizzesTaken: 0,
            averageQuizScore: 0.0,
            totalAIAssessments: 0,
            averageAIScore: 0.0,
            overallProgress: 0.0,
            strugglingTopics: [],
            lastActivity: student.enrolledAt,
          ));
        }
      }

      if (mounted) {
        setState(() {
          _recentStudents = recentProgress;
          _isLoading = false;
        });
        debugPrint(
            '✅ Dashboard loaded with ${_recentStudents.length} students');
      }
    } catch (e) {
      debugPrint('❌ Error loading dashboard: $e');
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
        leadingWidth: 64,
        leading: Padding(
          padding: EdgeInsets.only(left: 16),
          child: Image.asset(
            'assets/images/Klaro-logo.png',
            fit: BoxFit.contain,
          ),
        ),
        title: TranslatableText('Teacher Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          // Demo setup button (only for demo teacher)
          if (widget.user.uid == 'demo-teacher')
            IconButton(
              onPressed: _isSettingUpDemo ? null : _manualSetupDemo,
              icon: Icon(Icons.science, color: KlaroTheme.accentYellow),
              tooltip: 'Setup Demo Data',
            ),
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Header
                  Row(
                    children: [
                      TranslatableText(
                        'Kumusta',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: KlaroTheme.textDark,
                        ),
                      ),
                      Text(
                        ', ${widget.user.name}!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: KlaroTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  TranslatableText(
                    'Manage your students and modules',
                    style: TextStyle(
                      fontSize: 14,
                      color: KlaroTheme.textMuted,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          'My Students',
                          Icons.people_rounded,
                          KlaroTheme.primaryBlue,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TeacherStudentsScreen(
                                  teacherId: widget.user.uid,
                                ),
                              ),
                            ).then((_) => _loadDashboardData());
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          'My Modules',
                          Icons.library_books_rounded,
                          Color(0xFF0F766E),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TeacherModulesScreen(
                                  teacherId: widget.user.uid,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Recent Students Section
                  Row(
                    children: [
                      TranslatableText(
                        'Recent Student Activity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: KlaroTheme.textDark,
                        ),
                      ),
                      Spacer(),
                      if (_recentStudents.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TeacherStudentsScreen(
                                  teacherId: widget.user.uid,
                                ),
                              ),
                            ).then((_) => _loadDashboardData());
                          },
                          child: TranslatableText('View All'),
                        ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Student Cards
                  if (_recentStudents.isEmpty)
                    _buildEmptyStudentsState()
                  else
                    ..._recentStudents
                        .map((student) => _buildStudentCard(student)),

                  SizedBox(height: 24),

                  // Info Card
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: KlaroTheme.primaryBlue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: KlaroTheme.primaryBlue.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline,
                                size: 20, color: KlaroTheme.primaryBlue),
                            SizedBox(width: 8),
                            TranslatableText(
                              'Getting Started',
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
                          '1. Add your students to start tracking their progress\n'
                          '2. Upload custom modules for your class\n'
                          '3. View individual student progress and get AI-powered teaching suggestions',
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

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: 12),
            TranslatableText(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: KlaroTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(StudentProgressSummary student) {
    final statusColor =
        student.needsAttention ? KlaroTheme.warning : KlaroTheme.success;

    return GestureDetector(
      onTap: () async {
        // Find the TeacherStudent object
        final students =
            await _firestoreService.getTeacherStudents(widget.user.uid);
        final teacherStudent = students.firstWhere(
          (s) => s.studentId == student.studentId,
          orElse: () => TeacherStudent(
            studentId: student.studentId,
            studentName: student.studentName,
            studentEmail: student.studentEmail,
            gradeLevel: 'Grade 7',
            enrolledAt: DateTime.now(),
          ),
        );

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TeacherStudentDetailScreen(
                teacherId: widget.user.uid,
                student: teacherStudent,
                progress: student,
              ),
            ),
          ).then((_) => _loadDashboardData());
        }
      },
      child: Container(
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
                color: KlaroTheme.lightBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  student.studentName
                      .split(' ')
                      .map((n) => n[0])
                      .take(2)
                      .join(),
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
                    student.studentName,
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
                        'Quiz: ${student.averageQuizScore.toStringAsFixed(0)}%',
                        style: TextStyle(
                            fontSize: 12, color: KlaroTheme.textMuted),
                      ),
                      SizedBox(width: 12),
                      TranslatableText(
                        'AI: ${student.averageAIScore.toStringAsFixed(0)}%',
                        style: TextStyle(
                            fontSize: 12, color: KlaroTheme.textMuted),
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
                  '${student.overallProgress.toStringAsFixed(0)}%',
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
                    Icon(
                      student.needsAttention
                          ? Icons.warning_rounded
                          : Icons.check_circle_rounded,
                      size: 12,
                      color: statusColor,
                    ),
                    SizedBox(width: 4),
                    Text(
                      student.statusLabel,
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
      ),
    );
  }

  Widget _buildEmptyStudentsState() {
    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: KlaroTheme.textMuted.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16),
          TranslatableText(
            'No students yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: KlaroTheme.textMuted,
            ),
          ),
          SizedBox(height: 8),
          TranslatableText(
            'Add students to start tracking their progress',
            style: TextStyle(
              fontSize: 13,
              color: KlaroTheme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TeacherStudentsScreen(
                    teacherId: widget.user.uid,
                  ),
                ),
              ).then((_) => _loadDashboardData());
            },
            icon: Icon(Icons.person_add),
            label: TranslatableText('Add Students'),
            style: ElevatedButton.styleFrom(
              backgroundColor: KlaroTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

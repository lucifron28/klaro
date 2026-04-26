import 'package:flutter/material.dart';
import 'package:klaro/models/teacher_student.dart';
import 'package:klaro/screens/teacher_student_detail_screen.dart';
import 'package:klaro/services/firestore_service.dart';
import 'package:klaro/services/local_storage_service.dart';
import 'package:klaro/utils/theme.dart';
import 'package:klaro/utils/translations.dart';
import 'package:klaro/widgets/translatable_text.dart';

/// ============================================================
/// Teacher Students Screen
/// ============================================================
/// Shows all students assigned to a teacher with their progress

class TeacherStudentsScreen extends StatefulWidget {
  final String teacherId;

  const TeacherStudentsScreen({
    super.key,
    required this.teacherId,
  });

  @override
  State<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends State<TeacherStudentsScreen> {
  final _firestoreService = FirestoreService();
  final _localStorage = LocalStorageService();
  List<TeacherStudent> _students = [];
  Map<String, StudentProgressSummary?> _progressMap = {};
  bool _isLoading = true;
  String _searchQuery = '';
  String _searchHint = 'Search students...';

  @override
  void initState() {
    super.initState();
    _loadTranslations();
    _loadStudents();
  }

  Future<void> _loadTranslations() async {
    final languageCode = await _localStorage.getLanguagePreference() ?? 'en';
    final translated = AppTranslations.translate('Search students...', languageCode);
    if (mounted) {
      setState(() => _searchHint = translated);
    }
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);

    try {
      final students = await _firestoreService.getTeacherStudents(widget.teacherId);
      
      debugPrint('📊 Loaded ${students.length} students');
      
      // Load progress for each student
      final progressMap = <String, StudentProgressSummary?>{};
      for (final student in students) {
        debugPrint('📈 Loading progress for: ${student.studentName} (${student.studentId})');
        final progress = await _firestoreService.getStudentProgressSummary(student.studentId);
        
        if (progress != null) {
          debugPrint('✅ Progress found: ${progress.overallProgress.toStringAsFixed(1)}%');
          progressMap[student.studentId] = progress;
        } else {
          debugPrint('⚠️ No progress data, creating empty summary');
          // Create empty progress summary for students without data
          progressMap[student.studentId] = StudentProgressSummary(
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
          );
        }
      }

      if (mounted) {
        setState(() {
          _students = students;
          _progressMap = progressMap;
          _isLoading = false;
        });
        debugPrint('✅ Students screen loaded with ${_students.length} students');
      }
    } catch (e) {
      debugPrint('❌ Error loading students: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading students: $e'),
            backgroundColor: KlaroTheme.error,
          ),
        );
      }
    }
  }

  List<TeacherStudent> get _filteredStudents {
    if (_searchQuery.isEmpty) return _students;
    
    return _students.where((student) {
      return student.studentName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.studentEmail.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KlaroTheme.surfaceLight,
      appBar: AppBar(
        title: TranslatableText('My Students'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadStudents,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: _searchHint,
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),

                // Summary Stats
                if (_students.isNotEmpty) _buildSummaryStats(),

                // Student List
                Expanded(
                  child: _filteredStudents.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = _filteredStudents[index];
                            final progress = _progressMap[student.studentId];
                            return _buildStudentCard(student, progress);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStudentDialog,
        backgroundColor: KlaroTheme.primaryBlue,
        foregroundColor: Colors.white,
        icon: Icon(Icons.person_add),
        label: TranslatableText('Add Student'),
      ),
    );
  }

  Widget _buildSummaryStats() {
    final totalStudents = _students.length;
    final studentsWithProgress = _progressMap.values.where((p) => p != null).length;
    final avgProgress = studentsWithProgress > 0
        ? _progressMap.values
                .where((p) => p != null)
                .map((p) => p!.overallProgress)
                .reduce((a, b) => a + b) /
            studentsWithProgress
        : 0.0;
    final needingSupport = _progressMap.values.where((p) => p?.needsAttention ?? false).length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', '$totalStudents', KlaroTheme.primaryBlue),
          _buildStatItem('Avg Progress', '${avgProgress.toStringAsFixed(0)}%', KlaroTheme.success),
          _buildStatItem('Need Support', '$needingSupport', KlaroTheme.warning),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        TranslatableText(
          label,
          style: TextStyle(
            fontSize: 11,
            color: KlaroTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(TeacherStudent student, StudentProgressSummary? progress) {
    final statusColor = progress == null
        ? KlaroTheme.textMuted
        : progress.needsAttention
            ? KlaroTheme.warning
            : KlaroTheme.success;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeacherStudentDetailScreen(
              teacherId: widget.teacherId,
              student: student,
              progress: progress,
            ),
          ),
        ).then((_) => _loadStudents());
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: KlaroTheme.lightBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  student.studentName.split(' ').map((n) => n[0]).take(2).join(),
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
                  Text(
                    student.studentEmail,
                    style: TextStyle(
                      fontSize: 12,
                      color: KlaroTheme.textMuted,
                    ),
                  ),
                  if (progress != null) ...[
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.assignment_turned_in, size: 12, color: KlaroTheme.textMuted),
                        SizedBox(width: 4),
                        Text(
                          '${progress.totalQuizzesTaken} ',
                          style: TextStyle(fontSize: 11, color: KlaroTheme.textMuted),
                        ),
                        TranslatableText(
                          'quizzes',
                          style: TextStyle(fontSize: 11, color: KlaroTheme.textMuted),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.psychology, size: 12, color: KlaroTheme.textMuted),
                        SizedBox(width: 4),
                        Text(
                          '${progress.totalAIAssessments} ',
                          style: TextStyle(fontSize: 11, color: KlaroTheme.textMuted),
                        ),
                        TranslatableText(
                          'AI tests',
                          style: TextStyle(fontSize: 11, color: KlaroTheme.textMuted),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Progress
            if (progress != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${progress.overallProgress.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                  SizedBox(height: 2),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: TranslatableText(
                      progress.statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              )
            else
                      TranslatableText(
                        'No data',
                        style: TextStyle(
                          fontSize: 12,
                          color: KlaroTheme.textMuted,
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: KlaroTheme.textMuted.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16),
          TranslatableText(
            _searchQuery.isEmpty ? 'No students yet' : 'No students found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: KlaroTheme.textMuted,
            ),
          ),
          SizedBox(height: 8),
          TranslatableText(
            _searchQuery.isEmpty
                ? 'Add students to start tracking their progress'
                : 'Try a different search term',
            style: TextStyle(
              fontSize: 14,
              color: KlaroTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddStudentDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedGrade = 'Grade 7';
    final sectionController = TextEditingController();

    // Load translations before showing dialog
    final languageCode = await _localStorage.getLanguagePreference() ?? 'en';
    final studentNameLabel = AppTranslations.translate('Student Name', languageCode);
    final studentEmailLabel = AppTranslations.translate('Student Email', languageCode);
    final gradeLevelLabel = AppTranslations.translate('Grade Level', languageCode);
    final sectionLabel = AppTranslations.translate('Section (Optional)', languageCode);
    final fillFieldsMsg = AppTranslations.translate('Please fill in all required fields', languageCode);
    final successMsg = AppTranslations.translate('Student added successfully!', languageCode);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: TranslatableText('Add Student'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: studentNameLabel,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: studentEmailLabel,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedGrade,
                  decoration: InputDecoration(
                    labelText: gradeLevelLabel,
                    border: OutlineInputBorder(),
                  ),
                  items: ['Grade 7', 'Grade 8', 'Grade 9', 'Grade 10']
                      .map((grade) => DropdownMenuItem(
                            value: grade,
                            child: Text(grade),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedGrade = value!);
                  },
                ),
                SizedBox(height: 12),
                TextField(
                  controller: sectionController,
                  decoration: InputDecoration(
                    labelText: sectionLabel,
                    border: OutlineInputBorder(),
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
                if (nameController.text.isEmpty || emailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(fillFieldsMsg)),
                  );
                  return;
                }

                try {
                  final student = TeacherStudent(
                    studentId: emailController.text.trim().toLowerCase().replaceAll('@', '_at_').replaceAll('.', '_'),
                    studentName: nameController.text.trim(),
                    studentEmail: emailController.text.trim(),
                    gradeLevel: selectedGrade,
                    enrolledAt: DateTime.now(),
                    section: sectionController.text.trim().isEmpty ? null : sectionController.text.trim(),
                  );

                  await _firestoreService.addStudentToTeacher(widget.teacherId, student);
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(successMsg),
                        backgroundColor: KlaroTheme.success,
                      ),
                    );
                    _loadStudents();
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: KlaroTheme.error,
                    ),
                  );
                }
              },
              child: TranslatableText('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

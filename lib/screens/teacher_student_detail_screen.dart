import 'package:flutter/material.dart';
import 'package:klaro/models/teacher_student.dart';
import 'package:klaro/models/lesson_suggestion.dart';
import 'package:klaro/services/lesson_suggestion_service.dart';
import 'package:klaro/utils/theme.dart';
import 'package:klaro/widgets/translatable_text.dart';

/// ============================================================
/// Teacher Student Detail Screen
/// ============================================================
/// Shows detailed progress for a single student with AI suggestions

class TeacherStudentDetailScreen extends StatefulWidget {
  final String teacherId;
  final TeacherStudent student;
  final StudentProgressSummary? progress;

  const TeacherStudentDetailScreen({
    super.key,
    required this.teacherId,
    required this.student,
    this.progress,
  });

  @override
  State<TeacherStudentDetailScreen> createState() => _TeacherStudentDetailScreenState();
}

class _TeacherStudentDetailScreenState extends State<TeacherStudentDetailScreen> {
  final _suggestionService = LessonSuggestionService();
  List<LessonSuggestion>? _suggestions;
  bool _isLoadingSuggestions = false;

  @override
  void initState() {
    super.initState();
    if (widget.progress != null && widget.progress!.needsAttention) {
      _loadSuggestions();
    }
  }

  Future<void> _loadSuggestions() async {
    if (widget.progress == null) return;

    setState(() => _isLoadingSuggestions = true);

    try {
      final suggestions = await _suggestionService.generateSuggestions(widget.progress!);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSuggestions = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading suggestions: $e'),
            backgroundColor: KlaroTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.progress;

    return Scaffold(
      backgroundColor: KlaroTheme.surfaceLight,
      appBar: AppBar(
        title: Text(widget.student.studentName),
      ),
      body: progress == null
          ? _buildNoDataState()
          : ListView(
              padding: EdgeInsets.all(20),
              children: [
                // Student Info Card
                _buildStudentInfoCard(),
                SizedBox(height: 16),

                // Progress Overview
                _buildProgressOverview(progress),
                SizedBox(height: 16),

                // Performance Breakdown
                _buildPerformanceBreakdown(progress),
                SizedBox(height: 16),

                // Struggling Topics
                if (progress.strugglingTopics.isNotEmpty) ...[
                  _buildStrugglingTopics(progress),
                  SizedBox(height: 16),
                ],

                // AI Suggestions
                if (progress.needsAttention) ...[
                  _buildAISuggestions(),
                  SizedBox(height: 16),
                ],

                // Last Activity
                _buildLastActivity(progress),
              ],
            ),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: KlaroTheme.textMuted.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16),
          TranslatableText(
            'No Progress Data Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: KlaroTheme.textMuted,
            ),
          ),
          SizedBox(height: 8),
          TranslatableText(
            'This student hasn\'t completed any lessons yet',
            style: TextStyle(
              fontSize: 14,
              color: KlaroTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: KlaroTheme.lightBlue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                widget.student.studentName.split(' ').map((n) => n[0]).take(2).join(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: KlaroTheme.primaryBlue,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.student.studentName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: KlaroTheme.textDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.student.studentEmail,
                  style: TextStyle(
                    fontSize: 13,
                    color: KlaroTheme.textMuted,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${widget.student.gradeLevel}${widget.student.section != null ? " - ${widget.student.section}" : ""}',
                  style: TextStyle(
                    fontSize: 13,
                    color: KlaroTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(StudentProgressSummary progress) {
    final statusColor = progress.needsAttention ? KlaroTheme.warning : KlaroTheme.success;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withValues(alpha: 0.1), statusColor.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '${progress.overallProgress.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: statusColor,
            ),
          ),
          SizedBox(height: 8),
          TranslatableText(
            'Overall Progress',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: KlaroTheme.textDark,
            ),
          ),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              progress.statusLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceBreakdown(StudentProgressSummary progress) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TranslatableText(
            'Performance Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: KlaroTheme.textDark,
            ),
          ),
          SizedBox(height: 16),
          _buildStatRow(
            'Lessons Completed',
            '${progress.totalLessonsCompleted}',
            Icons.menu_book,
            KlaroTheme.primaryBlue,
          ),
          SizedBox(height: 12),
          _buildStatRow(
            'Quizzes Taken',
            '${progress.totalQuizzesTaken}',
            Icons.quiz,
            Color(0xFF0F766E),
          ),
          SizedBox(height: 12),
          _buildStatRow(
            'Average Quiz Score',
            '${progress.averageQuizScore.toStringAsFixed(1)}%',
            Icons.assessment,
            progress.averageQuizScore >= 75 ? KlaroTheme.success : KlaroTheme.warning,
          ),
          SizedBox(height: 12),
          _buildStatRow(
            'AI Assessments',
            '${progress.totalAIAssessments}',
            Icons.psychology,
            Color(0xFF7C3AED),
          ),
          SizedBox(height: 12),
          _buildStatRow(
            'Average AI Score',
            '${progress.averageAIScore.toStringAsFixed(1)}%',
            Icons.stars,
            progress.averageAIScore >= 75 ? KlaroTheme.success : KlaroTheme.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: TranslatableText(
            label,
            style: TextStyle(
              fontSize: 14,
              color: KlaroTheme.textDark,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStrugglingTopics(StudentProgressSummary progress) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KlaroTheme.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: KlaroTheme.warning, size: 20),
              SizedBox(width: 8),
              TranslatableText(
                'Topics Needing Attention',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: KlaroTheme.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...progress.strugglingTopics.map((topic) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: KlaroTheme.warning),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        topic,
                        style: TextStyle(
                          fontSize: 13,
                          color: KlaroTheme.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildAISuggestions() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KlaroTheme.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: KlaroTheme.accentYellow, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: TranslatableText(
                  'AI-Powered Teaching Suggestions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: KlaroTheme.textDark,
                  ),
                ),
              ),
              if (_isLoadingSuggestions)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (_suggestions == null)
                IconButton(
                  icon: Icon(Icons.refresh, size: 20),
                  onPressed: _loadSuggestions,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
            ],
          ),
          SizedBox(height: 12),
          if (_isLoadingSuggestions)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    TranslatableText(
                      'Generating personalized suggestions...',
                      style: TextStyle(
                        fontSize: 12,
                        color: KlaroTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_suggestions == null || _suggestions!.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: TranslatableText(
                  'Tap refresh to generate AI suggestions',
                  style: TextStyle(
                    fontSize: 13,
                    color: KlaroTheme.textMuted,
                  ),
                ),
              ),
            )
          else
            ..._suggestions!.map((suggestion) => _buildSuggestionCard(suggestion)),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(LessonSuggestion suggestion) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KlaroTheme.lightBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: KlaroTheme.primaryBlue.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  suggestion.topic,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: KlaroTheme.textDark,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(suggestion.difficulty).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  suggestion.difficulty,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getDifficultyColor(suggestion.difficulty),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Teaching Strategy:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: KlaroTheme.textDark,
            ),
          ),
          SizedBox(height: 4),
          Text(
            suggestion.teachingStrategy,
            style: TextStyle(
              fontSize: 12,
              color: KlaroTheme.textMuted,
              height: 1.4,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Key Recommendations:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: KlaroTheme.textDark,
            ),
          ),
          SizedBox(height: 4),
          ...suggestion.recommendations.take(3).map((rec) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: KlaroTheme.primaryBlue)),
                    Expanded(
                      child: Text(
                        rec,
                        style: TextStyle(
                          fontSize: 11,
                          color: KlaroTheme.textMuted,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'high':
        return KlaroTheme.error;
      case 'medium':
        return KlaroTheme.warning;
      default:
        return KlaroTheme.success;
    }
  }

  Widget _buildLastActivity(StudentProgressSummary progress) {
    final daysAgo = DateTime.now().difference(progress.lastActivity).inDays;
    final activityText = daysAgo == 0
        ? 'Today'
        : daysAgo == 1
            ? 'Yesterday'
            : '$daysAgo days ago';

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: KlaroTheme.textMuted, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TranslatableText(
                  'Last Activity',
                  style: TextStyle(
                    fontSize: 12,
                    color: KlaroTheme.textMuted,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  activityText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: KlaroTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

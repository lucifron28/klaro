import 'package:flutter/material.dart';
import 'package:klaro/models/quiz_response.dart';
import 'package:klaro/models/ai_conversation.dart';
import 'package:klaro/services/local_storage_service.dart';
import 'package:klaro/utils/helpers.dart';
import 'package:klaro/utils/theme.dart';
import 'package:klaro/widgets/translatable_text.dart';

/// ============================================================
/// Student Dashboard Screen
/// ============================================================
/// Shows the student's learning history and performance across lessons.

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final LocalStorageService _localStorage = LocalStorageService();
  List<QuizResponse> _quizResponses = [];
  List<AIConversation> _aiConversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final quizzes = await _localStorage.getAllQuizResponses();
    final conversations = await _localStorage.getAllAIConversations();
    setState(() {
      _quizResponses = quizzes;
      _aiConversations = conversations;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _isLoading
          ? Center(child: CircularProgressIndicator(color: KlaroTheme.primaryBlue))
          : _quizResponses.isEmpty
              ? _buildEmptyState()
              : _buildDashboard(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 64,
            color: KlaroTheme.textMuted.withOpacity(0.3),
          ),
          SizedBox(height: 16),
          TranslatableText(
            'No progress yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: KlaroTheme.textDark,
            ),
          ),
          SizedBox(height: 8),
          TranslatableText(
            'Complete a lesson and quiz to see your progress here.',
            style: TextStyle(
              fontSize: 14,
              color: KlaroTheme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TranslatableText(
            'My Progress',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: KlaroTheme.textDark,
            ),
          ),
          SizedBox(height: 4),
          TranslatableText(
            '${_quizResponses.length} lesson(s) completed',
            style: TextStyle(
              fontSize: 14,
              color: KlaroTheme.textMuted,
            ),
          ),
          SizedBox(height: 20),

          // Summary stats
          _buildSummaryRow(),
          SizedBox(height: 24),

          // Lesson history
          TranslatableText(
            'Lesson History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: KlaroTheme.textDark,
            ),
          ),
          SizedBox(height: 12),

          ..._quizResponses.map((quiz) => _buildLessonHistoryCard(quiz)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    final avgQuiz = _quizResponses.isEmpty
        ? 0
        : _quizResponses.map((q) => q.percentage).reduce((a, b) => a + b) ~/
            _quizResponses.length;

    final avgAI = _aiConversations.isEmpty
        ? 0.0
        : _aiConversations.map((c) => c.score).reduce((a, b) => a + b) /
            _aiConversations.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Avg Quiz',
            '$avgQuiz%',
            Icons.quiz_rounded,
            KlaroTheme.accentYellow.withRed(200),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Avg AI Score',
            '${avgAI.toStringAsFixed(1)}/5',
            Icons.chat_bubble_rounded,
            KlaroTheme.primaryBlue,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Lessons',
            '${_quizResponses.length}',
            Icons.menu_book_rounded,
            KlaroTheme.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
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
          Text(
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

  Widget _buildLessonHistoryCard(QuizResponse quiz) {
    // Find matching AI conversation
    final aiConv = _aiConversations.firstWhere(
      (c) => c.lessonId == quiz.lessonId,
      orElse: () => AIConversation(
        lessonId: '',
        lessonTitle: '',
        score: 0,
        summary: 'Not completed',
        date: DateTime.now(),
      ),
    );

    final overallPercent = Helpers.calculateOverallScore(
      quiz.percentage,
      aiConv.score,
    );

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  quiz.lessonTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: KlaroTheme.textDark,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: overallPercent >= 70
                      ? KlaroTheme.success.withOpacity(0.1)
                      : KlaroTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$overallPercent%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: overallPercent >= 70
                        ? KlaroTheme.success
                        : KlaroTheme.warning,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildMiniStat('Quiz', '${quiz.score}/${quiz.total}'),
              SizedBox(width: 16),
              _buildMiniStat('AI', '${aiConv.score.toStringAsFixed(1)}/5'),
              SizedBox(width: 16),
              _buildMiniStat('Date', Helpers.formatDate(quiz.date)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: KlaroTheme.textMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: KlaroTheme.textDark,
          ),
        ),
      ],
    );
  }
}

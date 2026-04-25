import 'package:flutter/material.dart';
import 'package:klaro/models/quiz_response.dart';
import 'package:klaro/models/ai_conversation.dart';
import 'package:klaro/models/app_user.dart';
import 'package:klaro/models/lesson.dart';
import 'package:klaro/data/sample_lessons.dart';
import 'package:klaro/screens/lesson_reading_screen.dart';
import 'package:klaro/services/local_storage_service.dart';
import 'package:klaro/services/firestore_service.dart';
import 'package:klaro/utils/helpers.dart';
import 'package:klaro/utils/theme.dart';
import 'package:klaro/widgets/translatable_text.dart';

/// ============================================================
/// My Progress Screen
/// ============================================================
/// Displays all quiz and AI assessment results with recent-first ordering.

class MyProgressScreen extends StatefulWidget {
  final AppUser user;

  const MyProgressScreen({super.key, required this.user});

  @override
  State<MyProgressScreen> createState() => _MyProgressScreenState();
}

class _MyProgressScreenState extends State<MyProgressScreen> {
  final LocalStorageService _localStorage = LocalStorageService();
  final FirestoreService _firestoreService = FirestoreService();
  
  List<QuizResponse> _quizResults = [];
  List<AIConversation> _assessmentResults = [];
  bool _isLoading = true;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Try to load from Firestore first
      if (_firestoreService.isAvailable) {
        final quizzes = await _firestoreService.getQuizResults(widget.user.uid);
        final assessments = await _firestoreService.getAssessmentResults(widget.user.uid);
        
        if (quizzes.isNotEmpty || assessments.isNotEmpty) {
          setState(() {
            _quizResults = quizzes;
            _assessmentResults = assessments;
            _isOnline = true;
          });
        } else {
          // Fallback to local storage
          await _loadLocalData();
        }
      } else {
        // Load from local storage
        await _loadLocalData();
      }
    } catch (e) {
      debugPrint('Error loading from Firestore: $e');
      await _loadLocalData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadLocalData() async {
    final quizzes = await _localStorage.getAllQuizResponses(userId: widget.user.uid);
    final assessments = await _localStorage.getAllAIConversations(userId: widget.user.uid);
    
    setState(() {
      _quizResults = quizzes;
      _assessmentResults = assessments;
      _isOnline = false;
    });
  }

  Lesson? _findLessonById(String lessonId) {
    // Search through all subjects and modules to find the lesson
    for (final subject in SampleLessons.subjects) {
      for (final module in subject.modules) {
        for (final lesson in module.lessons) {
          if (lesson.id == lessonId) {
            return lesson;
          }
        }
      }
    }
    return null;
  }

  void _navigateToLesson(String lessonId, String lessonTitle) {
    final lesson = _findLessonById(lessonId);
    
    if (lesson != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LessonReadingScreen(lesson: lesson),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lesson not found: $lessonTitle'),
          backgroundColor: KlaroTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: KlaroTheme.primaryBlue))
            : _quizResults.isEmpty && _assessmentResults.isEmpty
                ? _buildEmptyState()
                : _buildProgressList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: 100),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assessment_outlined,
                size: 64,
                color: KlaroTheme.textMuted.withOpacity(0.3),
              ),
              SizedBox(height: 16),
              TranslatableText(
                'No results yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: KlaroTheme.textDark,
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: TranslatableText(
                  'Complete lessons and assessments to see your progress here.',
                  style: TextStyle(
                    fontSize: 14,
                    color: KlaroTheme.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressList() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient background
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  KlaroTheme.primaryBlue,
                  KlaroTheme.primaryBlue.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: KlaroTheme.primaryBlue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.assessment_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Progress',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${_quizResults.length + _assessmentResults.length} result(s)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_isOnline)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.cloud_off, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Offline',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Quiz Results Section
          if (_quizResults.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: KlaroTheme.accentYellow.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.quiz,
                    size: 18,
                    color: KlaroTheme.accentYellow.withRed(200),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Quiz Results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: KlaroTheme.textDark,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: KlaroTheme.accentYellow.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_quizResults.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: KlaroTheme.accentYellow.withRed(200),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ..._quizResults.map((quiz) => _buildQuizCard(quiz)),
            SizedBox(height: 24),
          ],

          // AI Assessment Results Section
          if (_assessmentResults.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: KlaroTheme.primaryBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.psychology,
                    size: 18,
                    color: KlaroTheme.primaryBlue,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'AI Assessment Results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: KlaroTheme.textDark,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: KlaroTheme.primaryBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_assessmentResults.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: KlaroTheme.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ..._assessmentResults.map((assessment) => _buildAssessmentCard(assessment)),
          ],
        ],
      ),
    );
  }

  Widget _buildQuizCard(QuizResponse quiz) {
    final isHighScore = quiz.percentage >= 80;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isHighScore 
              ? [Colors.white, KlaroTheme.success.withOpacity(0.05)]
              : [Colors.white, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighScore 
              ? KlaroTheme.success.withOpacity(0.3)
              : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isHighScore 
                ? KlaroTheme.success.withOpacity(0.1)
                : Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToLesson(quiz.lessonId, quiz.lessonTitle),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon badge
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isHighScore 
                            ? KlaroTheme.success.withOpacity(0.15)
                            : KlaroTheme.accentYellow.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isHighScore ? Icons.emoji_events : Icons.quiz,
                        color: isHighScore ? KlaroTheme.success : KlaroTheme.accentYellow.withRed(200),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    // Title and score
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quiz.lessonTitle,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: KlaroTheme.textDark,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 4),
                          // Subject badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              quiz.subject,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: KlaroTheme.textMuted,
                              ),
                            ),
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: quiz.percentage >= 70
                                      ? KlaroTheme.success.withOpacity(0.15)
                                      : KlaroTheme.warning.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${quiz.percentage}%',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: quiz.percentage >= 70
                                        ? KlaroTheme.success
                                        : KlaroTheme.warning,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${quiz.score}/${quiz.total}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: KlaroTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // Metadata row
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: KlaroTheme.textMuted),
                      SizedBox(width: 6),
                      Text(
                        Helpers.formatDate(quiz.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: KlaroTheme.textMuted,
                        ),
                      ),
                      if (quiz.attemptCount > 1) ...[
                        SizedBox(width: 16),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: KlaroTheme.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.refresh, size: 12, color: KlaroTheme.primaryBlue),
                              SizedBox(width: 4),
                              Text(
                                'Attempt ${quiz.attemptCount}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: KlaroTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentCard(AIConversation assessment) {
    final isHighScore = assessment.score >= 80;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isHighScore 
              ? [Colors.white, KlaroTheme.primaryBlue.withOpacity(0.05)]
              : [Colors.white, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighScore 
              ? KlaroTheme.primaryBlue.withOpacity(0.3)
              : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isHighScore 
                ? KlaroTheme.primaryBlue.withOpacity(0.1)
                : Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToLesson(assessment.lessonId, assessment.lessonTitle),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon badge
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isHighScore 
                            ? KlaroTheme.primaryBlue.withOpacity(0.15)
                            : KlaroTheme.lightBlue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isHighScore ? Icons.psychology : Icons.chat_bubble_outline,
                        color: isHighScore ? KlaroTheme.primaryBlue : KlaroTheme.lightBlue,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    // Title and score
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assessment.lessonTitle,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: KlaroTheme.textDark,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 4),
                          // Subject badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              assessment.subject,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: KlaroTheme.textMuted,
                              ),
                            ),
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: assessment.score >= 70
                                      ? KlaroTheme.success.withOpacity(0.15)
                                      : KlaroTheme.warning.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${assessment.score.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: assessment.score >= 70
                                        ? KlaroTheme.success
                                        : KlaroTheme.warning,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${assessment.correctAnswers}/${assessment.totalAttempts}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: KlaroTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (assessment.summary.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: KlaroTheme.lightBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline, 
                          size: 14, 
                          color: KlaroTheme.primaryBlue,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            assessment.summary,
                            style: TextStyle(
                              fontSize: 12,
                              color: KlaroTheme.textDark,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 12),
                // Metadata row
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: KlaroTheme.textMuted),
                      SizedBox(width: 6),
                      Text(
                        Helpers.formatDate(assessment.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: KlaroTheme.textMuted,
                        ),
                      ),
                      if (assessment.attemptCount > 1) ...[
                        SizedBox(width: 16),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: KlaroTheme.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.refresh, size: 12, color: KlaroTheme.primaryBlue),
                              SizedBox(width: 4),
                              Text(
                                'Attempt ${assessment.attemptCount}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: KlaroTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

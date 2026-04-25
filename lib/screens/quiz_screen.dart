import 'package:flutter/material.dart';
import 'package:klaro/models/lesson.dart';
import 'package:klaro/models/quiz_question.dart';
import 'package:klaro/models/quiz_response.dart';
import 'package:klaro/models/app_user.dart';
import 'package:klaro/services/gemini_service.dart';
import 'package:klaro/services/local_storage_service.dart';
import 'package:klaro/services/firestore_service.dart';
import 'package:klaro/screens/ai_assessment_screen.dart';
import 'package:klaro/widgets/quiz_card.dart';
import 'package:klaro/utils/theme.dart';
import 'package:klaro/widgets/translatable_text.dart';

/// ============================================================
/// Quiz Screen
/// ============================================================
/// Generates and displays comprehension quiz questions using Gemini.
/// Shows results and links to the AI Assessment.

class QuizScreen extends StatefulWidget {
  final Lesson lesson;

  const QuizScreen({super.key, required this.lesson});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final GeminiService _geminiService = GeminiService();
  final LocalStorageService _localStorage = LocalStorageService();
  final FirestoreService _firestoreService = FirestoreService();

  List<QuizQuestion> _questions = [];
  List<String> _studentAnswers = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _showResults = false;
  int _score = 0;
  int _total = 0;
  String? _errorMessage;
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _generateQuiz();
  }

  Future<void> _loadUser() async {
    final user = await _localStorage.getUser();
    if (mounted) {
      setState(() => _user = user);
    }
  }

  Future<void> _generateQuiz() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final questions = await _geminiService.generateQuizQuestions(
        widget.lesson.content,
      );
      setState(() {
        _questions = questions;
        _studentAnswers = List.filled(questions.length, '');
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate quiz. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _submitQuiz() async {
    // Check if all questions are answered
    final unanswered = _studentAnswers.indexWhere((a) => a.trim().isEmpty);
    if (unanswered != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TranslatableText('Please answer all questions before submitting.'),
          backgroundColor: KlaroTheme.warning,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await _geminiService.evaluateQuizAnswers(
        _questions,
        _studentAnswers,
      );

      _score = result['score'] ?? 0;
      _total = result['total'] ?? _questions.length;
      final results = result['results'] as List? ?? [];

      // Update questions with feedback
      for (int i = 0; i < _questions.length && i < results.length; i++) {
        final r = results[i];
        _questions[i].isCorrect = r['isCorrect'] ?? false;
        _questions[i].feedback = r['feedback'] ?? '';
        _questions[i].studentAnswer = _studentAnswers[i];
      }

      // Save quiz response locally
      final quizResponse = QuizResponse(
        lessonId: widget.lesson.id,
        lessonTitle: widget.lesson.title,
        subject: widget.lesson.subject,
        score: _score,
        total: _total,
        date: DateTime.now(),
      );
      await _localStorage.saveQuizResponse(quizResponse, userId: _user?.uid);

      // Save to Firestore if available and user is loaded
      if (_user != null) {
        try {
          await _firestoreService.saveQuizResult(_user!.uid, quizResponse);
        } catch (e) {
          debugPrint('Failed to save quiz to Firestore: $e');
        }
      }

      setState(() {
        _showResults = true;
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: TranslatableText('Failed to evaluate quiz. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KlaroTheme.surfaceLight,
      appBar: AppBar(
        title: TranslatableText('Comprehension Quiz'),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildQuizContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: KlaroTheme.primaryBlue),
          SizedBox(height: 20),
          TranslatableText(
            'Generating quiz questions...',
            style: TextStyle(
              fontSize: 16,
              color: KlaroTheme.textMuted,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TranslatableText(
                'Based on: ',
                style: TextStyle(
                  fontSize: 13,
                  color: KlaroTheme.textMuted,
                ),
              ),
              Text(
                widget.lesson.title,
                style: TextStyle(
                  fontSize: 13,
                  color: KlaroTheme.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: KlaroTheme.error),
          SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: TextStyle(fontSize: 16, color: KlaroTheme.textDark),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _generateQuiz,
            child: TranslatableText('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: _showResults ? 1.0 : _answeredCount / _questions.length,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation(
            _showResults ? KlaroTheme.success : KlaroTheme.accentYellow,
          ),
          minHeight: 4,
        ),

        // Score banner (after submission)
        if (_showResults)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            color: _score >= (_total * 0.7)
                ? KlaroTheme.success.withOpacity(0.1)
                : KlaroTheme.warning.withOpacity(0.1),
            child: Column(
              children: [
                Text(
                  '$_score / $_total',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: _score >= (_total * 0.7)
                        ? KlaroTheme.success
                        : KlaroTheme.warning,
                  ),
                ),
                SizedBox(height: 4),
                TranslatableText(
                  _score >= (_total * 0.7)
                      ? 'Great job! You understood the lesson well.'
                      : 'Keep going! Review the lesson and try again.',
                  style: TextStyle(
                    fontSize: 14,
                    color: KlaroTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),

        // Questions list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              return QuizCard(
                question: _questions[index],
                questionNumber: index + 1,
                totalQuestions: _questions.length,
                showResult: _showResults,
                onAnswerChanged: (answer) {
                  setState(() => _studentAnswers[index] = answer);
                },
              );
            },
          ),
        ),

        // Bottom action bar
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: _showResults
                ? ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AIAssessmentScreen(
                            lesson: widget.lesson,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.assessment_outlined),
                    label: TranslatableText('Start Assessment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KlaroTheme.primaryBlue,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KlaroTheme.accentYellow,
                      foregroundColor: KlaroTheme.textDark,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: KlaroTheme.textDark,
                            ),
                          )
                        : TranslatableText('Submit Answers'),
                  ),
          ),
        ),
      ],
    );
  }

  int get _answeredCount =>
      _studentAnswers.where((a) => a.trim().isNotEmpty).length;
}

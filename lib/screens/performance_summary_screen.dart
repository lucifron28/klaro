import 'package:flutter/material.dart';
import 'package:klaro/models/lesson.dart';
import 'package:klaro/services/local_storage_service.dart';
import 'package:klaro/widgets/score_card.dart';
import 'package:klaro/utils/helpers.dart';
import 'package:klaro/utils/theme.dart';

/// ============================================================
/// Performance Summary Screen
/// ============================================================
/// Shows the student's combined performance from quiz + AI conversation.

class PerformanceSummaryScreen extends StatelessWidget {
  final Lesson lesson;
  final int quizScore;
  final int quizTotal;
  final double aiScore;
  final String aiSummary;

  const PerformanceSummaryScreen({
    super.key,
    required this.lesson,
    required this.quizScore,
    required this.quizTotal,
    required this.aiScore,
    required this.aiSummary,
  });

  @override
  Widget build(BuildContext context) {
    final quizPercent = Helpers.calculatePercentage(quizScore, quizTotal);
    final overallPercent = Helpers.calculateOverallScore(quizPercent, aiScore);
    final grade = Helpers.getGradeLabel(overallPercent);
    final message = Helpers.getPerformanceMessage(overallPercent);

    // Mark lesson as completed
    LocalStorageService().markLessonCompleted(lesson.id);

    return Scaffold(
      backgroundColor: KlaroTheme.surfaceLight,
      appBar: AppBar(
        title: Text('Performance Summary'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Overall Score Card
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [KlaroTheme.primaryBlue, Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: KlaroTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Overall Score',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$overallPercent',
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          '%',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Grade: $grade',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    lesson.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Score breakdown
            Row(
              children: [
                Expanded(
                  child: ScoreCard(
                    label: 'Quiz Score',
                    value: '$quizScore/$quizTotal',
                    subtitle: '$quizPercent%',
                    icon: Icons.quiz_rounded,
                    color: KlaroTheme.accentYellow.withRed(200),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ScoreCard(
                    label: 'AI Assessment',
                    value: '${aiScore.toStringAsFixed(1)}/5',
                    subtitle: '${((aiScore / 5) * 100).round()}%',
                    icon: Icons.chat_bubble_rounded,
                    color: KlaroTheme.primaryBlue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Performance message
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: KlaroTheme.accentYellow, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Feedback',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: KlaroTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: KlaroTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),

            // AI Summary
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: KlaroTheme.lightBlue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'AI Tutor Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: KlaroTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    aiSummary,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: KlaroTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Action buttons
            ElevatedButton.icon(
              onPressed: () {
                // Pop back to home screen
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: Icon(Icons.home_rounded),
              label: Text('Back to Lessons'),
              style: ElevatedButton.styleFrom(
                backgroundColor: KlaroTheme.primaryBlue,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Go back to AI conversation
              },
              icon: Icon(Icons.replay_rounded),
              label: Text('Review Conversation'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:klaro/models/learned_concept.dart';
import 'package:klaro/models/lesson.dart';
import 'package:klaro/screens/quiz_screen.dart';
import 'package:klaro/utils/theme.dart';
import 'package:klaro/widgets/translatable_text.dart';

/// ============================================================
/// Learning Recap Screen
/// ============================================================
/// Reviews words and concepts the student explored before the quiz.

class LearningRecapScreen extends StatelessWidget {
  final Lesson lesson;
  final List<LearnedConcept> learnedConcepts;

  const LearningRecapScreen({
    super.key,
    required this.lesson,
    required this.learnedConcepts,
  });

  @override
  Widget build(BuildContext context) {
    final concepts = [...learnedConcepts]
      ..sort((a, b) => a.selectedAt.compareTo(b.selectedAt));

    return Scaffold(
      backgroundColor: KlaroTheme.surfaceLight,
      appBar: AppBar(
        title: TranslatableText('Learning Recap'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, 16, 20, 18),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: KlaroTheme.textDark,
                  ),
                ),
                SizedBox(height: 6),
                TranslatableText(
                  concepts.isEmpty
                      ? 'Review the concepts you explored below before the quiz.'
                      : 'Review your personalized learning recap before starting the quiz.',
                  style: TextStyle(
                    fontSize: 14,
                    color: KlaroTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                if (concepts.isEmpty)
                  _buildEmptyState()
                else
                  ...concepts.map(_buildConceptCard),
              ],
            ),
          ),
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
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(lesson: lesson),
                    ),
                  );
                },
                icon: Icon(Icons.quiz_rounded),
                label: TranslatableText('Start Quiz'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KlaroTheme.accentYellow,
                  foregroundColor: KlaroTheme.textDark,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.touch_app_rounded, color: KlaroTheme.primaryBlue),
          SizedBox(width: 12),
          Expanded(
            child: TranslatableText(
              'Your learning recap will appear here after you tap words you want to learn more about while reading.',
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: KlaroTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConceptCard(LearnedConcept concept) {
    return Container(
      margin: EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: KlaroTheme.lightBlue.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  concept.word,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: KlaroTheme.primaryBlue,
                  ),
                ),
              ),
              Spacer(),
              Icon(Icons.check_circle, color: KlaroTheme.success, size: 20),
            ],
          ),
          SizedBox(height: 14),
          _buildRecapLine(
            icon: Icons.lightbulb_outline,
            color: KlaroTheme.accentYellow,
            text: concept.explanation,
          ),
          SizedBox(height: 10),
          _buildRecapLine(
            icon: Icons.translate,
            color: KlaroTheme.lightBlue,
            text: concept.tagalog,
          ),
        ],
      ),
    );
  }

  Widget _buildRecapLine({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: KlaroTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

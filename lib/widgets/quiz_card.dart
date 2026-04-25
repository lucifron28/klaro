import 'package:flutter/material.dart';
import 'package:klaro/models/quiz_question.dart';
import 'package:klaro/utils/theme.dart';

/// ============================================================
/// Quiz Card Widget
/// ============================================================
/// Displays a single quiz question with answer input.

class QuizCard extends StatefulWidget {
  final QuizQuestion question;
  final int questionNumber;
  final int totalQuestions;
  final ValueChanged<String> onAnswerChanged;
  final bool showResult;

  const QuizCard({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.onAnswerChanged,
    this.showResult = false,
  });

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  String? _selectedChoice;
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.showResult
              ? (widget.question.isCorrect == true
                  ? KlaroTheme.success.withOpacity(0.3)
                  : KlaroTheme.error.withOpacity(0.3))
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: KlaroTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Q${widget.questionNumber}/${widget.totalQuestions}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: KlaroTheme.primaryBlue,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.question.type == QuestionType.multipleChoice
                      ? KlaroTheme.lightBlue.withOpacity(0.2)
                      : KlaroTheme.accentYellow.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.question.type == QuestionType.multipleChoice
                      ? 'Multiple Choice'
                      : 'Short Answer',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: KlaroTheme.textDark,
                  ),
                ),
              ),
              if (widget.showResult) ...[
                Spacer(),
                Icon(
                  widget.question.isCorrect == true
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: widget.question.isCorrect == true
                      ? KlaroTheme.success
                      : KlaroTheme.error,
                  size: 24,
                ),
              ],
            ],
          ),
          SizedBox(height: 16),

          // Question text
          Text(
            widget.question.question,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: KlaroTheme.textDark,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16),

          // Answer input
          if (widget.question.type == QuestionType.multipleChoice)
            _buildMultipleChoice()
          else
            _buildShortAnswer(),

          // Feedback (after submission)
          if (widget.showResult && widget.question.feedback != null) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.question.isCorrect == true
                    ? KlaroTheme.success.withOpacity(0.1)
                    : KlaroTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: widget.question.isCorrect == true
                        ? KlaroTheme.success
                        : KlaroTheme.error,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.question.feedback!,
                      style: TextStyle(
                        fontSize: 13,
                        color: KlaroTheme.textDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMultipleChoice() {
    return Column(
      children: (widget.question.choices ?? []).map((choice) {
        final isSelected = _selectedChoice == choice;
        final isCorrectAnswer = widget.showResult &&
            choice == widget.question.correctAnswer;
        final isWrongSelection = widget.showResult &&
            isSelected &&
            widget.question.isCorrect == false;

        return GestureDetector(
          onTap: widget.showResult
              ? null
              : () {
                  setState(() => _selectedChoice = choice);
                  widget.onAnswerChanged(choice);
                },
          child: Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isCorrectAnswer
                  ? KlaroTheme.success.withOpacity(0.1)
                  : isWrongSelection
                      ? KlaroTheme.error.withOpacity(0.1)
                      : isSelected
                          ? KlaroTheme.primaryBlue.withOpacity(0.08)
                          : KlaroTheme.surfaceLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isCorrectAnswer
                    ? KlaroTheme.success
                    : isWrongSelection
                        ? KlaroTheme.error
                        : isSelected
                            ? KlaroTheme.primaryBlue
                            : Colors.grey.shade200,
                width: isSelected || isCorrectAnswer || isWrongSelection ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    choice,
                    style: TextStyle(
                      fontSize: 14,
                      color: KlaroTheme.textDark,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (isCorrectAnswer)
                  Icon(Icons.check_circle, color: KlaroTheme.success, size: 20),
                if (isWrongSelection)
                  Icon(Icons.cancel, color: KlaroTheme.error, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildShortAnswer() {
    return TextField(
      controller: _textController,
      enabled: !widget.showResult,
      maxLines: 3,
      onChanged: widget.onAnswerChanged,
      decoration: InputDecoration(
        hintText: 'Type your answer here...',
        filled: true,
        fillColor: KlaroTheme.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}

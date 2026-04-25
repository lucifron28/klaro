/// ============================================================
/// Quiz Question Model
/// ============================================================

enum QuestionType { multipleChoice, shortAnswer }

class QuizQuestion {
  final String question;
  final QuestionType type;
  final List<String>? choices;       // For multiple choice
  final String correctAnswer;
  String? studentAnswer;
  bool? isCorrect;
  String? feedback;

  QuizQuestion({
    required this.question,
    required this.type,
    this.choices,
    required this.correctAnswer,
    this.studentAnswer,
    this.isCorrect,
    this.feedback,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'type': type == QuestionType.multipleChoice ? 'multipleChoice' : 'shortAnswer',
      'choices': choices,
      'correctAnswer': correctAnswer,
      'studentAnswer': studentAnswer,
      'isCorrect': isCorrect,
      'feedback': feedback,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      question: map['question'] ?? '',
      type: map['type'] == 'multipleChoice'
          ? QuestionType.multipleChoice
          : QuestionType.shortAnswer,
      choices: map['choices'] != null ? List<String>.from(map['choices']) : null,
      correctAnswer: map['correctAnswer'] ?? '',
      studentAnswer: map['studentAnswer'],
      isCorrect: map['isCorrect'],
      feedback: map['feedback'],
    );
  }
}

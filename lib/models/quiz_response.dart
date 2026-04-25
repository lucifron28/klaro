/// ============================================================
/// Quiz Response Model
/// ============================================================

class QuizResponse {
  final String lessonId;
  final String lessonTitle;
  final int score;
  final int total;
  final int percentage;
  final DateTime date;
  final List<Map<String, dynamic>>? questionResults;

  QuizResponse({
    required this.lessonId,
    required this.lessonTitle,
    required this.score,
    required this.total,
    required this.date,
    this.questionResults,
  }) : percentage = total > 0 ? ((score / total) * 100).round() : 0;

  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'lessonTitle': lessonTitle,
      'score': score,
      'total': total,
      'percentage': percentage,
      'date': date.toIso8601String(),
      'questionResults': questionResults,
    };
  }

  factory QuizResponse.fromMap(Map<dynamic, dynamic> map) {
    final score = map['score'] ?? 0;
    final total = map['total'] ?? 0;
    return QuizResponse(
      lessonId: map['lessonId'] ?? '',
      lessonTitle: map['lessonTitle'] ?? '',
      score: score,
      total: total,
      date: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : DateTime.now(),
      questionResults: map['questionResults'] != null
          ? List<Map<String, dynamic>>.from(map['questionResults'])
          : null,
    );
  }
}

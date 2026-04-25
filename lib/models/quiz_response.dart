/// ============================================================
/// Quiz Response Model
/// ============================================================

class QuizResponse {
  final String lessonId;
  final String lessonTitle;
  final String subject;
  final int score;
  final int total;
  final int percentage;
  final DateTime date;
  final int attemptCount;
  final DateTime? firstAttemptDate;

  QuizResponse({
    required this.lessonId,
    required this.lessonTitle,
    required this.subject,
    required this.score,
    required this.total,
    required this.date,
    this.attemptCount = 1,
    this.firstAttemptDate,
  }) : percentage = total > 0 ? ((score / total) * 100).round() : 0;

  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'lessonTitle': lessonTitle,
      'subject': subject,
      'score': score,
      'total': total,
      'percentage': percentage,
      'date': date.toIso8601String(),
      'timestamp': date.toIso8601String(),
      'attemptCount': attemptCount,
      'firstAttemptDate': firstAttemptDate?.toIso8601String(),
    };
  }

  factory QuizResponse.fromMap(Map<dynamic, dynamic> map) {
    final score = map['score'] ?? 0;
    final total = map['total'] ?? 0;
    // Handle backward compatibility: try 'subject' first, then 'schoolSubject'
    final subject = map['subject'] ?? map['schoolSubject'] ?? 'Unknown';
    return QuizResponse(
      lessonId: map['lessonId'] ?? '',
      lessonTitle: map['lessonTitle'] ?? '',
      subject: subject,
      score: score,
      total: total,
      date: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : (map['timestamp'] != null
              ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
              : DateTime.now()),
      attemptCount: map['attemptCount'] ?? 1,
      firstAttemptDate: map['firstAttemptDate'] != null
          ? DateTime.tryParse(map['firstAttemptDate'])
          : null,
    );
  }
}

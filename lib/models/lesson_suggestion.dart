/// ============================================================
/// Lesson Suggestion Model
/// ============================================================
/// AI-generated suggestions for teachers to help struggling students

class LessonSuggestion {
  final String studentId;
  final String studentName;
  final String topic;
  final String subject;
  final double currentScore;
  final String difficulty;
  final List<String> recommendations;
  final List<String> focusAreas;
  final String teachingStrategy;
  final DateTime generatedAt;

  LessonSuggestion({
    required this.studentId,
    required this.studentName,
    required this.topic,
    required this.subject,
    required this.currentScore,
    required this.difficulty,
    required this.recommendations,
    required this.focusAreas,
    required this.teachingStrategy,
    required this.generatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'topic': topic,
      'subject': subject,
      'currentScore': currentScore,
      'difficulty': difficulty,
      'recommendations': recommendations,
      'focusAreas': focusAreas,
      'teachingStrategy': teachingStrategy,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory LessonSuggestion.fromMap(Map<String, dynamic> map) {
    return LessonSuggestion(
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      topic: map['topic'] ?? '',
      subject: map['subject'] ?? '',
      currentScore: (map['currentScore'] ?? 0).toDouble(),
      difficulty: map['difficulty'] ?? '',
      recommendations: List<String>.from(map['recommendations'] ?? []),
      focusAreas: List<String>.from(map['focusAreas'] ?? []),
      teachingStrategy: map['teachingStrategy'] ?? '',
      generatedAt: map['generatedAt'] != null
          ? DateTime.parse(map['generatedAt'])
          : DateTime.now(),
    );
  }
}

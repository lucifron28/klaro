/// ============================================================
/// Learned Concept Model
/// ============================================================
/// Stores words a student tapped while reading a lesson.

class LearnedConcept {
  final String word;
  final String explanation;
  final String tagalog;
  final DateTime selectedAt;

  LearnedConcept({
    required this.word,
    required this.explanation,
    required this.tagalog,
    required this.selectedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'explanation': explanation,
      'tagalog': tagalog,
      'selectedAt': selectedAt.toIso8601String(),
    };
  }

  factory LearnedConcept.fromMap(Map<dynamic, dynamic> map) {
    return LearnedConcept(
      word: map['word']?.toString() ?? '',
      explanation: map['explanation']?.toString() ?? '',
      tagalog: map['tagalog']?.toString() ?? '',
      selectedAt: DateTime.tryParse(map['selectedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

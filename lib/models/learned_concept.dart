/// ============================================================
/// Learned Concept Model
/// ============================================================
/// Stores words a student tapped while reading a lesson.

class LearnedConcept {
  final String word;
  final String explanation;
  final String tagalog;
  final String languageCode;
  final DateTime selectedAt;

  LearnedConcept({
    required this.word,
    required this.explanation,
    required this.tagalog,
    this.languageCode = 'tl',
    required this.selectedAt,
  });

  LearnedConcept copyWith({
    String? word,
    String? explanation,
    String? tagalog,
    String? languageCode,
    DateTime? selectedAt,
  }) {
    return LearnedConcept(
      word: word ?? this.word,
      explanation: explanation ?? this.explanation,
      tagalog: tagalog ?? this.tagalog,
      languageCode: languageCode ?? this.languageCode,
      selectedAt: selectedAt ?? this.selectedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'explanation': explanation,
      'tagalog': tagalog,
      'languageCode': languageCode,
      'selectedAt': selectedAt.toIso8601String(),
    };
  }

  factory LearnedConcept.fromMap(Map<dynamic, dynamic> map) {
    return LearnedConcept(
      word: map['word']?.toString() ?? '',
      explanation: map['explanation']?.toString() ?? '',
      tagalog: map['tagalog']?.toString() ?? '',
      languageCode: map['languageCode']?.toString() ??
          map['dialectCode']?.toString() ??
          'tl',
      selectedAt: DateTime.tryParse(map['selectedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

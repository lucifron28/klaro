/// ============================================================
/// Lesson Model
/// ============================================================

class Lesson {
  final String id;
  final String title;
  final String subject;
  final String gradeLevel;
  final String content;
  final List<String> keyTerms;
  final DateTime? dateCompleted;

  Lesson({
    required this.id,
    required this.title,
    required this.subject,
    required this.gradeLevel,
    required this.content,
    this.keyTerms = const [],
    this.dateCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'gradeLevel': gradeLevel,
      'content': content,
      'keyTerms': keyTerms,
      'dateCompleted': dateCompleted?.toIso8601String(),
    };
  }

  factory Lesson.fromMap(Map<dynamic, dynamic> map) {
    return Lesson(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      gradeLevel: map['gradeLevel'] ?? '',
      content: map['content'] ?? '',
      keyTerms: List<String>.from(map['keyTerms'] ?? []),
      dateCompleted: map['dateCompleted'] != null
          ? DateTime.tryParse(map['dateCompleted'])
          : null,
    );
  }

  Lesson copyWith({
    String? id,
    String? title,
    String? subject,
    String? gradeLevel,
    String? content,
    List<String>? keyTerms,
    DateTime? dateCompleted,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      content: content ?? this.content,
      keyTerms: keyTerms ?? this.keyTerms,
      dateCompleted: dateCompleted ?? this.dateCompleted,
    );
  }
}

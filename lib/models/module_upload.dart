/// ============================================================
/// Module Upload Model
/// ============================================================
/// Represents a custom module/lesson uploaded by a teacher.
/// Collection: teachers/{teacherId}/modules/{moduleId}

class ModuleUpload {
  final String id;
  final String teacherId;
  final String title;
  final String subject;
  final String gradeLevel;
  final String description;
  final String content;
  final List<String> keyTerms;
  final List<String> learningObjectives;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;
  final String? quarter;
  final int? orderIndex;

  ModuleUpload({
    required this.id,
    required this.teacherId,
    required this.title,
    required this.subject,
    required this.gradeLevel,
    required this.description,
    required this.content,
    this.keyTerms = const [],
    this.learningObjectives = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isPublished = false,
    this.quarter,
    this.orderIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherId': teacherId,
      'title': title,
      'subject': subject,
      'gradeLevel': gradeLevel,
      'description': description,
      'content': content,
      'keyTerms': keyTerms,
      'learningObjectives': learningObjectives,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPublished': isPublished,
      'quarter': quarter,
      'orderIndex': orderIndex,
    };
  }

  factory ModuleUpload.fromMap(Map<String, dynamic> map) {
    return ModuleUpload(
      id: map['id'] ?? '',
      teacherId: map['teacherId'] ?? '',
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      gradeLevel: map['gradeLevel'] ?? '',
      description: map['description'] ?? '',
      content: map['content'] ?? '',
      keyTerms: List<String>.from(map['keyTerms'] ?? []),
      learningObjectives: List<String>.from(map['learningObjectives'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      isPublished: map['isPublished'] ?? false,
      quarter: map['quarter'],
      orderIndex: map['orderIndex'],
    );
  }

  ModuleUpload copyWith({
    String? title,
    String? subject,
    String? gradeLevel,
    String? description,
    String? content,
    List<String>? keyTerms,
    List<String>? learningObjectives,
    bool? isPublished,
    String? quarter,
    int? orderIndex,
  }) {
    return ModuleUpload(
      id: id,
      teacherId: teacherId,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      description: description ?? this.description,
      content: content ?? this.content,
      keyTerms: keyTerms ?? this.keyTerms,
      learningObjectives: learningObjectives ?? this.learningObjectives,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isPublished: isPublished ?? this.isPublished,
      quarter: quarter ?? this.quarter,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}

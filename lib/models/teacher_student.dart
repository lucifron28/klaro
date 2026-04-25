/// ============================================================
/// Teacher-Student Relationship Model
/// ============================================================
/// Represents the connection between a teacher and their students.
/// Collection: teachers/{teacherId}/students/{studentId}

class TeacherStudent {
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String gradeLevel;
  final DateTime enrolledAt;
  final String? section;

  TeacherStudent({
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.gradeLevel,
    required this.enrolledAt,
    this.section,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'gradeLevel': gradeLevel,
      'enrolledAt': enrolledAt.toIso8601String(),
      'section': section,
    };
  }

  factory TeacherStudent.fromMap(Map<String, dynamic> map) {
    return TeacherStudent(
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      studentEmail: map['studentEmail'] ?? '',
      gradeLevel: map['gradeLevel'] ?? '',
      enrolledAt: map['enrolledAt'] != null
          ? DateTime.parse(map['enrolledAt'])
          : DateTime.now(),
      section: map['section'],
    );
  }
}

/// ============================================================
/// Student Progress Summary
/// ============================================================
/// Aggregated progress data for a student

class StudentProgressSummary {
  final String studentId;
  final String studentName;
  final String studentEmail;
  final int totalLessonsCompleted;
  final int totalQuizzesTaken;
  final double averageQuizScore;
  final int totalAIAssessments;
  final double averageAIScore;
  final double overallProgress;
  final List<String> strugglingTopics;
  final DateTime lastActivity;

  StudentProgressSummary({
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    this.totalLessonsCompleted = 0,
    this.totalQuizzesTaken = 0,
    this.averageQuizScore = 0.0,
    this.totalAIAssessments = 0,
    this.averageAIScore = 0.0,
    this.overallProgress = 0.0,
    this.strugglingTopics = const [],
    required this.lastActivity,
  });

  String get statusLabel {
    if (overallProgress >= 90) return 'Excellent';
    if (overallProgress >= 75) return 'Good';
    if (overallProgress >= 60) return 'Satisfactory';
    return 'Needs Support';
  }

  bool get needsAttention => overallProgress < 60 || strugglingTopics.isNotEmpty;
}

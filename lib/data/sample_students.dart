/// ============================================================
/// Sample Students (Hardcoded for Teacher Dashboard Demo)
/// ============================================================

class SampleStudent {
  final String name;
  final String email;
  final int quizScore;
  final int quizTotal;
  final double aiScore;
  final int overallPercent;
  final String status;

  SampleStudent({
    required this.name,
    required this.email,
    required this.quizScore,
    required this.quizTotal,
    required this.aiScore,
    required this.overallPercent,
    required this.status,
  });
}

class SampleStudents {
  SampleStudents._();

  static final List<SampleStudent> students = [
    SampleStudent(
      name: 'Maria Santos',
      email: 'maria@test.com',
      quizScore: 2,
      quizTotal: 3,
      aiScore: 4.5,
      overallPercent: 73,
      status: 'Completed',
    ),
    SampleStudent(
      name: 'Juan Dela Cruz',
      email: 'juan@test.com',
      quizScore: 3,
      quizTotal: 3,
      aiScore: 4.0,
      overallPercent: 90,
      status: 'Completed',
    ),
    SampleStudent(
      name: 'Ana Reyes',
      email: 'ana@test.com',
      quizScore: 1,
      quizTotal: 3,
      aiScore: 3.0,
      overallPercent: 47,
      status: 'Needs Review',
    ),
    SampleStudent(
      name: 'Carlo Garcia',
      email: 'carlo@test.com',
      quizScore: 2,
      quizTotal: 3,
      aiScore: 3.5,
      overallPercent: 68,
      status: 'Completed',
    ),
    SampleStudent(
      name: 'Bea Mendoza',
      email: 'bea@test.com',
      quizScore: 3,
      quizTotal: 3,
      aiScore: 5.0,
      overallPercent: 100,
      status: 'Excellent',
    ),
  ];
}

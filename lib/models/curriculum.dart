import 'package:klaro/models/lesson.dart';

class CurriculumSubject {
  final String id;
  final String title;
  final String gradeLevel;
  final String description;
  final List<CurriculumModule> modules;

  const CurriculumSubject({
    required this.id,
    required this.title,
    required this.gradeLevel,
    required this.description,
    required this.modules,
  });

  int get lessonCount =>
      modules.fold(0, (total, module) => total + module.lessons.length);

  List<Lesson> get lessons =>
      modules.expand((module) => module.lessons).toList(growable: false);
}

class CurriculumModule {
  final String id;
  final String subjectId;
  final String subjectTitle;
  final String gradeLevel;
  final String quarter;
  final String title;
  final String description;
  final List<Lesson> lessons;

  const CurriculumModule({
    required this.id,
    required this.subjectId,
    required this.subjectTitle,
    required this.gradeLevel,
    required this.quarter,
    required this.title,
    required this.description,
    required this.lessons,
  });
}

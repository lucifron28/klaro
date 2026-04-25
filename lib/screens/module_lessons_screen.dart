import 'package:flutter/material.dart';
import 'package:klaro/models/curriculum.dart';
import 'package:klaro/models/lesson.dart';
import 'package:klaro/screens/lesson_reading_screen.dart';
import 'package:klaro/utils/theme.dart';
import 'package:klaro/widgets/translatable_text.dart';

class ModuleLessonsScreen extends StatelessWidget {
  final CurriculumModule module;

  const ModuleLessonsScreen({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KlaroTheme.surfaceLight,
      appBar: AppBar(
        title: Text(module.quarter),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, 16, 20, 18),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: KlaroTheme.textDark,
                  ),
                ),
                SizedBox(height: 6),
                Wrap(
                  children: [
                    Text(
                      '${module.subjectTitle} ${module.gradeLevel.split(' ').last} - ${module.lessons.length} ',
                      style: TextStyle(
                        fontSize: 14,
                        color: KlaroTheme.textMuted,
                      ),
                    ),
                    TranslatableText(
                      'lessons',
                      style: TextStyle(
                        fontSize: 14,
                        color: KlaroTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(20),
              itemCount: module.lessons.length,
              itemBuilder: (context, index) {
                return _buildLessonCard(
                  context,
                  module.lessons[index],
                  index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, Lesson lesson, int index) {
    final color = index.isEven ? KlaroTheme.primaryBlue : Color(0xFF0F766E);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LessonReadingScreen(lesson: lesson),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      color: KlaroTheme.textDark,
                    ),
                  ),
                  TranslatableText(
                    'Tap to read lesson',
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 12,
                      color: KlaroTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: KlaroTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:klaro/models/curriculum.dart';
import 'package:klaro/screens/module_lessons_screen.dart';
import 'package:klaro/utils/theme.dart';
import 'package:klaro/widgets/translatable_text.dart';

class SubjectModulesScreen extends StatelessWidget {
  final CurriculumSubject subject;

  const SubjectModulesScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KlaroTheme.surfaceLight,
      appBar: AppBar(
        title: Text('${subject.title} ${subject.gradeLevel.split(' ').last}'),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Text(
            subject.description,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: KlaroTheme.textMuted,
            ),
          ),
          SizedBox(height: 18),
          TranslatableText(
            'Modules',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: KlaroTheme.textDark,
            ),
          ),
          SizedBox(height: 12),
          ...subject.modules.asMap().entries.map(
                (entry) => _buildModuleCard(
                  context,
                  entry.value,
                  entry.key,
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    CurriculumModule module,
    int index,
  ) {
    final colors = [
      KlaroTheme.primaryBlue,
      Color(0xFF0F766E),
      Color(0xFF7C3AED),
      Color(0xFFB45309),
    ];
    final color = colors[index % colors.length];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ModuleLessonsScreen(module: module),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 14),
        padding: EdgeInsets.all(18),
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
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 18,
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
                    module.quarter,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    module.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: KlaroTheme.textDark,
                    ),
                  ),
                  SizedBox(height: 5),
                  Wrap(
                    children: [
                      Text(
                        '${module.lessons.length} ',
                        style: TextStyle(
                          fontSize: 12,
                          color: KlaroTheme.textMuted,
                        ),
                      ),
                      TranslatableText(
                        'lessons',
                        style: TextStyle(
                          fontSize: 12,
                          color: KlaroTheme.textMuted,
                        ),
                      ),
                    ],
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

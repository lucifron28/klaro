import 'package:flutter/foundation.dart';
import 'package:klaro/models/lesson_suggestion.dart';
import 'package:klaro/models/teacher_student.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:klaro/utils/constants.dart';

/// ============================================================
/// Lesson Suggestion Service
/// ============================================================
/// Generates AI-powered teaching suggestions for struggling students

class LessonSuggestionService {
  /// Generate a model instance
  GenerativeModel _model(String modelName) {
    return FirebaseAI.googleAI().generativeModel(
      model: modelName,
      generationConfig: GenerationConfig(
        temperature: 0.3,
        maxOutputTokens: 2048,
      ),
    );
  }

  /// Core method: send a prompt and get text back
  Future<String> _generateText(String prompt) async {
    final modelNames = AppConstants.geminiModelFallbacks;

    for (var i = 0; i < modelNames.length; i++) {
      final modelName = modelNames[i];
      final isLastModel = i == modelNames.length - 1;
      final model = _model(modelName);

      try {
        final response = await model.generateContent([Content.text(prompt)]);
        final text = response.text;

        if (text == null || text.trim().isEmpty) {
          throw Exception('AI returned an empty response');
        }

        if (modelName != AppConstants.geminiModel) {
          debugPrint(
            'Lesson suggestion fallback succeeded with model: $modelName',
          );
        }
        return text.trim();
      } on FirebaseAIException catch (error) {
        debugPrint(
          'Lesson suggestion AI failed on $modelName: ${error.message}',
        );
        if (_shouldTryNextModel(error.message) && !isLastModel) {
          debugPrint(
            'Trying lesson suggestion fallback model: ${modelNames[i + 1]}',
          );
          continue;
        }
        rethrow;
      } catch (error) {
        debugPrint('AI generation error on $modelName: $error');
        rethrow;
      }
    }

    throw Exception('All configured Firebase AI models failed.');
  }

  bool _shouldTryNextModel(String message) {
    final normalized = message.toLowerCase();

    if (normalized.contains('api_key_invalid') ||
        normalized.contains('api key') ||
        normalized.contains('permission_denied') ||
        normalized.contains('permission denied') ||
        normalized.contains('service_disabled') ||
        normalized.contains('firebase ai logic api') ||
        normalized.contains('vertex ai in firebase api')) {
      return false;
    }

    return normalized.contains('quota') ||
        normalized.contains('rate limit') ||
        normalized.contains('rate-limit') ||
        normalized.contains('resource_exhausted') ||
        normalized.contains('too many requests') ||
        normalized.contains('429') ||
        normalized.contains('traffic') ||
        normalized.contains('overload') ||
        normalized.contains('overloaded') ||
        normalized.contains('unavailable') ||
        normalized.contains('503') ||
        normalized.contains('deadline') ||
        normalized.contains('timeout') ||
        normalized.contains('timed out') ||
        normalized.contains('internal') ||
        normalized.contains('500') ||
        normalized.contains('not found') ||
        normalized.contains('404') ||
        normalized.contains('model') && normalized.contains('not supported');
  }

  /// Generate lesson suggestions for a student based on their progress
  Future<List<LessonSuggestion>> generateSuggestions(
    StudentProgressSummary student,
  ) async {
    if (student.strugglingTopics.isEmpty) {
      return [];
    }

    final suggestions = <LessonSuggestion>[];

    for (final topic in student.strugglingTopics) {
      try {
        final suggestion = await _generateSuggestionForTopic(
          student,
          topic,
        );
        if (suggestion != null) {
          suggestions.add(suggestion);
        }
      } catch (e) {
        debugPrint('Error generating suggestion for $topic: $e');
      }
    }

    return suggestions;
  }

  Future<LessonSuggestion?> _generateSuggestionForTopic(
    StudentProgressSummary student,
    String topic,
  ) async {
    final prompt = '''
You are an educational advisor helping a Filipino teacher support their Grade 7 student.

Student: ${student.studentName}
Struggling Topic: $topic
Current Average Score: ${student.averageQuizScore.toStringAsFixed(1)}%
AI Assessment Score: ${student.averageAIScore.toStringAsFixed(1)}/5

Please provide:
1. 3-4 specific teaching recommendations to help this student understand the topic better
2. 2-3 key focus areas the teacher should emphasize
3. A recommended teaching strategy (e.g., visual aids, hands-on activities, peer learning, simplified explanations)

Format your response as:
RECOMMENDATIONS:
- [recommendation 1]
- [recommendation 2]
- [recommendation 3]

FOCUS AREAS:
- [focus area 1]
- [focus area 2]

TEACHING STRATEGY:
[strategy description]

Keep recommendations practical and culturally appropriate for Filipino students.
''';

    try {
      final response = await _generateText(prompt);

      // Parse the response
      final recommendations = <String>[];
      final focusAreas = <String>[];
      String teachingStrategy = '';

      final lines = response.split('\n');
      String currentSection = '';

      for (final line in lines) {
        final trimmed = line.trim();

        if (trimmed.startsWith('RECOMMENDATIONS:')) {
          currentSection = 'recommendations';
          continue;
        } else if (trimmed.startsWith('FOCUS AREAS:')) {
          currentSection = 'focus';
          continue;
        } else if (trimmed.startsWith('TEACHING STRATEGY:')) {
          currentSection = 'strategy';
          continue;
        }

        if (trimmed.isEmpty) continue;

        if (currentSection == 'recommendations' && trimmed.startsWith('-')) {
          recommendations.add(trimmed.substring(1).trim());
        } else if (currentSection == 'focus' && trimmed.startsWith('-')) {
          focusAreas.add(trimmed.substring(1).trim());
        } else if (currentSection == 'strategy') {
          teachingStrategy += '$trimmed ';
        }
      }

      // Fallback if parsing fails
      if (recommendations.isEmpty) {
        recommendations.addAll([
          'Break down the topic into smaller, manageable parts',
          'Use visual aids and real-world examples',
          'Provide additional practice exercises',
          'Encourage questions and peer discussion',
        ]);
      }

      if (focusAreas.isEmpty) {
        focusAreas.addAll([
          'Core concepts and definitions',
          'Practical applications',
          'Common misconceptions',
        ]);
      }

      if (teachingStrategy.isEmpty) {
        teachingStrategy =
            'Use a combination of visual aids, hands-on activities, and simplified explanations. Encourage peer learning and provide frequent feedback.';
      }

      // Determine difficulty level
      String difficulty;
      if (student.averageQuizScore < 40) {
        difficulty = 'High';
      } else if (student.averageQuizScore < 60) {
        difficulty = 'Medium';
      } else {
        difficulty = 'Low';
      }

      return LessonSuggestion(
        studentId: student.studentId,
        studentName: student.studentName,
        topic: topic,
        subject: 'General', // Could be extracted from topic if needed
        currentScore: student.averageQuizScore,
        difficulty: difficulty,
        recommendations: recommendations,
        focusAreas: focusAreas,
        teachingStrategy: teachingStrategy.trim(),
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error generating AI suggestion: $e');
      return null;
    }
  }

  /// Generate a quick intervention plan for multiple struggling students
  Future<String> generateClassInterventionPlan(
    List<StudentProgressSummary> strugglingStudents,
  ) async {
    if (strugglingStudents.isEmpty) {
      return 'All students are performing well! Continue with the current teaching approach.';
    }

    final studentSummaries = strugglingStudents.map((s) {
      return '- ${s.studentName}: ${s.averageQuizScore.toStringAsFixed(1)}% (Struggling with: ${s.strugglingTopics.take(2).join(", ")})';
    }).join('\n');

    final prompt = '''
You are an educational advisor helping a Filipino Grade 7 teacher create an intervention plan.

Students needing support:
$studentSummaries

Please provide:
1. A brief class-wide intervention strategy
2. Grouping recommendations (if applicable)
3. Time management suggestions
4. Resources or materials that might help

Keep the plan practical and achievable for a busy teacher. Format as a clear, actionable plan.
''';

    try {
      final response = await _generateText(prompt);
      return response;
    } catch (e) {
      debugPrint('Error generating intervention plan: $e');
      return 'Unable to generate intervention plan at this time. Please review individual student progress and adjust teaching strategies accordingly.';
    }
  }
}

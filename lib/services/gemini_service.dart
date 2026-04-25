import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:klaro/models/quiz_question.dart';
import 'package:klaro/utils/constants.dart';
import 'package:klaro/utils/helpers.dart';

/// ============================================================
/// Gemini Service
/// ============================================================
/// Handles all AI interactions: word simplification, quiz generation,
/// quiz evaluation, and conversational AI assessment.

class GeminiService {
  static final Uri _generateContentUri = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/'
    '${AppConstants.geminiModel}:generateContent',
  );

  Future<String> _generateText(
    String prompt, {
    double temperature = 0.2,
    int maxOutputTokens = 4096,
  }) async {
    if (AppConstants.geminiApiKey.isEmpty ||
        AppConstants.geminiApiKey == 'YOUR_GEMINI_API_KEY') {
      throw StateError('Gemini API key is not configured.');
    }

    final response = await http.post(
      _generateContentUri,
      headers: {
        'Content-Type': 'application/json',
        'X-goog-api-key': AppConstants.geminiApiKey,
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          'temperature': temperature,
          'maxOutputTokens': maxOutputTokens,
        },
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          body['error'] is Map ? body['error']['message']?.toString() : null;
      throw StateError(message ?? 'Gemini request failed.');
    }

    final candidates = body['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw StateError('Gemini returned no candidates.');
    }

    final content = candidates.first['content'];
    final parts = content is Map ? content['parts'] : null;
    if (parts is! List) {
      throw StateError('Gemini returned no text parts.');
    }

    return parts
        .whereType<Map>()
        .map((part) => part['text']?.toString() ?? '')
        .join()
        .trim();
  }

  // ── Word Simplification ───────────────────────────────────

  /// Simplify a word and provide Tagalog/Taglish translation.
  /// Returns a map with 'explanation' and 'tagalog' keys.
  Future<Map<String, String>> simplifyWord(String word,
      {String? context}) async {
    final prompt = '''
You are a helpful tutor for Filipino Grade 8 students.
Explain this word in very simple terms that a 13-year-old can understand.
Also provide a Tagalog or Taglish translation/explanation.
Keep each answer to one short sentence.

Word: $word
${context != null ? 'Context: "$context"' : ''}

Respond in this exact JSON format only, no other text:
{
  "explanation": "simple explanation here",
  "tagalog": "Tagalog/Taglish explanation here"
}
''';

    final text = await _generateText(prompt, maxOutputTokens: 2048);
    final parsed = Helpers.tryParseJson(text);

    if (parsed != null && parsed is Map) {
      return {
        'explanation':
            parsed['explanation']?.toString() ?? 'Unable to explain.',
        'tagalog':
            parsed['tagalog']?.toString() ?? 'Hindi available ang translation.',
      };
    }

    if (text.trim().startsWith('{')) {
      throw StateError('Gemini returned incomplete JSON.');
    }

    // Fallback: return plain text as explanation if Gemini did not use JSON.
    return {
      'explanation': text,
      'tagalog': 'Hindi available ang translation.',
    };
  }

  // ── Quiz Generation ───────────────────────────────────────

  /// Generate quiz questions from lesson content.
  /// Returns a list of QuizQuestion objects.
  Future<List<QuizQuestion>> generateQuizQuestions(String lessonContent) async {
    final prompt = '''
You are creating a comprehension quiz for a Filipino Grade 8 student.
Based on this lesson, generate exactly 3 quiz questions.

Rules:
- Question 1 and 2: Multiple choice with 4 options (A, B, C, D). One correct answer.
- Question 3: Short answer question.
- Questions should test understanding, not just memorization.
- Use simple, clear language.

Lesson:
$lessonContent

Respond in this exact JSON format only, no other text:
[
  {
    "question": "What is evaporation?",
    "type": "multipleChoice",
    "choices": ["A) Water turning to gas", "B) Gas turning to water", "C) Water turning to ice", "D) Ice turning to water"],
    "correctAnswer": "A) Water turning to gas"
  },
  {
    "question": "Another question here?",
    "type": "multipleChoice",
    "choices": ["A) Option 1", "B) Option 2", "C) Option 3", "D) Option 4"],
    "correctAnswer": "B) Option 2"
  },
  {
    "question": "Explain in your own words what happens during condensation.",
    "type": "shortAnswer",
    "choices": null,
    "correctAnswer": "Water vapor cools down and turns back into liquid water droplets"
  }
]
''';

    try {
      final text = await _generateText(prompt);
      final parsed = Helpers.tryParseJson(text);

      if (parsed != null && parsed is List) {
        return parsed.map((q) {
          final map = Map<String, dynamic>.from(q);
          return QuizQuestion.fromMap(map);
        }).toList();
      }

      // Fallback: return hardcoded questions
      return _fallbackQuestions();
    } catch (e) {
      return _fallbackQuestions();
    }
  }

  List<QuizQuestion> _fallbackQuestions() {
    return [
      QuizQuestion(
        question: 'What is the main topic of this lesson?',
        type: QuestionType.multipleChoice,
        choices: [
          'A) The water cycle',
          'B) The food chain',
          'C) The solar system',
          'D) The human body',
        ],
        correctAnswer: 'A) The water cycle',
      ),
      QuizQuestion(
        question: 'What happens during evaporation?',
        type: QuestionType.multipleChoice,
        choices: [
          'A) Water freezes into ice',
          'B) Water turns into vapor due to heat',
          'C) Clouds form in the sky',
          'D) Rain falls from clouds',
        ],
        correctAnswer: 'B) Water turns into vapor due to heat',
      ),
      QuizQuestion(
        question:
            'In your own words, explain why the water cycle is important for life on Earth.',
        type: QuestionType.shortAnswer,
        correctAnswer:
            'The water cycle distributes fresh water, regulates temperature, and supports all living things.',
      ),
    ];
  }

  // ── Quiz Evaluation ───────────────────────────────────────

  /// Evaluate student answers and return scores with feedback.
  Future<Map<String, dynamic>> evaluateQuizAnswers(
    List<QuizQuestion> questions,
    List<String> studentAnswers,
  ) async {
    final questionsText = questions.asMap().entries.map((e) {
      final q = e.value;
      final answer = studentAnswers[e.key];
      return '''
Question ${e.key + 1}: ${q.question}
${q.type == QuestionType.multipleChoice ? 'Correct Answer: ${q.correctAnswer}' : 'Expected Answer: ${q.correctAnswer}'}
Student Answer: $answer
''';
    }).join('\n');

    final prompt = '''
Evaluate these student answers for a Grade 8 quiz.
Be encouraging but honest. For short answer questions, accept answers that show understanding even if not word-perfect.

$questionsText

Respond in this exact JSON format only, no other text:
{
  "score": 2,
  "total": 3,
  "results": [
    {"questionNumber": 1, "isCorrect": true, "feedback": "Correct! Great job."},
    {"questionNumber": 2, "isCorrect": false, "feedback": "Not quite. The correct answer is..."},
    {"questionNumber": 3, "isCorrect": true, "feedback": "Good explanation! You understand the concept."}
  ]
}
''';

    try {
      final text = await _generateText(prompt);
      final parsed = Helpers.tryParseJson(text);

      if (parsed != null && parsed is Map) {
        return Map<String, dynamic>.from(parsed);
      }

      // Fallback: simple evaluation
      return _fallbackEvaluation(questions, studentAnswers);
    } catch (e) {
      return _fallbackEvaluation(questions, studentAnswers);
    }
  }

  Map<String, dynamic> _fallbackEvaluation(
    List<QuizQuestion> questions,
    List<String> studentAnswers,
  ) {
    int score = 0;
    final results = <Map<String, dynamic>>[];

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final answer = studentAnswers[i].trim().toLowerCase();
      final correct = q.correctAnswer.trim().toLowerCase();
      final isCorrect = answer == correct || correct.contains(answer);

      if (isCorrect) score++;
      results.add({
        'questionNumber': i + 1,
        'isCorrect': isCorrect,
        'feedback': isCorrect
            ? 'Correct! Well done.'
            : 'The correct answer is: ${q.correctAnswer}',
      });
    }

    return {'score': score, 'total': questions.length, 'results': results};
  }

  // ── Conversational AI ─────────────────────────────────────

  /// Conduct a conversational AI assessment.
  /// Takes lesson content and conversation history, returns AI response.
  Future<Map<String, dynamic>> conductConversation(
    String lessonContent,
    List<Map<String, String>> conversationHistory,
  ) async {
    final historyText = conversationHistory.map((m) {
      final role = m['role'] == 'student' ? 'Student' : 'AI Tutor';
      return '$role: ${m['message']}';
    }).join('\n');

    final exchangeCount =
        conversationHistory.where((m) => m['role'] == 'student').length;

    final isNearEnd = exchangeCount >= 4;

    final prompt = '''
You are a friendly AI tutor named Klaro, helping a Filipino Grade 8 student understand a lesson.

Rules:
- Ask follow-up questions to confirm their understanding.
- Be encouraging, supportive, and use simple language.
- Relate concepts to everyday Filipino life when possible.
- Keep responses short (2-3 sentences max).
${isNearEnd ? '''
- This is exchange $exchangeCount. It's time to wrap up.
- After your response, provide a final assessment.
- End your message with the student's score and summary in this exact format on a new line:
ASSESSMENT_JSON: {"score": 4.5, "summary": "Brief summary of student understanding"}
- Score should be 1-5 (1=poor, 5=excellent understanding).
''' : '''
- Ask ONE follow-up question to test deeper understanding.
- Do NOT end the conversation yet.
'''}

Lesson Content:
$lessonContent

Conversation so far:
$historyText

Respond as the AI Tutor. Remember: be encouraging and ask questions.
''';

    try {
      final text = await _generateText(
        prompt,
        temperature: 0.7,
        maxOutputTokens: 1024,
      );

      // Check if the response contains the assessment JSON
      if (text.contains('ASSESSMENT_JSON:')) {
        final parts = text.split('ASSESSMENT_JSON:');
        final message = parts[0].trim();
        final jsonStr = parts[1].trim();
        final parsed = Helpers.tryParseJson(jsonStr);

        return {
          'message': message,
          'isComplete': true,
          'score': parsed?['score']?.toDouble() ?? 3.0,
          'summary': parsed?['summary'] ?? 'Conversation completed.',
        };
      }

      return {
        'message': text.trim(),
        'isComplete': false,
      };
    } catch (e) {
      return {
        'message': 'I had trouble understanding. Can you try explaining again?',
        'isComplete': false,
      };
    }
  }

  /// Get the initial AI greeting for a conversation.
  String getInitialGreeting(String lessonTitle) {
    return "Hi there! I'm Klaro, your AI tutor. Let's talk about \"$lessonTitle\" to make sure you really understand it. Ready? Tell me — what is the main idea of this lesson in your own words?";
  }
}

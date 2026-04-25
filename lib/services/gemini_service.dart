import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:klaro/models/quiz_question.dart';
import 'package:klaro/utils/constants.dart';
import 'package:klaro/utils/helpers.dart';

/// Handles all AI interactions through Firebase AI Logic.
class GeminiServiceException implements Exception {
  const GeminiServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GeminiService {
  /// Create a model instance with custom generation config.
  GenerativeModel _modelWith({
    double temperature = 0.2,
    int maxOutputTokens = 4096,
  }) {
    return FirebaseAI.googleAI().generativeModel(
      model: AppConstants.geminiModel,
      generationConfig: GenerationConfig(
        temperature: temperature,
        maxOutputTokens: maxOutputTokens,
      ),
    );
  }

  /// Core method: send a prompt and get text back.
  Future<String> _generateText(
    String prompt, {
    double temperature = 0.2,
    int maxOutputTokens = 4096,
  }) async {
    final model = _modelWith(
      temperature: temperature,
      maxOutputTokens: maxOutputTokens,
    );

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text == null || text.trim().isEmpty) {
        throw const GeminiServiceException(
          'Klaro AI returned an empty response. Please try again.',
        );
      }

      return text.trim();
    } on GeminiServiceException {
      rethrow;
    } on FirebaseAISdkException catch (error, stackTrace) {
      debugPrint('Firebase AI SDK error: ${error.message}');
      debugPrintStack(stackTrace: stackTrace);
      throw const GeminiServiceException(
        'The Firebase AI SDK could not read the response. Update packages and try again.',
      );
    } on FirebaseAIException catch (error, stackTrace) {
      debugPrint('Firebase AI request failed: ${error.message}');
      debugPrintStack(stackTrace: stackTrace);
      throw GeminiServiceException(_friendlyFirebaseAIMessage(error.message));
    } catch (error, stackTrace) {
      debugPrint('Klaro AI request failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const GeminiServiceException(
        'Klaro AI is unavailable right now. Check internet and Firebase AI setup.',
      );
    }
  }

  String _friendlyFirebaseAIMessage(String message) {
    final normalized = message.toLowerCase();

    if (normalized.contains('firebasevertexai.googleapis.com') ||
        normalized.contains('firebase ai logic api') ||
        normalized.contains('vertex ai in firebase api') ||
        normalized.contains('service_disabled')) {
      return 'Firebase AI Logic is not enabled for this Firebase project yet. Enable AI Logic in Firebase Console, wait a few minutes, then try again.';
    }

    if (normalized.contains('api_key_invalid') ||
        normalized.contains('api key')) {
      return 'Firebase rejected the Android API key. Check that google-services.json belongs to this Firebase project and Android app.';
    }

    if (normalized.contains('limit: 0') && normalized.contains('quota')) {
      return 'This Firebase project has zero quota for the selected Gemini model. Update the model or enable billing/quota in Google AI Studio.';
    }

    if (normalized.contains('quota')) {
      return 'Firebase AI quota was exceeded. Wait a few seconds, then try again. If it keeps happening, check the project quota.';
    }

    if (normalized.contains('permission_denied') ||
        normalized.contains('permission denied')) {
      return 'Firebase AI permission was denied. Check Firebase AI Logic, billing/API access, and the Android app configuration.';
    }

    return 'Klaro AI failed: $message';
  }

  Future<Map<String, String>> simplifyWord(
    String word, {
    String? context,
    String targetLanguage = 'tl', // Default to Tagalog for backward compatibility
  }) async {
    // Get language name from code
    final languageNames = {
      'en': 'English',
      'tl': 'Tagalog',
      'ceb': 'Cebuano',
      'ilo': 'Ilocano',
      'hil': 'Hiligaynon',
      'war': 'Waray',
      'pam': 'Kapampangan',
      'bik': 'Bikol',
      'pag': 'Pangasinan',
    };

    final languageName = languageNames[targetLanguage] ?? 'Tagalog';

    final prompt = '''
You are a helpful tutor for Filipino Grade 7 students.
Explain this word in very simple terms that a 12-13-year-old can understand.
Also provide a $languageName translation/explanation.
Keep each answer to one short sentence.

Word: $word
${context != null ? 'Context: "$context"' : ''}

Respond in this exact JSON format only, no other text:
{
  "explanation": "simple explanation here",
  "tagalog": "$languageName explanation here"
}
''';

    final text = await _generateText(prompt, maxOutputTokens: 512);
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
      throw const GeminiServiceException('Klaro AI returned incomplete JSON.');
    }

    return {
      'explanation': text,
      'tagalog': 'Hindi available ang translation.',
    };
  }

  Future<List<QuizQuestion>> generateQuizQuestions(String lessonContent) async {
    final prompt = '''
You are creating a comprehension quiz for a Filipino Grade 7 student.
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
    "question": "Question text here?",
    "type": "multipleChoice",
    "choices": ["A) Option 1", "B) Option 2", "C) Option 3", "D) Option 4"],
    "correctAnswer": "A) Option 1"
  },
  {
    "question": "Another question here?",
    "type": "multipleChoice",
    "choices": ["A) Option 1", "B) Option 2", "C) Option 3", "D) Option 4"],
    "correctAnswer": "B) Option 2"
  },
  {
    "question": "Explain the main idea in your own words.",
    "type": "shortAnswer",
    "choices": null,
    "correctAnswer": "A short expected answer here"
  }
]
''';

    try {
      final text = await _generateText(prompt, maxOutputTokens: 2048);
      final parsed = Helpers.tryParseJson(text);

      if (parsed != null && parsed is List) {
        return parsed.map((q) {
          final map = Map<String, dynamic>.from(q);
          return QuizQuestion.fromMap(map);
        }).toList();
      }

      return _fallbackQuestions();
    } catch (error) {
      debugPrint('Quiz generation failed: $error');
      return _fallbackQuestions();
    }
  }

  List<QuizQuestion> _fallbackQuestions() {
    return [
      QuizQuestion(
        question: 'What is the main topic of this lesson?',
        type: QuestionType.multipleChoice,
        choices: [
          'A) The lesson topic',
          'B) An unrelated topic',
          'C) A classroom rule',
          'D) A personal opinion',
        ],
        correctAnswer: 'A) The lesson topic',
      ),
      QuizQuestion(
        question: 'What should you do with important terms from the lesson?',
        type: QuestionType.multipleChoice,
        choices: [
          'A) Ignore them',
          'B) Memorize without understanding',
          'C) Use them to explain the lesson',
          'D) Remove them from notes',
        ],
        correctAnswer: 'C) Use them to explain the lesson',
      ),
      QuizQuestion(
        question:
            'Explain one important idea from this lesson in your own words.',
        type: QuestionType.shortAnswer,
        correctAnswer:
            'The answer should explain a key idea from the lesson clearly.',
      ),
    ];
  }

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
Evaluate these student answers for a Grade 7 quiz.
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
      final text = await _generateText(prompt, maxOutputTokens: 2048);
      final parsed = Helpers.tryParseJson(text);

      if (parsed != null && parsed is Map) {
        return Map<String, dynamic>.from(parsed);
      }

      return _fallbackEvaluation(questions, studentAnswers);
    } catch (error) {
      debugPrint('Quiz evaluation failed: $error');
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

  Future<Map<String, dynamic>> conductAssessmentConversation(
    String lessonContent,
    List<Map<String, String>> conversationHistory,
    int correctAnswers,
    int incorrectAnswers,
  ) async {
    final historyText = conversationHistory.map((m) {
      final role = m['role'] == 'student' ? 'Student' : 'AI Assessment';
      return '$role: ${m['message']}';
    }).join('\n');

    final totalAttempts = correctAnswers + incorrectAnswers;
    final consecutiveIncorrect = _countConsecutiveIncorrect(conversationHistory);

    final prompt = '''
You are Klaro, a friendly and encouraging AI Assessment assistant helping a Filipino Grade 7 student learn and demonstrate their understanding.

FORMATTING RULES:
- Use proper markdown formatting in your responses
- For lists, use markdown syntax with dashes: "- Item 1\\n- Item 2\\n- Item 3"
- For bold text, use **text**
- For emphasis, use *text*
- Always add a blank line before starting a list

YOUR TEACHING PHILOSOPHY:
- You're not just testing - you're teaching through conversation
- Help students discover answers through guided questions
- Provide hints and encouragement when they struggle
- Celebrate their progress and correct thinking
- Make learning feel like a natural conversation, not an interrogation

CONVERSATION FLOW RULES:
1. DISTINGUISH between questions and answer attempts:
   - Questions: "What do you mean?", "Can you explain?", "I don't understand", "Help me"
   - Answer attempts: Direct responses to your questions, explanations, definitions

2. WHEN STUDENT ASKS A QUESTION:
   - Provide helpful hints without giving away the answer
   - Break down complex concepts into simpler parts
   - Use examples from everyday Filipino life
   - Encourage them to try answering after the hint
   - DO NOT count this as an attempt

3. WHEN EVALUATING ANSWERS:
   - If CORRECT: Praise specifically what they got right, then ask a deeper follow-up question to test understanding
   - If INCORRECT: 
     * Don't just say "wrong" - explain WHY it's incorrect
     * Provide a hint or guide them toward the right thinking
     * Ask a simpler related question to build confidence
     * If they've struggled (${consecutiveIncorrect} consecutive incorrect), offer more detailed guidance

4. KEEP THE CONVERSATION NATURAL:
   - Use conversational Filipino-English mix when appropriate
   - Ask "Why do you think that?" or "Can you explain more?" to deepen understanding
   - Reference their previous correct answers to build on their knowledge
   - Make connections between concepts

5. ADAPTIVE DIFFICULTY:
   - Start with broader questions
   - If they answer correctly, ask more specific/challenging follow-ups
   - If they struggle, break questions into smaller, manageable parts
   - Adjust your language complexity based on their responses

CURRENT SITUATION:
- Score: $correctAnswers correct, $incorrectAnswers incorrect (Total attempts: $totalAttempts)
- Consecutive incorrect: $consecutiveIncorrect
${consecutiveIncorrect >= 2 ? '- Student is struggling - provide more guidance and simpler questions' : ''}
${correctAnswers >= 2 ? '- Student is doing well - you can ask more challenging questions' : ''}

Lesson Content:
$lessonContent

Conversation History:
$historyText

${correctAnswers >= 3 ? '''
🎉 ASSESSMENT COMPLETE - PASSED! 
The student has demonstrated understanding with 3 correct answers.
Write an encouraging final message that:
- Celebrates their achievement
- Mentions specific concepts they understood well
- Encourages them to keep learning
Then add: ASSESSMENT_COMPLETE: {"correctAnswers": $correctAnswers, "totalAttempts": $totalAttempts, "passed": true, "summary": "Successfully demonstrated understanding of [key concepts]"}
''' : incorrectAnswers >= 3 ? '''
📚 ASSESSMENT COMPLETE - NEEDS REVIEW
The student needs more practice with this lesson.
Write a supportive final message that:
- Acknowledges their effort
- Identifies specific areas to review
- Encourages them to study and try again
Then add: ASSESSMENT_COMPLETE: {"correctAnswers": $correctAnswers, "totalAttempts": $totalAttempts, "passed": false, "summary": "Needs to review: [specific topics]"}
''' : '''
CONTINUE THE CONVERSATION:

Analyze the student's last message:
- Is it a QUESTION/REQUEST FOR HELP? → Provide guidance without scoring
- Is it an ANSWER ATTEMPT? → Evaluate and provide feedback

Response Format:
[Your conversational response here - be natural, encouraging, and educational]

Then add ONE of these tags:
- If it was a question: EVALUATION: {"isQuestion": true}
- If it was an answer attempt: EVALUATION: {"isCorrect": true/false, "isQuestion": false}

REMEMBER: 
- Always explain WHY an answer is correct or incorrect
- Always ask a follow-up question to continue the conversation
- Make the student feel supported, not interrogated
- Help them learn, not just test them
'''}

Respond as Klaro, the friendly AI Assessment assistant.
''';

    try {
      final text = await _generateText(
        prompt,
        temperature: 0.4, // Slightly higher for more natural conversation
        maxOutputTokens: 1536, // More tokens for detailed explanations
      );

      // Check for assessment completion
      if (text.contains('ASSESSMENT_COMPLETE:')) {
        final parts = text.split('ASSESSMENT_COMPLETE:');
        final message = parts[0].trim();
        final jsonStr = parts[1].trim();
        final parsed = Helpers.tryParseJson(jsonStr);

        return {
          'message': message,
          'isComplete': true,
          'correctAnswers': parsed?['correctAnswers'] ?? correctAnswers,
          'totalAttempts': parsed?['totalAttempts'] ?? totalAttempts,
          'passed': parsed?['passed'] ?? false,
          'summary': parsed?['summary'] ?? 'Assessment completed.',
        };
      }

      // Check for evaluation
      if (text.contains('EVALUATION:')) {
        final parts = text.split('EVALUATION:');
        final message = parts[0].trim();
        final jsonStr = parts[1].trim();
        final parsed = Helpers.tryParseJson(jsonStr);

        final isQuestion = parsed?['isQuestion'] ?? false;
        final isCorrect = parsed?['isCorrect'] ?? false;

        return {
          'message': message,
          'isComplete': false,
          'isQuestion': isQuestion,
          'isCorrect': isCorrect,
        };
      }

      // Fallback: treat as question/clarification
      return {
        'message': text.trim(),
        'isComplete': false,
        'isQuestion': true,
      };
    } catch (error) {
      debugPrint('Assessment conversation failed: $error');
      return {
        'message': 'I had trouble understanding. Can you try explaining again? Or if you need help, just ask me to explain the concept!',
        'isComplete': false,
        'isQuestion': true,
      };
    }
  }

  /// Count consecutive incorrect answers to adjust difficulty
  int _countConsecutiveIncorrect(List<Map<String, String>> history) {
    int count = 0;
    // Look at recent AI responses for "incorrect" or "not quite" patterns
    for (int i = history.length - 1; i >= 0; i--) {
      final msg = history[i];
      if (msg['role'] == 'ai') {
        final text = msg['message']?.toLowerCase() ?? '';
        if (text.contains('incorrect') || 
            text.contains('not quite') || 
            text.contains('not exactly') ||
            text.contains('try again')) {
          count++;
        } else if (text.contains('correct') || text.contains('good') || text.contains('right')) {
          break; // Stop counting if we hit a correct answer
        }
      }
    }
    return count;
  }

  String getAssessmentGreeting(String lessonTitle) {
    return "Hi! I'm Klaro, your AI Assessment assistant. 👋\n\nLet's have a conversation about \"$lessonTitle\" to see how well you understand it. Don't worry - this is a learning conversation, not just a test!\n\n📝 Here's how it works:\n\n- You need 3 correct answers to pass\n- If you're unsure, just ask me for help or hints\n- I'll guide you through the concepts\n- Take your time and think through your answers\n\nReady? Let's start with an easy one: What is the main idea of this lesson? Explain it in your own words. 😊";
  }

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
You are a friendly AI tutor named Klaro, helping a Filipino Grade 7 student understand a lesson.

Rules:
- Ask follow-up questions to confirm their understanding.
- Be encouraging, supportive, and use simple language.
- Relate concepts to everyday Filipino life when possible.
- Keep responses short (2-3 sentences max).
${isNearEnd ? '''
- This is exchange $exchangeCount. It is time to wrap up.
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
    } catch (error) {
      debugPrint('Conversation generation failed: $error');
      return {
        'message': 'I had trouble understanding. Can you try explaining again?',
        'isComplete': false,
      };
    }
  }

  String getInitialGreeting(String lessonTitle) {
    return "Hi there! I'm Klaro, your AI tutor. Let's talk about \"$lessonTitle\" to make sure you really understand it. Ready? Tell me the main idea of this lesson in your own words.";
  }

  /// Translate static UI text to target language
  Future<String> translateText(String text, String targetLanguage) async {
    // Get language name from code
    final languageNames = {
      'en': 'English',
      'tl': 'Tagalog',
      'ceb': 'Cebuano',
      'ilo': 'Ilocano',
      'hil': 'Hiligaynon',
      'war': 'Waray',
      'pam': 'Kapampangan',
      'bik': 'Bikol',
      'pan': 'Pangasinan',
    };

    final languageName = languageNames[targetLanguage] ?? targetLanguage;

    final prompt = '''
You are a professional translator for Filipino educational content.
Translate the following English text to $languageName.

Rules:
- Maintain the original meaning and tone
- Use natural, conversational language appropriate for Grade 7 students
- Keep technical terms in English if commonly used that way
- Preserve any placeholders like {name} or {count}
- Do NOT add explanations or additional text

Text to translate: "$text"

Respond with ONLY the translated text, no explanations or additional text.
''';

    try {
      final translation = await _generateText(prompt, maxOutputTokens: 512);
      return translation.trim();
    } catch (error) {
      debugPrint('Translation failed: $error');
      // Fallback to original text
      return text;
    }
  }
}

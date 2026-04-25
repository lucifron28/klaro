import 'package:hive_flutter/hive_flutter.dart';
import 'package:klaro/models/app_user.dart';
import 'package:klaro/models/quiz_response.dart';
import 'package:klaro/models/ai_conversation.dart';
import 'package:klaro/models/learned_concept.dart';
import 'package:klaro/utils/constants.dart';

/// ============================================================
/// Local Storage Service (Hive)
/// ============================================================
/// Handles all local data persistence using Hive key-value store.
/// This is the primary data layer for the hackathon MVP.

class LocalStorageService {
  /// Initialize Hive and open all required boxes
  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(AppConstants.lessonsBox);
    await Hive.openBox(AppConstants.scoresBox);
    await Hive.openBox(AppConstants.conversationsBox);
    await Hive.openBox(AppConstants.userBox);
    await Hive.openBox(AppConstants.cacheBox);
    await Hive.openBox('translation_cache');
    await Hive.openBox('language_preference');
  }

  // ── User ──────────────────────────────────────────────────

  Future<void> saveUser(AppUser user) async {
    final box = Hive.box(AppConstants.userBox);
    await box.put('currentUser', user.toMap());
  }

  Future<AppUser?> getUser() async {
    final box = Hive.box(AppConstants.userBox);
    final data = box.get('currentUser');
    if (data != null) {
      return AppUser.fromMap(Map<dynamic, dynamic>.from(data));
    }
    return null;
  }

  Future<void> clearUser() async {
    final box = Hive.box(AppConstants.userBox);
    await box.delete('currentUser');
  }

  // ── Word Cache ────────────────────────────────────────────

  Future<void> cacheWordExplanation(
      String word, Map<String, String> data) async {
    final box = Hive.box(AppConstants.cacheBox);
    await box.put(word.toLowerCase(), data);
  }

  Map<String, String>? getCachedWordExplanation(String word) {
    final box = Hive.box(AppConstants.cacheBox);
    final data = box.get(word.toLowerCase());
    if (data != null) {
      return Map<String, String>.from(data);
    }
    return null;
  }

  Future<void> saveLearnedConcept(
    String lessonId,
    LearnedConcept concept,
  ) async {
    final concepts = await getLearnedConcepts(lessonId);
    final index = concepts.indexWhere(
      (item) => item.word.toLowerCase() == concept.word.toLowerCase(),
    );

    if (index == -1) {
      concepts.add(concept);
    } else {
      concepts[index] = concept;
    }

    await saveLearnedConcepts(lessonId, concepts);
  }

  Future<void> saveLearnedConcepts(
    String lessonId,
    List<LearnedConcept> concepts,
  ) async {
    final box = Hive.box(AppConstants.lessonsBox);
    await box.put(
      'learned_$lessonId',
      concepts.map((concept) => concept.toMap()).toList(),
    );
  }

  Future<List<LearnedConcept>> getLearnedConcepts(String lessonId) async {
    final box = Hive.box(AppConstants.lessonsBox);
    final data = box.get('learned_$lessonId');
    if (data is! List) return [];

    return data
        .map((item) => LearnedConcept.fromMap(Map<dynamic, dynamic>.from(item)))
        .where((concept) => concept.word.isNotEmpty)
        .toList();
  }

  // ── Quiz Scores ───────────────────────────────────────────

  Future<void> saveQuizResponse(QuizResponse response) async {
    final box = Hive.box(AppConstants.scoresBox);
    await box.put('quiz_${response.lessonId}', response.toMap());
  }

  Future<QuizResponse?> getQuizResponse(String lessonId) async {
    final box = Hive.box(AppConstants.scoresBox);
    final data = box.get('quiz_$lessonId');
    if (data != null) {
      return QuizResponse.fromMap(Map<dynamic, dynamic>.from(data));
    }
    return null;
  }

  Future<List<QuizResponse>> getAllQuizResponses() async {
    final box = Hive.box(AppConstants.scoresBox);
    final responses = <QuizResponse>[];
    for (final key in box.keys) {
      if (key.toString().startsWith('quiz_')) {
        final data = box.get(key);
        if (data != null) {
          responses.add(QuizResponse.fromMap(Map<dynamic, dynamic>.from(data)));
        }
      }
    }
    return responses;
  }

  // ── AI Conversations ──────────────────────────────────────

  Future<void> saveAIConversation(AIConversation conversation) async {
    final box = Hive.box(AppConstants.conversationsBox);
    await box.put('ai_${conversation.lessonId}', conversation.toMap());
  }

  Future<AIConversation?> getAIConversation(String lessonId) async {
    final box = Hive.box(AppConstants.conversationsBox);
    final data = box.get('ai_$lessonId');
    if (data != null) {
      return AIConversation.fromMap(Map<dynamic, dynamic>.from(data));
    }
    return null;
  }

  Future<List<AIConversation>> getAllAIConversations() async {
    final box = Hive.box(AppConstants.conversationsBox);
    final conversations = <AIConversation>[];
    for (final key in box.keys) {
      if (key.toString().startsWith('ai_')) {
        final data = box.get(key);
        if (data != null) {
          conversations
              .add(AIConversation.fromMap(Map<dynamic, dynamic>.from(data)));
        }
      }
    }
    return conversations;
  }

  // ── Lesson Completion ─────────────────────────────────────

  Future<void> markLessonCompleted(String lessonId) async {
    final box = Hive.box(AppConstants.lessonsBox);
    await box.put('completed_$lessonId', DateTime.now().toIso8601String());
  }

  Future<bool> isLessonCompleted(String lessonId) async {
    final box = Hive.box(AppConstants.lessonsBox);
    return box.containsKey('completed_$lessonId');
  }

  // ── Clear All Data ────────────────────────────────────────

  Future<void> clearAll() async {
    await Hive.box(AppConstants.lessonsBox).clear();
    await Hive.box(AppConstants.scoresBox).clear();
    await Hive.box(AppConstants.conversationsBox).clear();
    await Hive.box(AppConstants.cacheBox).clear();
  }

  // ── Language Preference ───────────────────────────────────

  Future<void> saveLanguagePreference(String languageCode) async {
    final box = Hive.box('language_preference');
    await box.put('preferred_language', languageCode);
  }

  Future<String?> getLanguagePreference() async {
    final box = Hive.box('language_preference');
    return box.get('preferred_language') as String?;
  }

  // ── Seeder Status ─────────────────────────────────────────

  Future<bool> getSeederStatus() async {
    final box = Hive.box('language_preference');
    return box.get('seeder_completed', defaultValue: false) as bool;
  }

  Future<void> markSeederComplete() async {
    final box = Hive.box('language_preference');
    await box.put('seeder_completed', true);
  }
}

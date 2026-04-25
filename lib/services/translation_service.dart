import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:klaro/models/translation_models.dart';
import 'package:klaro/services/gemini_service.dart';
import 'package:klaro/services/local_storage_service.dart';

/// ============================================================
/// Translation Service
/// ============================================================
/// Provides runtime translation of static UI text using Gemini API.
/// Implements dual caching strategy (in-memory + Hive).

class TranslationService {
  final LocalStorageService _localStorage = LocalStorageService();
  final GeminiService _geminiService = GeminiService();

  // In-memory cache for current session
  final Map<String, String> _memoryCache = {};

  String _preferredLanguage = 'en';

  /// Initialize service and load user's preferred language
  Future<void> initialize() async {
    // Load preferred language from local storage first
    final localLang = await _localStorage.getLanguagePreference();
    if (localLang != null) {
      _preferredLanguage = localLang;
      debugPrint('Loaded language preference from local storage: $localLang');
      return;
    }

    // Default to English if no preference found
    _preferredLanguage = 'en';
    debugPrint('No language preference found, defaulting to English');
  }

  /// Translate a single text string
  Future<String> translate(String text, String targetLanguage) async {
    // If target language is English, return original text
    if (targetLanguage == 'en') {
      return text;
    }

    // Check memory cache first
    final cacheKey = '$targetLanguage:$text';
    if (_memoryCache.containsKey(cacheKey)) {
      debugPrint('Translation cache hit (memory): $text');
      return _memoryCache[cacheKey]!;
    }

    // Check Hive cache
    final cachedTranslation = await getCachedTranslation(text, targetLanguage);
    if (cachedTranslation != null) {
      debugPrint('Translation cache hit (Hive): $text');
      _memoryCache[cacheKey] = cachedTranslation;
      return cachedTranslation;
    }

    // Cache miss - call Gemini API
    try {
      debugPrint('Translation cache miss, calling Gemini API: $text');
      final translation = await _geminiService.translateText(text, targetLanguage);

      // Cache the translation
      await cacheTranslation(text, targetLanguage, translation);

      return translation;
    } catch (e) {
      debugPrint('Translation error: $e');
      // Fallback to original text on error
      return text;
    }
  }

  /// Translate multiple strings in batch
  Future<Map<String, String>> translateBatch(
    List<String> texts,
    String targetLanguage,
  ) async {
    final translations = <String, String>{};

    for (final text in texts) {
      translations[text] = await translate(text, targetLanguage);
    }

    return translations;
  }

  /// Get cached translation from Hive
  Future<String?> getCachedTranslation(
      String text, String targetLanguage) async {
    try {
      final box = Hive.box('translation_cache');
      final cacheKey = '$targetLanguage:$text';
      final data = box.get(cacheKey);

      if (data != null) {
        final entry = TranslationCacheEntry.fromMap(
          Map<dynamic, dynamic>.from(data),
        );

        // Check if cache entry is expired (30 days)
        if (!entry.isExpired(const Duration(days: 30))) {
          return entry.translatedText;
        } else {
          // Remove expired entry
          await box.delete(cacheKey);
        }
      }
    } catch (e) {
      debugPrint('Error getting cached translation: $e');
    }

    return null;
  }

  /// Save translation to cache (memory + Hive)
  Future<void> cacheTranslation(
    String text,
    String targetLanguage,
    String translation,
  ) async {
    try {
      // Save to memory cache
      final cacheKey = '$targetLanguage:$text';
      _memoryCache[cacheKey] = translation;

      // Save to Hive cache
      final box = Hive.box('translation_cache');
      final entry = TranslationCacheEntry(
        sourceText: text,
        targetLanguage: targetLanguage,
        translatedText: translation,
        cachedAt: DateTime.now(),
      );

      await box.put(cacheKey, entry.toMap());
      debugPrint('Cached translation: $text -> $translation');
    } catch (e) {
      debugPrint('Error caching translation: $e');
    }
  }

  /// Change user's preferred language
  Future<void> setPreferredLanguage(String languageCode) async {
    _preferredLanguage = languageCode;
    await _localStorage.saveLanguagePreference(languageCode);
    debugPrint('Set preferred language to: $languageCode');
  }

  /// Get current preferred language
  String getPreferredLanguage() {
    return _preferredLanguage;
  }

  /// Clear all cached translations
  Future<void> clearCache() async {
    _memoryCache.clear();
    final box = Hive.box('translation_cache');
    await box.clear();
    debugPrint('Cleared translation cache');
  }
}

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:klaro/models/translation_models.dart';
import 'package:klaro/services/google_cloud_translation_service.dart';
import 'package:klaro/services/local_storage_service.dart';
import 'package:klaro/utils/translations.dart';

/// ============================================================
/// Translation Service
/// ============================================================
/// Provides runtime translation of static UI text using Google Cloud
/// Translation API with local fallback translations.
/// Implements dual caching strategy (in-memory + Hive).

class TranslationService {
  final LocalStorageService _localStorage = LocalStorageService();
  static final GoogleCloudTranslationService _cloudTranslation =
      GoogleCloudTranslationService();

  // In-memory cache for current session
  static final Map<String, String> _memoryCache = {};

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

  /// Translate a single text string.
  Future<String> translate(
    String text,
    String targetLanguage, {
    String sourceLanguage = 'en',
  }) async {
    final normalizedTarget =
        GoogleCloudTranslationService.cloudLanguageCode(targetLanguage);
    final normalizedSource =
        GoogleCloudTranslationService.cloudLanguageCode(sourceLanguage);

    if (normalizedTarget == 'en' || normalizedTarget == normalizedSource) {
      return text;
    }

    // Check memory cache first
    final cacheKey = _cacheKey(text, normalizedTarget, normalizedSource);
    if (_memoryCache.containsKey(cacheKey)) {
      debugPrint('Translation cache hit (memory): $text');
      return _memoryCache[cacheKey]!;
    }

    // Check Hive cache
    final cachedTranslation = await getCachedTranslation(
      text,
      normalizedTarget,
      sourceLanguage: normalizedSource,
    );
    if (cachedTranslation != null) {
      debugPrint('Translation cache hit (Hive): $text');
      _memoryCache[cacheKey] = cachedTranslation;
      return cachedTranslation;
    }

    // Cache miss - call Google Cloud Translation API.
    try {
      debugPrint('Translation cache miss, calling Google Cloud: $text');
      final translation = await _cloudTranslation.translateText(
        text,
        normalizedTarget,
        sourceLanguage: normalizedSource,
      );

      // Cache the translation
      await cacheTranslation(
        text,
        normalizedTarget,
        translation,
        sourceLanguage: normalizedSource,
      );

      return translation;
    } catch (e) {
      debugPrint('Translation error: $e');
      return _fallbackTranslation(text, normalizedTarget);
    }
  }

  /// Translate multiple strings in batch
  Future<Map<String, String>> translateBatch(
    List<String> texts,
    String targetLanguage, {
    String sourceLanguage = 'en',
  }) async {
    final normalizedTarget =
        GoogleCloudTranslationService.cloudLanguageCode(targetLanguage);
    final normalizedSource =
        GoogleCloudTranslationService.cloudLanguageCode(sourceLanguage);
    final translations = <String, String>{};
    final cacheMisses = <String>[];

    for (final text in texts) {
      if (normalizedTarget == 'en' || normalizedTarget == normalizedSource) {
        translations[text] = text;
        continue;
      }

      final cacheKey = _cacheKey(text, normalizedTarget, normalizedSource);
      final memoryTranslation = _memoryCache[cacheKey];
      if (memoryTranslation != null) {
        translations[text] = memoryTranslation;
        continue;
      }

      final cachedTranslation = await getCachedTranslation(
        text,
        normalizedTarget,
        sourceLanguage: normalizedSource,
      );
      if (cachedTranslation != null) {
        _memoryCache[cacheKey] = cachedTranslation;
        translations[text] = cachedTranslation;
        continue;
      }

      cacheMisses.add(text);
    }

    if (cacheMisses.isEmpty) {
      return translations;
    }

    try {
      for (var start = 0; start < cacheMisses.length; start += 128) {
        final end = (start + 128).clamp(0, cacheMisses.length);
        final chunk = cacheMisses.sublist(start, end);
        final cloudTranslations = await _cloudTranslation.translateTexts(
          chunk,
          normalizedTarget,
          sourceLanguage: normalizedSource,
        );

        for (var i = 0; i < chunk.length; i++) {
          final sourceText = chunk[i];
          final translatedText = cloudTranslations[i];
          translations[sourceText] = translatedText;
          await cacheTranslation(
            sourceText,
            normalizedTarget,
            translatedText,
            sourceLanguage: normalizedSource,
          );
        }
      }
    } catch (e) {
      debugPrint('Batch translation error: $e');
      for (final text in cacheMisses) {
        translations[text] = _fallbackTranslation(text, normalizedTarget);
      }
    }

    return translations;
  }

  /// Get cached translation from Hive
  Future<String?> getCachedTranslation(
    String text,
    String targetLanguage, {
    String sourceLanguage = 'en',
  }) async {
    try {
      final box = Hive.box('translation_cache');
      final cacheKey = _cacheKey(text, targetLanguage, sourceLanguage);
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
    String translation, {
    String sourceLanguage = 'en',
  }) async {
    try {
      // Save to memory cache
      final cacheKey = _cacheKey(text, targetLanguage, sourceLanguage);
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

  String _cacheKey(
    String text,
    String targetLanguage,
    String sourceLanguage,
  ) {
    final target = GoogleCloudTranslationService.cloudLanguageCode(
      targetLanguage,
    );
    final source = GoogleCloudTranslationService.cloudLanguageCode(
      sourceLanguage,
    );
    return 'cloud_translation_v2:$source:$target:$text';
  }

  String _fallbackTranslation(String text, String targetLanguage) {
    return AppTranslations.translate(text, targetLanguage);
  }
}

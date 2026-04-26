/// ============================================================
/// Translation Models
/// ============================================================
/// Models for translation requests, responses, and caching.

/// Translation Request Format
class TranslationRequest {
  final String sourceText;
  final String targetLanguageCode;
  final String? context; // Optional context for better translation

  TranslationRequest({
    required this.sourceText,
    required this.targetLanguageCode,
    this.context,
  });

  Map<String, dynamic> toJson() => {
        'sourceText': sourceText,
        'targetLanguage': targetLanguageCode,
        if (context != null) 'context': context,
      };

  factory TranslationRequest.fromJson(Map<String, dynamic> json) {
    return TranslationRequest(
      sourceText: json['sourceText'] as String,
      targetLanguageCode: json['targetLanguage'] as String,
      context: json['context'] as String?,
    );
  }
}

/// Translation Response Format
class TranslationResponse {
  final String translatedText;
  final String languageCode;
  final bool fromCache;

  TranslationResponse({
    required this.translatedText,
    required this.languageCode,
    this.fromCache = false,
  });

  Map<String, dynamic> toJson() => {
        'translatedText': translatedText,
        'languageCode': languageCode,
        'fromCache': fromCache,
      };

  factory TranslationResponse.fromJson(Map<String, dynamic> json) {
    return TranslationResponse(
      translatedText: json['translatedText'] as String,
      languageCode: json['languageCode'] as String,
      fromCache: json['fromCache'] as bool? ?? false,
    );
  }
}

/// Translation Cache Entry
class TranslationCacheEntry {
  final String sourceText;
  final String targetLanguage;
  final String translatedText;
  final DateTime cachedAt;

  TranslationCacheEntry({
    required this.sourceText,
    required this.targetLanguage,
    required this.translatedText,
    required this.cachedAt,
  });

  String get cacheKey => '$targetLanguage:$sourceText';

  bool isExpired(Duration maxAge) {
    return DateTime.now().difference(cachedAt) > maxAge;
  }

  Map<String, dynamic> toMap() {
    return {
      'sourceText': sourceText,
      'targetLanguage': targetLanguage,
      'translatedText': translatedText,
      'cachedAt': cachedAt.toIso8601String(),
    };
  }

  factory TranslationCacheEntry.fromMap(Map<dynamic, dynamic> map) {
    return TranslationCacheEntry(
      sourceText: map['sourceText'] ?? '',
      targetLanguage: map['targetLanguage'] ?? '',
      translatedText: map['translatedText'] ?? '',
      cachedAt: DateTime.parse(map['cachedAt']),
    );
  }
}

/// Language Preference Model
class LanguagePreference {
  final String languageCode;
  final String languageName;
  final DateTime selectedAt;
  final bool isDefault;

  LanguagePreference({
    required this.languageCode,
    required this.languageName,
    required this.selectedAt,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'languageCode': languageCode,
      'languageName': languageName,
      'selectedAt': selectedAt.toIso8601String(),
      'isDefault': isDefault,
    };
  }

  factory LanguagePreference.fromMap(Map<dynamic, dynamic> map) {
    return LanguagePreference(
      languageCode: map['languageCode'] ?? 'en',
      languageName: map['languageName'] ?? 'English',
      selectedAt: DateTime.parse(map['selectedAt']),
      isDefault: map['isDefault'] ?? false,
    );
  }
}

/// Supported Languages Enum
enum SupportedLanguage {
  english('en', 'English'),
  tagalog('tl', 'Tagalog'),
  cebuano('ceb', 'Cebuano'),
  ilocano('ilo', 'Ilocano'),
  hiligaynon('hil', 'Hiligaynon'),
  waray('war', 'Waray'),
  kapampangan('pam', 'Kapampangan'),
  bikol('bik', 'Bikol'),
  pangasinan('pag', 'Pangasinan');

  const SupportedLanguage(this.code, this.displayName);
  final String code;
  final String displayName;

  static SupportedLanguage fromCode(String code) {
    final normalizedCode = code == 'pan' ? 'pag' : code;
    return SupportedLanguage.values.firstWhere(
      (lang) => lang.code == normalizedCode,
      orElse: () => SupportedLanguage.english,
    );
  }

  static List<SupportedLanguage> get all => SupportedLanguage.values;
}

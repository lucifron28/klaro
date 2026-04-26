/// ============================================================
/// Klaro App Constants
/// ============================================================
/// Firebase AI Logic SDK uses the Firebase app configuration, so the app does
/// not read a separate Gemini API key from Dart code or .env.

class AppConstants {
  AppConstants._();

  // Primary Firebase AI model. Keep this first in geminiModelFallbacks.
  static const String geminiModel = 'gemini-3.1-flash-lite-preview';

  // Ordered fallback chain for text-generation features.
  // The app tries the next model only for recoverable model-level failures
  // such as quota/rate limits, overloaded traffic, temporary unavailability,
  // or a retired/unavailable model name.
  static const List<String> geminiModelFallbacks = [
    geminiModel,
    'gemini-3-flash-preview',
    'gemini-2.5-flash-lite',
    'gemini-2.5-flash',
    'gemini-2.5-pro',
    // Legacy active models, kept as last-resort fallbacks while available.
    'gemini-2.0-flash-lite',
    'gemini-2.0-flash',
  ];

  // Reference list of currently relevant Firebase AI Logic Gemini text models.
  // Not every model is used automatically; billing-heavy models should stay
  // manual unless the team explicitly wants them in the fallback chain.
  static const List<String> supportedGeminiTextModels = [
    'gemini-3.1-pro-preview',
    'gemini-3-flash-preview',
    'gemini-3.1-flash-lite-preview',
    'gemini-2.5-pro',
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
    'gemini-2.0-flash',
    'gemini-2.0-flash-lite',
  ];

  // Firebase test accounts for the hackathon demo.
  static const String testStudentEmail = 'student@test.com';
  static const String testStudentPassword = 'password123';
  static const String testTeacherEmail = 'teacher@test.com';
  static const String testTeacherPassword = 'password123';

  // Hive box names.
  static const String lessonsBox = 'lessons';
  static const String scoresBox = 'scores';
  static const String conversationsBox = 'conversations';
  static const String userBox = 'user';
  static const String cacheBox = 'word_cache';

  // App info.
  static const String appName = 'Klaro';
  static const String appTagline = 'Maintindihan ang Bawat Leksyon';
  static const String appVersion = '1.0.0';
}

/// ============================================================
/// Klaro App Constants
/// ============================================================
/// Firebase AI Logic SDK uses the Firebase app configuration, so the app does
/// not read a separate Gemini API key from Dart code or .env.

class AppConstants {
  AppConstants._();

  // Firebase AI model used by GeminiService.
  static const String geminiModel = 'gemini-3-flash-preview';

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

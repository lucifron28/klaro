/// ============================================================
/// Klaro App Constants
/// ============================================================
/// Firebase AI Logic SDK manages the API key server-side,
/// so no Gemini API key is needed in the codebase.

class AppConstants {
  AppConstants._();

  // ── Firebase AI Model ─────────────────────────────────────
  // The model name used by Firebase AI Logic SDK.
  // Change this to switch models (e.g., 'gemini-2.0-flash', 'gemini-1.5-flash').
  static const String geminiModel = 'gemini-2.0-flash';

  // ── Firebase Test Accounts (hardcoded for hackathon demo) ─
  static const String testStudentEmail = 'student1@test.com';
  static const String testStudentPassword = 'password123';
  static const String testTeacherEmail = 'teacher1@test.com';
  static const String testTeacherPassword = 'password123';

  // ── Hive Box Names ────────────────────────────────────────
  static const String lessonsBox = 'lessons';
  static const String scoresBox = 'scores';
  static const String conversationsBox = 'conversations';
  static const String userBox = 'user';
  static const String cacheBox = 'word_cache';

  // ── App Info ──────────────────────────────────────────────
  static const String appName = 'Klaro';
  static const String appTagline = 'Maintindihan ang Bawat Leksyon';
  static const String appVersion = '1.0.0';
}

import 'package:klaro/services/env_service.dart';

/// ============================================================
/// Klaro App Constants
/// ============================================================

class AppConstants {
  AppConstants._();

  // ── API Keys ──────────────────────────────────────────────
  static const String _geminiApiKeyFromDefine =
      String.fromEnvironment('GEMINI_API_KEY');

  static String get geminiApiKey {
    if (_geminiApiKeyFromDefine.isNotEmpty) return _geminiApiKeyFromDefine;
    return EnvService.get('GEMINI_API_KEY');
  }

  // ── Firebase Test Accounts (hardcoded for hackathon demo) ─
  static const String testStudentEmail = 'student1@test.com';
  static const String testStudentPassword = 'password123';
  static const String testTeacherEmail = 'teacher1@test.com';
  static const String testTeacherPassword = 'password123';

  // ── Gemini Model ──────────────────────────────────────────
  static const String geminiModel = 'gemini-flash-latest';

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

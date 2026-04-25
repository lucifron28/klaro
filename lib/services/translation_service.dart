import 'dart:convert';
import 'package:http/http.dart' as http;

/// ============================================================
/// Translation Service
/// ============================================================
/// Handles translation to Tagalog/Taglish.
/// For the hackathon, we use Gemini for translation (bundled with
/// the word simplification call in GeminiService).
/// This service provides a standalone translation option using
/// Google Cloud Translation API if needed.

class TranslationService {
  // For the hackathon MVP, translation is handled inside GeminiService
  // as part of the word simplification call (one API call instead of two).
  //
  // If you need standalone translation, you can use the Google Cloud
  // Translation API with the method below.

  static const String _baseUrl =
      'https://translation.googleapis.com/language/translate/v2';

  /// Translate text to Tagalog using Google Cloud Translation API.
  /// Requires a valid API key.
  Future<String> translateToTagalog(String text, {String? apiKey}) async {
    if (apiKey == null || apiKey.isEmpty) {
      return 'Translation API key not configured.';
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'source': 'en',
          'target': 'tl', // Tagalog language code
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translations = data['data']['translations'] as List;
        if (translations.isNotEmpty) {
          return translations[0]['translatedText'] ?? text;
        }
      }
      return 'Translation unavailable.';
    } catch (e) {
      return 'Translation error: $e';
    }
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GoogleCloudTranslationException implements Exception {
  const GoogleCloudTranslationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GoogleCloudTranslationService {
  GoogleCloudTranslationService({http.Client? client})
      : _client = client ?? http.Client();

  static const _endpoint =
      'https://translation.googleapis.com/language/translate/v2';
  static const _apiKeyName = 'GOOGLE_TRANSLATE_API_KEY';
  static const _timeout = Duration(seconds: 12);

  final http.Client _client;

  Future<String> translateText(
    String text,
    String targetLanguage, {
    String sourceLanguage = 'en',
  }) async {
    final translated = await translateTexts(
      [text],
      targetLanguage,
      sourceLanguage: sourceLanguage,
    );
    return translated.first;
  }

  Future<List<String>> translateTexts(
    List<String> texts,
    String targetLanguage, {
    String sourceLanguage = 'en',
  }) async {
    final normalizedTarget = cloudLanguageCode(targetLanguage);
    final normalizedSource = cloudLanguageCode(sourceLanguage);

    if (normalizedTarget == normalizedSource || normalizedTarget == 'en') {
      return texts;
    }

    final nonEmptyTexts =
        texts.where((text) => text.trim().isNotEmpty).toList();
    if (nonEmptyTexts.length != texts.length) {
      return texts;
    }

    final apiKey = _apiKey;
    if (apiKey.isEmpty) {
      throw const GoogleCloudTranslationException(
        'Google Cloud Translation API key is missing. Set GOOGLE_TRANSLATE_API_KEY in .env.',
      );
    }

    final uri = Uri.parse(_endpoint).replace(
      queryParameters: {'key': apiKey},
    );

    final body = {
      'q': texts,
      'source': normalizedSource,
      'target': normalizedTarget,
      'format': 'text',
    };

    try {
      final response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw GoogleCloudTranslationException(
          _extractErrorMessage(response.body, response.statusCode),
        );
      }

      final decoded = jsonDecode(response.body);
      final translations =
          decoded['data']?['translations'] as List<dynamic>? ?? [];

      if (translations.length != texts.length) {
        throw const GoogleCloudTranslationException(
          'Google Cloud Translation returned an unexpected response.',
        );
      }

      return translations.map((item) {
        final translatedText = item['translatedText']?.toString();
        if (translatedText == null || translatedText.trim().isEmpty) {
          throw const GoogleCloudTranslationException(
            'Google Cloud Translation returned an empty translation.',
          );
        }
        return _decodeHtmlEntities(translatedText.trim());
      }).toList();
    } on GoogleCloudTranslationException {
      rethrow;
    } on TimeoutException {
      throw const GoogleCloudTranslationException(
        'Google Cloud Translation request timed out. Check your internet connection.',
      );
    } catch (error, stackTrace) {
      debugPrint('Google Cloud Translation failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const GoogleCloudTranslationException(
        'Google Cloud Translation is unavailable right now.',
      );
    }
  }

  static String cloudLanguageCode(String languageCode) {
    switch (languageCode.trim().toLowerCase()) {
      case 'pan':
      case 'pag':
        return 'pag';
      case 'fil':
      case 'tl':
        return 'tl';
      default:
        return languageCode.trim().toLowerCase();
    }
  }

  String get _apiKey {
    const dartDefineKey = String.fromEnvironment(_apiKeyName);
    if (dartDefineKey.trim().isNotEmpty) {
      return dartDefineKey.trim();
    }

    try {
      return dotenv.env[_apiKeyName]?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  String _extractErrorMessage(String responseBody, int statusCode) {
    try {
      final decoded = jsonDecode(responseBody);
      final message = decoded['error']?['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return 'Google Cloud Translation failed: $message';
      }
    } catch (_) {
      // Fall through to the generic message below.
    }

    return 'Google Cloud Translation failed with HTTP $statusCode.';
  }

  static String _decodeHtmlEntities(String value) {
    return value
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }
}

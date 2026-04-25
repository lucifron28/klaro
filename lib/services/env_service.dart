import 'package:flutter/services.dart';

/// Loads simple KEY=VALUE pairs from the app's .env asset.
class EnvService {
  EnvService._();

  static final Map<String, String> _values = {};

  static Future<void> load() async {
    try {
      final content = await rootBundle.loadString('.env');
      _values
        ..clear()
        ..addAll(_parse(content));
    } catch (_) {
      _values.clear();
    }
  }

  static String get(String key) => _values[key] ?? '';

  static Map<String, String> _parse(String content) {
    final values = <String, String>{};

    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      final separatorIndex = line.indexOf('=');
      if (separatorIndex <= 0) continue;

      final key = line.substring(0, separatorIndex).trim();
      var value = line.substring(separatorIndex + 1).trim();

      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }

      values[key] = value;
    }

    return values;
  }
}

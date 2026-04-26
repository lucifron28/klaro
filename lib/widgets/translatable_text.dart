import 'package:flutter/material.dart';
import 'package:klaro/services/local_storage_service.dart';
import 'package:klaro/services/translation_service.dart';

/// ============================================================
/// Translatable Text Widget
/// ============================================================
/// A widget that automatically translates static UI text based on
/// the user's preferred language using Google Cloud Translation API.
///
/// Usage:
/// ```dart
/// TranslatableText('Hello', style: TextStyle(fontSize: 16))
/// ```

class TranslatableText extends StatefulWidget {
  final String text;
  final String? languageCode;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatableText(
    this.text, {
    super.key,
    this.languageCode,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  State<TranslatableText> createState() => _TranslatableTextState();
}

class _TranslatableTextState extends State<TranslatableText> {
  final LocalStorageService _localStorage = LocalStorageService();
  final TranslationService _translationService = TranslationService();
  String? _translatedText;

  @override
  void initState() {
    super.initState();
    _loadTranslation();
  }

  @override
  void didUpdateWidget(TranslatableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload translation if the source text or active language changed.
    if (oldWidget.text != widget.text ||
        oldWidget.languageCode != widget.languageCode) {
      _loadTranslation();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload translation when dependencies change (e.g., after navigation)
    _loadTranslation();
  }

  Future<void> _loadTranslation() async {
    try {
      final languageCode = widget.languageCode ??
          await _localStorage.getLanguagePreference() ??
          'en';

      final translated = await _translationService.translate(
        widget.text,
        languageCode,
      );

      if (mounted) {
        setState(() {
          _translatedText = translated;
        });
      }
    } catch (e) {
      // Fallback to original text on error
      if (mounted) {
        setState(() {
          _translatedText = widget.text;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show original text while loading or if translation failed
    final displayText = _translatedText ?? widget.text;

    return Text(
      displayText,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow ?? TextOverflow.visible,
      softWrap: true,
    );
  }
}

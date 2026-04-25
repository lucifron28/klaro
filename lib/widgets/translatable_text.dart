import 'package:flutter/material.dart';
import 'package:klaro/services/local_storage_service.dart';
import 'package:klaro/utils/translations.dart';

/// ============================================================
/// Translatable Text Widget
/// ============================================================
/// A widget that automatically translates static UI text based on
/// the user's preferred language using hardcoded translations.
///
/// Usage:
/// ```dart
/// TranslatableText('Hello', style: TextStyle(fontSize: 16))
/// ```

class TranslatableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatableText(
    this.text, {
    super.key,
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
  String? _translatedText;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTranslation();
  }

  @override
  void didUpdateWidget(TranslatableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload translation if the text changed
    if (oldWidget.text != widget.text) {
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
      // Get preferred language from local storage
      final languageCode = await _localStorage.getLanguagePreference() ?? 'en';
      
      // Get hardcoded translation
      final translated = AppTranslations.translate(widget.text, languageCode);

      if (mounted) {
        setState(() {
          _translatedText = translated;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback to original text on error
      if (mounted) {
        setState(() {
          _translatedText = widget.text;
          _isLoading = false;
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
      overflow: widget.overflow,
    );
  }
}

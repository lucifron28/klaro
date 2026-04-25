import 'package:flutter/material.dart';
import 'package:klaro/services/local_storage_service.dart';
import 'package:klaro/utils/theme.dart';
import 'package:klaro/widgets/translatable_text.dart';

/// ============================================================
/// Word Popup (Bottom Sheet)
/// ============================================================
/// Shows the simplified explanation and translation in the user's
/// preferred language when a student taps on a word in the lesson text.

class WordPopup extends StatefulWidget {
  final String word;
  final String explanation;
  final String translation;
  final bool isLoading;

  const WordPopup({
    super.key,
    required this.word,
    required this.explanation,
    required this.translation,
    this.isLoading = false,
  });

  /// Show this widget as a modal bottom sheet
  static Future<void> show(
    BuildContext context, {
    required String word,
    required String explanation,
    required String tagalog,
    bool isLoading = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: !isLoading,
      enableDrag: !isLoading,
      backgroundColor: Colors.transparent,
      builder: (context) => WordPopup(
        word: word,
        explanation: explanation,
        translation: tagalog,
        isLoading: isLoading,
      ),
    );
  }

  @override
  State<WordPopup> createState() => _WordPopupState();
}

class _WordPopupState extends State<WordPopup> {
  String _languageName = 'Translation';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLanguageName();
  }

  @override
  void didUpdateWidget(WordPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload language name if widget is updated
    _loadLanguageName();
  }

  Future<void> _loadLanguageName() async {
    final localStorage = LocalStorageService();
    final languageCode = await localStorage.getLanguagePreference() ?? 'en';
    
    // Map language codes to display names
    final languageNames = {
      'en': 'English',
      'tl': 'Tagalog',
      'ceb': 'Cebuano',
      'war': 'Waray',
      'ilo': 'Ilocano',
      'hil': 'Hiligaynon',
      'pam': 'Kapampangan',
      'bik': 'Bikol',
      'pag': 'Pangasinan',
    };
    
    if (mounted) {
      setState(() {
        _languageName = languageNames[languageCode] ?? 'Translation';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Word title
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: KlaroTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.word,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: KlaroTheme.primaryBlue,
                    ),
                  ),
                ),
                Spacer(),
                Icon(Icons.auto_awesome,
                    color: KlaroTheme.accentYellow, size: 20),
              ],
            ),
            SizedBox(height: 20),

            if (widget.isLoading || _isLoading) ...[
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: KlaroTheme.primaryBlue),
                    SizedBox(height: 12),
                    TranslatableText(
                      'Simplifying...',
                      style: TextStyle(color: KlaroTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Simple Explanation (in English - not translated)
              _buildSection(
                icon: Icons.lightbulb_outline,
                iconColor: KlaroTheme.accentYellow,
                titleKey: 'Simple Explanation',
                content: widget.explanation,
              ),
              SizedBox(height: 16),

              // Translation in preferred language
              _buildSection(
                icon: Icons.translate,
                iconColor: KlaroTheme.lightBlue,
                titleKey: 'Translation',
                content: widget.translation,
                showLanguageName: true,
              ),
              SizedBox(height: 24),

              // Got it button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KlaroTheme.primaryBlue,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: TranslatableText('Got it!', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String titleKey,
    required String content,
    bool showLanguageName = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KlaroTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              SizedBox(width: 8),
              if (showLanguageName)
                Text(
                  _languageName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: KlaroTheme.textMuted,
                    letterSpacing: 0.5,
                  ),
                )
              else
                TranslatableText(
                  titleKey,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: KlaroTheme.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: KlaroTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

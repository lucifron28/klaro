import 'package:flutter/material.dart';
import 'package:klaro/utils/theme.dart';

/// ============================================================
/// Word Popup (Bottom Sheet)
/// ============================================================
/// Shows the simplified explanation and Tagalog translation
/// when a student taps on a word in the lesson text.

class WordPopup extends StatelessWidget {
  final String word;
  final String explanation;
  final String tagalog;
  final bool isLoading;

  const WordPopup({
    super.key,
    required this.word,
    required this.explanation,
    required this.tagalog,
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
        tagalog: tagalog,
        isLoading: isLoading,
      ),
    );
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
                    word,
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

            if (isLoading) ...[
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: KlaroTheme.primaryBlue),
                    SizedBox(height: 12),
                    Text(
                      'Simplifying...',
                      style: TextStyle(color: KlaroTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Simple Explanation
              _buildSection(
                icon: Icons.lightbulb_outline,
                iconColor: KlaroTheme.accentYellow,
                title: 'Simple Explanation',
                content: explanation,
              ),
              SizedBox(height: 16),

              // Tagalog Translation
              _buildSection(
                icon: Icons.translate,
                iconColor: KlaroTheme.lightBlue,
                title: 'Tagalog / Taglish',
                content: tagalog,
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
                  child: Text('Got it!', style: TextStyle(fontSize: 16)),
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
    required String title,
    required String content,
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
              Text(
                title,
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

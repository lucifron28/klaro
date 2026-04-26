import 'package:flutter/material.dart';
import 'package:klaro/utils/theme.dart';

/// ============================================================
/// Message Bubble Widget
/// ============================================================
/// Chat bubble for the AI conversation screen.

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isStudent;
  final bool isLoading;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isStudent,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayMessage = isStudent ? message : _cleanMarkdown(message);

    return Padding(
      padding: EdgeInsets.only(
        left: isStudent ? 48 : 0,
        right: isStudent ? 0 : 48,
        bottom: 12,
      ),
      child: Row(
        mainAxisAlignment:
            isStudent ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isStudent) ...[
            // AI avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: KlaroTheme.primaryBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'K',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isStudent
                    ? KlaroTheme.primaryBlue
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(isStudent ? 16 : 4),
                  bottomRight: Radius.circular(isStudent ? 4 : 16),
                ),
                border: isStudent
                    ? null
                    : Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: isLoading
                  ? _buildLoadingIndicator()
                  : Text(
                      displayMessage,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: isStudent ? Colors.white : KlaroTheme.textDark,
                      ),
                    ),
            ),
          ),
          if (isStudent) ...[
            SizedBox(width: 8),
            // Student avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: KlaroTheme.lightBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(0),
        SizedBox(width: 4),
        _buildDot(1),
        SizedBox(width: 4),
        _buildDot(2),
      ],
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: KlaroTheme.textMuted.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  String _cleanMarkdown(String value) {
    return value
        .replaceAll(RegExp(r'```[\s\S]*?```'), '')
        .replaceAllMapped(
          RegExp(r'\[([^\]]+)\]\([^)]+\)'),
          (match) => match.group(1) ?? '',
        )
        .replaceAll(RegExp(r'`([^`]+)`'), r'$1')
        .replaceAll(RegExp(r'^\s{0,3}#{1,6}\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^\s{0,3}>\s?', multiLine: true), '')
        .replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1')
        .replaceAll(RegExp(r'__([^_]+)__'), r'$1')
        .replaceAll(RegExp(r'\*([^*\n]+)\*'), r'$1')
        .replaceAll(RegExp(r'_([^_\n]+)_'), r'$1')
        .replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '- ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}

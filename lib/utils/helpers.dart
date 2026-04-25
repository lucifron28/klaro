import 'dart:convert';
import 'package:intl/intl.dart';

/// ============================================================
/// Utility Helpers
/// ============================================================

class Helpers {
  Helpers._();

  /// Format a DateTime to a readable string (e.g., "Apr 25, 2026")
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Format a DateTime to include time (e.g., "Apr 25, 2026 at 3:45 PM")
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, yyyy \'at\' h:mm a').format(date);
  }

  /// Calculate percentage from score and total
  static int calculatePercentage(int score, int total) {
    if (total == 0) return 0;
    return ((score / total) * 100).round();
  }

  /// Calculate overall score from quiz percentage and AI score (1-5)
  static int calculateOverallScore(int quizPercent, double aiScore) {
    final aiPercent = (aiScore / 5.0) * 100;
    return ((quizPercent + aiPercent) / 2).round();
  }

  /// Get a performance message based on overall score
  static String getPerformanceMessage(int overallPercent) {
    if (overallPercent >= 90) {
      return 'Outstanding! You have excellent understanding of this lesson.';
    } else if (overallPercent >= 75) {
      return 'Great job! You have a solid grasp of the material.';
    } else if (overallPercent >= 60) {
      return 'Good effort! Review the parts you found challenging.';
    } else if (overallPercent >= 40) {
      return 'Keep going! Try re-reading the lesson and taking the quiz again.';
    } else {
      return 'Don\'t give up! Let\'s review the lesson together.';
    }
  }

  /// Get a color-coded grade label
  static String getGradeLabel(int percent) {
    if (percent >= 90) return 'A';
    if (percent >= 80) return 'B';
    if (percent >= 70) return 'C';
    if (percent >= 60) return 'D';
    return 'F';
  }

  /// Try to parse JSON from a string that may contain markdown code blocks
  static dynamic tryParseJson(String text) {
    try {
      // Remove markdown code block markers if present
      String cleaned = text.trim();
      if (cleaned.startsWith('```json')) {
        cleaned = cleaned.substring(7);
      } else if (cleaned.startsWith('```')) {
        cleaned = cleaned.substring(3);
      }
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3);
      }
      return jsonDecode(cleaned.trim());
    } catch (e) {
      return null;
    }
  }

  /// Split lesson content into individual words for tappable text
  static List<String> splitIntoWords(String text) {
    return text.split(RegExp(r'(\s+)'));
  }

  /// Check if a word is a "content word" worth explaining (not a, the, is, etc.)
  static bool isContentWord(String word) {
    final stopWords = {
      'a', 'an', 'the', 'is', 'are', 'was', 'were', 'be', 'been', 'being',
      'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could',
      'should', 'may', 'might', 'shall', 'can', 'need', 'dare', 'ought',
      'used', 'to', 'of', 'in', 'for', 'on', 'with', 'at', 'by', 'from',
      'as', 'into', 'through', 'during', 'before', 'after', 'above', 'below',
      'between', 'out', 'off', 'over', 'under', 'again', 'further', 'then',
      'once', 'and', 'but', 'or', 'nor', 'not', 'so', 'yet', 'both',
      'either', 'neither', 'each', 'every', 'all', 'any', 'few', 'more',
      'most', 'other', 'some', 'such', 'no', 'only', 'own', 'same', 'than',
      'too', 'very', 'just', 'because', 'if', 'when', 'where', 'how', 'what',
      'which', 'who', 'whom', 'this', 'that', 'these', 'those', 'it', 'its',
      'i', 'me', 'my', 'we', 'our', 'you', 'your', 'he', 'him', 'his',
      'she', 'her', 'they', 'them', 'their',
    };
    final cleaned = word.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    return cleaned.length > 2 && !stopWords.contains(cleaned);
  }
}

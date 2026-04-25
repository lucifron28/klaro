import 'package:flutter/material.dart';
import 'package:klaro/models/learned_concept.dart';
import 'package:klaro/models/lesson.dart';
import 'package:klaro/services/gemini_service.dart';
import 'package:klaro/services/local_storage_service.dart';
import 'package:klaro/screens/learning_recap_screen.dart';
import 'package:klaro/widgets/word_popup.dart';
import 'package:klaro/utils/helpers.dart';
import 'package:klaro/utils/theme.dart';

/// ============================================================
/// Lesson Reading Screen
/// ============================================================
/// Interactive reading experience where students can tap on words
/// to see simplified explanations and Tagalog translations.

class LessonReadingScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonReadingScreen({super.key, required this.lesson});

  @override
  State<LessonReadingScreen> createState() => _LessonReadingScreenState();
}

class _LessonReadingScreenState extends State<LessonReadingScreen> {
  final GeminiService _geminiService = GeminiService();
  final LocalStorageService _localStorage = LocalStorageService();
  final Map<String, LearnedConcept> _learnedConcepts = {};
  String? _selectedWord;

  @override
  void initState() {
    super.initState();
    _loadLearnedConcepts();
  }

  Future<void> _loadLearnedConcepts() async {
    final saved = await _localStorage.getLearnedConcepts(widget.lesson.id);
    if (!mounted) return;

    setState(() {
      for (final concept in saved) {
        _learnedConcepts[concept.word.toLowerCase()] = concept;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KlaroTheme.surfaceLight,
      appBar: AppBar(
        title: Text(widget.lesson.title),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 12),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: KlaroTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app, size: 14, color: KlaroTheme.primaryBlue),
                SizedBox(width: 4),
                Text(
                  'Tap words',
                  style: TextStyle(
                    fontSize: 12,
                    color: KlaroTheme.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Instruction banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: KlaroTheme.lightBlue.withOpacity(0.15),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: KlaroTheme.primaryBlue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tap any word you don\'t understand to see a simple explanation and Tagalog translation.',
                    style: TextStyle(
                      fontSize: 12,
                      color: KlaroTheme.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lesson content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: _buildInteractiveText(),
              ),
            ),
          ),

          // Learning recap button
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openLearningRecap,
                icon: Icon(Icons.fact_check_rounded),
                label: Text('Review Learning Recap'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KlaroTheme.accentYellow,
                  foregroundColor: KlaroTheme.textDark,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the lesson text with tappable words
  Widget _buildInteractiveText() {
    final paragraphs = widget.lesson.content.split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((paragraph) {
        if (paragraph.trim().isEmpty) return SizedBox(height: 8);

        // Check if it's a title (first line or short line)
        final isTitle = paragraph.trim() == widget.lesson.title ||
            (paragraph.trim().length < 40 && !paragraph.contains('.'));

        if (isTitle) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              paragraph.trim(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: KlaroTheme.textDark,
              ),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Wrap(
            children: _buildTappableWords(paragraph.trim()),
          ),
        );
      }).toList(),
    );
  }

  /// Split paragraph into tappable word spans
  List<Widget> _buildTappableWords(String text) {
    // Split by spaces but keep punctuation attached
    final words = text.split(' ');
    final widgets = <Widget>[];

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final cleanWord = word.replaceAll(RegExp(r'[^a-zA-Z]'), '');
      final isKeyTerm = widget.lesson.keyTerms
          .any((term) => term.toLowerCase() == cleanWord.toLowerCase());
      final isContentWord = Helpers.isContentWord(cleanWord);
      final isHighlighted =
          _selectedWord?.toLowerCase() == cleanWord.toLowerCase();

      widgets.add(
        GestureDetector(
          onTap: isContentWord ? () => _onWordTapped(cleanWord, text) : null,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 1, vertical: 2),
            decoration: isHighlighted
                ? BoxDecoration(
                    color: KlaroTheme.lightBlue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: Text(
              i < words.length - 1 ? '$word ' : word,
              style: TextStyle(
                fontSize: 16,
                height: 1.8,
                color: KlaroTheme.textDark,
                fontWeight: isKeyTerm ? FontWeight.w600 : FontWeight.w400,
                decoration: isKeyTerm ? TextDecoration.underline : null,
                decorationColor: KlaroTheme.primaryBlue.withOpacity(0.4),
                decorationStyle: TextDecorationStyle.dotted,
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  /// Handle word tap: show bottom sheet with explanation
  Future<void> _onWordTapped(String word, String context) async {
    setState(() {
      _selectedWord = word;
    });

    // Check local cache first
    final cached = _localStorage.getCachedWordExplanation(word);
    if (cached != null && _hasUsableExplanation(cached)) {
      await _recordLearnedConcept(word, cached);
      _showWordPopup(word, cached['explanation']!, cached['tagalog']!);
      return;
    }

    // Show loading popup
    if (mounted) {
      WordPopup.show(
        this.context,
        word: word,
        explanation: '',
        tagalog: '',
        isLoading: true,
      );
    }

    // Call Gemini API
    try {
      final result = await _geminiService.simplifyWord(word, context: context);

      // Cache the result
      await _localStorage.cacheWordExplanation(word, result);
      await _recordLearnedConcept(word, result);

      // Close loading popup and show result
      if (mounted) {
        Navigator.pop(this.context); // Close loading popup
        _showWordPopup(word, result['explanation']!, result['tagalog']!);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(this.context); // Close loading popup
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
              content: Text('Unable to explain "$word". Please try again.')),
        );
      }
    }
  }

  void _showWordPopup(String word, String explanation, String tagalog) {
    WordPopup.show(
      context,
      word: word,
      explanation: explanation,
      tagalog: tagalog,
    );
  }

  Future<void> _recordLearnedConcept(
    String word,
    Map<String, String> data,
  ) async {
    if (!_hasUsableExplanation(data)) return;

    final concept = LearnedConcept(
      word: word,
      explanation: data['explanation']!.trim(),
      tagalog: (data['tagalog'] ?? '').trim(),
      selectedAt: DateTime.now(),
    );

    if (mounted) {
      setState(() {
        _learnedConcepts[word.toLowerCase()] = concept;
      });
    } else {
      _learnedConcepts[word.toLowerCase()] = concept;
    }

    await _localStorage.saveLearnedConcept(widget.lesson.id, concept);
  }

  Future<void> _openLearningRecap() async {
    await _localStorage.markLessonCompleted(widget.lesson.id);
    final saved = await _localStorage.getLearnedConcepts(widget.lesson.id);
    final merged = {
      for (final concept in saved) concept.word.toLowerCase(): concept,
      ..._learnedConcepts,
    }.values.toList();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LearningRecapScreen(
          lesson: widget.lesson,
          learnedConcepts: merged,
        ),
      ),
    );
  }

  bool _hasUsableExplanation(Map<String, String> data) {
    final explanation = data['explanation']?.trim() ?? '';
    return explanation.isNotEmpty &&
        !explanation.toLowerCase().startsWith('unable to explain') &&
        !explanation.startsWith('{') &&
        !explanation.contains('"explanation"');
  }
}

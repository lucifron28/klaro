import 'package:flutter/material.dart';
import 'package:klaro/models/learned_concept.dart';
import 'package:klaro/models/lesson.dart';
import 'package:klaro/models/app_user.dart';
import 'package:klaro/screens/quiz_screen.dart';
import 'package:klaro/services/google_cloud_translation_service.dart';
import 'package:klaro/services/local_storage_service.dart';
import 'package:klaro/services/translation_service.dart';
import 'package:klaro/utils/theme.dart';
import 'package:klaro/widgets/translatable_text.dart';

/// ============================================================
/// Learning Recap Screen
/// ============================================================
/// Reviews words and concepts the student explored before the quiz.

class LearningRecapScreen extends StatefulWidget {
  final Lesson lesson;
  final List<LearnedConcept> learnedConcepts;

  const LearningRecapScreen({
    super.key,
    required this.lesson,
    required this.learnedConcepts,
  });

  @override
  State<LearningRecapScreen> createState() => _LearningRecapScreenState();
}

class _LearningRecapScreenState extends State<LearningRecapScreen> {
  final LocalStorageService _localStorage = LocalStorageService();
  final TranslationService _translationService = TranslationService();
  AppUser? _user;
  late List<LearnedConcept> _concepts;
  String _currentLanguageCode = 'tl';
  bool _isRefreshingConcepts = false;

  @override
  void initState() {
    super.initState();
    _concepts = [...widget.learnedConcepts];
    _loadUser();
    _refreshConceptDialect();
  }

  Future<void> _loadUser() async {
    final user = await _localStorage.getUser();
    if (mounted) {
      setState(() => _user = user);
    }
  }

  Future<void> _refreshConceptDialect() async {
    final languageCode = await _localStorage.getLanguagePreference() ?? 'tl';
    final normalizedLanguage =
        GoogleCloudTranslationService.cloudLanguageCode(languageCode);

    if (mounted) {
      setState(() {
        _currentLanguageCode = normalizedLanguage;
        _isRefreshingConcepts = true;
      });
    }

    final refreshed = <LearnedConcept>[];
    var changed = false;

    for (final concept in _concepts) {
      final conceptLanguage = GoogleCloudTranslationService.cloudLanguageCode(
        concept.languageCode,
      );
      final needsRefresh = concept.tagalog.trim().isEmpty ||
          conceptLanguage != normalizedLanguage;

      if (!needsRefresh) {
        refreshed.add(concept);
        continue;
      }

      final translated = await _translationService.translate(
        concept.explanation,
        normalizedLanguage,
      );

      refreshed.add(
        concept.copyWith(
          tagalog: translated,
          languageCode: normalizedLanguage,
        ),
      );
      changed = true;
    }

    if (changed) {
      await _localStorage.saveLearnedConcepts(widget.lesson.id, refreshed);
    }

    if (mounted) {
      setState(() {
        _concepts = refreshed;
        _currentLanguageCode = normalizedLanguage;
        _isRefreshingConcepts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final concepts = [..._concepts]
      ..sort((a, b) => b.selectedAt.compareTo(a.selectedAt)); // Recent first

    return Scaffold(
      backgroundColor: KlaroTheme.surfaceLight,
      appBar: AppBar(
        title: TranslatableText('Learning Recap'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, 16, 20, 18),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.lesson.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: KlaroTheme.textDark,
                  ),
                ),
                SizedBox(height: 6),
                TranslatableText(
                  concepts.isEmpty
                      ? 'Review the concepts you explored below before the quiz.'
                      : 'Review your personalized learning recap before starting the quiz.',
                  style: TextStyle(
                    fontSize: 14,
                    color: KlaroTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                if (concepts.isEmpty)
                  _buildEmptyState()
                else ...[
                  if (_isRefreshingConcepts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(
                        color: KlaroTheme.primaryBlue,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ...concepts.map(_buildConceptCard),
                ],
              ],
            ),
          ),
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
                onPressed: _user == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizScreen(lesson: widget.lesson),
                          ),
                        );
                      },
                icon: Icon(Icons.quiz_rounded),
                label: TranslatableText('Start Quiz'),
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

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.touch_app_rounded, color: KlaroTheme.primaryBlue),
          SizedBox(width: 12),
          Expanded(
            child: TranslatableText(
              'Your learning recap will appear here after you tap words you want to learn more about while reading.',
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: KlaroTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConceptCard(LearnedConcept concept) {
    return Container(
      margin: EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: KlaroTheme.lightBlue.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  concept.word,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: KlaroTheme.primaryBlue,
                  ),
                ),
              ),
              Spacer(),
              Icon(Icons.check_circle, color: KlaroTheme.success, size: 20),
            ],
          ),
          SizedBox(height: 14),
          _buildRecapLine(
            icon: Icons.lightbulb_outline,
            color: KlaroTheme.accentYellow,
            text: concept.explanation,
          ),
          SizedBox(height: 10),
          _buildRecapLine(
            icon: Icons.translate,
            color: KlaroTheme.lightBlue,
            label: _languageName(_currentLanguageCode),
            text: concept.tagalog,
          ),
        ],
      ),
    );
  }

  Widget _buildRecapLine({
    required IconData icon,
    required Color color,
    String? label,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null) ...[
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: KlaroTheme.textMuted,
                  ),
                ),
                SizedBox(height: 2),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: KlaroTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _languageName(String code) {
    const names = {
      'en': 'English',
      'tl': 'Tagalog',
      'ceb': 'Cebuano',
      'ilo': 'Ilocano',
      'hil': 'Hiligaynon',
      'war': 'Waray',
      'pam': 'Kapampangan',
      'bik': 'Bikol',
      'pag': 'Pangasinan',
      'pan': 'Pangasinan',
    };
    return names[code] ?? 'Translation';
  }
}

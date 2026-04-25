import 'package:flutter/material.dart';
import 'package:klaro/models/lesson.dart';
import 'package:klaro/models/ai_conversation.dart';
import 'package:klaro/models/app_user.dart';
import 'package:klaro/services/gemini_service.dart';
import 'package:klaro/services/local_storage_service.dart';
import 'package:klaro/services/firestore_service.dart';
import 'package:klaro/screens/student_home_screen.dart';
import 'package:klaro/widgets/message_bubble.dart';
import 'package:klaro/utils/theme.dart';

/// ============================================================
/// AI Assessment Screen
/// ============================================================
/// Conversation-based assessment that tracks correct/incorrect answers.
/// Students need 3 correct answers to pass, 3 incorrect to fail.

class AIAssessmentScreen extends StatefulWidget {
  final Lesson lesson;

  const AIAssessmentScreen({
    super.key,
    required this.lesson,
  });

  @override
  State<AIAssessmentScreen> createState() => _AIAssessmentScreenState();
}

class _AIAssessmentScreenState extends State<AIAssessmentScreen> {
  final GeminiService _geminiService = GeminiService();
  final LocalStorageService _localStorage = LocalStorageService();
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  final List<Map<String, String>> _conversationHistory = [];
  bool _isAITyping = false;
  bool _isAssessmentComplete = false;
  int _correctAnswers = 0;
  int _incorrectAnswers = 0;
  int _totalAttempts = 0;
  bool _passed = false;
  String _summary = '';
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _startAssessment();
  }

  Future<void> _loadUser() async {
    final user = await _localStorage.getUser();
    if (mounted) {
      setState(() => _user = user);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAssessment() {
    final greeting = _geminiService.getAssessmentGreeting(widget.lesson.title);
    _addMessage('ai', greeting);
    _conversationHistory.add({'role': 'ai', 'message': greeting});
  }

  void _addMessage(String role, String message) {
    setState(() {
      _messages.add(ChatMessage(role: role, message: message));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isAITyping || _isAssessmentComplete) return;

    _messageController.clear();

    // Add student message
    _addMessage('student', text);
    _conversationHistory.add({'role': 'student', 'message': text});

    // Show typing indicator
    setState(() => _isAITyping = true);

    try {
      final response = await _geminiService.conductAssessmentConversation(
        widget.lesson.content,
        _conversationHistory,
        _correctAnswers,
        _incorrectAnswers,
      );

      final aiMessage = response['message'] as String;
      final isComplete = response['isComplete'] as bool? ?? false;

      _addMessage('ai', aiMessage);
      _conversationHistory.add({'role': 'ai', 'message': aiMessage});

      if (isComplete) {
        // Assessment complete - AI triggered completion
        _correctAnswers = response['correctAnswers'] ?? _correctAnswers;
        _incorrectAnswers = response['totalAttempts'] != null 
            ? (response['totalAttempts'] as int) - _correctAnswers
            : _incorrectAnswers;
        _totalAttempts = response['totalAttempts'] ?? (_correctAnswers + _incorrectAnswers);
        _passed = response['passed'] ?? false;
        _summary = response['summary'] ?? 'Assessment completed.';

        setState(() => _isAssessmentComplete = true);

        // Calculate score (percentage)
        final score = _totalAttempts > 0 
            ? ((_correctAnswers / _totalAttempts) * 100).toDouble()
            : 0.0;

        // Save assessment
        final assessment = AIConversation(
          lessonId: widget.lesson.id,
          lessonTitle: widget.lesson.title,
          subject: widget.lesson.subject,
          correctAnswers: _correctAnswers,
          totalAttempts: _totalAttempts,
          score: score,
          summary: _summary,
          date: DateTime.now(),
          messages: _messages,
        );

        await _localStorage.saveAIConversation(assessment, userId: _user?.uid);
        
        // Save to Firestore if available and user is loaded
        if (_user != null) {
          try {
            await _firestoreService.saveAssessmentResult(_user!.uid, assessment);
          } catch (e) {
            debugPrint('Failed to save to Firestore: $e');
          }
        }
        
        // Show completion dialog
        _showCompletionDialog();
      } else {
        // Update score tracking
        final isQuestion = response['isQuestion'] as bool? ?? false;
        if (!isQuestion) {
          final isCorrect = response['isCorrect'] as bool? ?? false;
          setState(() {
            if (isCorrect) {
              _correctAnswers++;
              // Show brief success feedback
              _showFeedbackSnackbar('✓ Correct!', KlaroTheme.success);
            } else {
              _incorrectAnswers++;
              // Show brief feedback
              _showFeedbackSnackbar('Keep trying! Read the explanation above.', KlaroTheme.warning);
            }
          });
          
          // Manual check for completion (fallback if AI doesn't trigger it)
          if (_correctAnswers >= 3 || _incorrectAnswers >= 3) {
            _completeAssessment();
          }
        } else {
          // It was a question - show helpful indicator
          _showFeedbackSnackbar('💡 Here\'s some help for you!', KlaroTheme.primaryBlue);
        }
      }
    } catch (e) {
      _addMessage('ai', 'Sorry, I had trouble understanding. Can you try again? Or ask me for help if you need it!');
    } finally {
      setState(() => _isAITyping = false);
    }
  }

  void _showFeedbackSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 80, left: 16, right: 16),
      ),
    );
  }

  Future<void> _completeAssessment() async {
    // Prevent multiple calls
    if (_isAssessmentComplete) return;
    
    setState(() => _isAssessmentComplete = true);
    
    _totalAttempts = _correctAnswers + _incorrectAnswers;
    _passed = _correctAnswers >= 3;
    _summary = _passed 
        ? 'Successfully demonstrated understanding of key concepts'
        : 'Needs to review: ${widget.lesson.title}';

    // Calculate score (percentage)
    final score = _totalAttempts > 0 
        ? ((_correctAnswers / _totalAttempts) * 100).toDouble()
        : 0.0;

    // Save assessment
    final assessment = AIConversation(
      lessonId: widget.lesson.id,
      lessonTitle: widget.lesson.title,
      subject: widget.lesson.subject,
      correctAnswers: _correctAnswers,
      totalAttempts: _totalAttempts,
      score: score,
      summary: _summary,
      date: DateTime.now(),
      messages: _messages,
    );

    await _localStorage.saveAIConversation(assessment, userId: _user?.uid);
    
    // Save to Firestore if available and user is loaded
    if (_user != null) {
      try {
        await _firestoreService.saveAssessmentResult(_user!.uid, assessment);
      } catch (e) {
        debugPrint('Failed to save to Firestore: $e');
      }
    }

    // Show completion dialog
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _passed 
                      ? KlaroTheme.success.withOpacity(0.1)
                      : KlaroTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _passed ? KlaroTheme.success : KlaroTheme.warning,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _passed ? Icons.check_circle : Icons.info_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      _passed ? 'Assessment Passed!' : 'Keep Learning!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _passed ? KlaroTheme.success : KlaroTheme.warning,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Score display
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assessment, color: KlaroTheme.primaryBlue),
                          SizedBox(width: 8),
                          Text(
                            'Score: $_correctAnswers/$_totalAttempts correct',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: KlaroTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Message
                    Text(
                      _passed
                          ? 'Great job! You\'ve demonstrated a good understanding of this lesson. Keep up the excellent work!'
                          : 'Don\'t worry! Learning takes practice. Review the lesson again and you\'ll do better next time.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: KlaroTheme.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    
                    // Action buttons
                    if (_passed) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            // Get the user to pass to StudentHomeScreen
                            final user = await _localStorage.getUser();
                            if (user != null && mounted) {
                              // Navigate to home screen with My Progress tab selected
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => StudentHomeScreen(
                                    user: user,
                                    initialTab: 1, // My Progress tab
                                  ),
                                ),
                                (route) => false,
                              );
                            }
                          },
                          icon: Icon(Icons.assessment_outlined),
                          label: Text('View My Results'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KlaroTheme.primaryBlue,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            Navigator.of(context).pop(); // Go back to lesson
                          },
                          icon: Icon(Icons.arrow_back),
                          label: Text('Back to Lessons'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Go back to lesson reading screen
                            Navigator.of(context).pop(); // Close dialog
                            Navigator.of(context).pop(); // Close assessment
                            Navigator.of(context).pop(); // Close quiz
                            Navigator.of(context).pop(); // Close recap
                            // This will take them back to the lesson reading screen
                          },
                          icon: Icon(Icons.menu_book),
                          label: Text('Review Lesson'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KlaroTheme.primaryBlue,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            _retakeAssessment();
                          },
                          icon: Icon(Icons.refresh),
                          label: Text('Retake Assessment'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _retakeAssessment() {
    setState(() {
      _messages.clear();
      _conversationHistory.clear();
      _correctAnswers = 0;
      _incorrectAnswers = 0;
      _totalAttempts = 0;
      _isAssessmentComplete = false;
      _passed = false;
      _summary = '';
    });
    _startAssessment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KlaroTheme.surfaceLight,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: KlaroTheme.primaryBlue,
                borderRadius: BorderRadius.circular(8),
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
            SizedBox(width: 10),
            Text('Klaro AI Assessment'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Score tracker
          if (!_isAssessmentComplete)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildScoreBadge('Correct', _correctAnswers, KlaroTheme.success),
                  SizedBox(width: 16),
                  _buildScoreBadge('Incorrect', _incorrectAnswers, KlaroTheme.error),
                ],
              ),
            ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length + (_isAITyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isAITyping) {
                  return MessageBubble(
                    message: '',
                    isStudent: false,
                    isLoading: true,
                  );
                }
                final msg = _messages[index];
                return MessageBubble(
                  message: msg.message,
                  isStudent: msg.role == 'student',
                );
              },
            ),
          ),

          // Input bar
          if (!_isAssessmentComplete)
            Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Quick help buttons
                  if (_messages.length > 2) // Show after initial exchange
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          _buildQuickActionButton(
                            'Give me a hint 💡',
                            'Can you give me a hint about this?',
                          ),
                          SizedBox(width: 8),
                          _buildQuickActionButton(
                            'Explain more 📖',
                            'Can you explain this concept in simpler terms?',
                          ),
                          SizedBox(width: 8),
                          _buildQuickActionButton(
                            'Example please 🌟',
                            'Can you give me an example?',
                          ),
                        ],
                      ),
                    ),
                  // Helpful hints
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    margin: EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: KlaroTheme.lightBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline, 
                          size: 16, 
                          color: KlaroTheme.primaryBlue,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Need help? Just ask! Try: "Can you give me a hint?" or "I don\'t understand"',
                            style: TextStyle(
                              fontSize: 11,
                              color: KlaroTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 3,
                          minLines: 1,
                          decoration: InputDecoration(
                            hintText: 'Type your answer or ask for help...',
                            hintStyle: TextStyle(fontSize: 14),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: KlaroTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: IconButton(
                          onPressed: _isAITyping ? null : _sendMessage,
                          icon: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreBadge(String label, int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String label, String message) {
    return InkWell(
      onTap: () {
        if (!_isAITyping && !_isAssessmentComplete) {
          _messageController.text = message;
          _sendMessage();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: KlaroTheme.primaryBlue.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: KlaroTheme.primaryBlue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

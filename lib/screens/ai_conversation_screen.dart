import 'package:flutter/material.dart';
import 'package:klaro/models/lesson.dart';
import 'package:klaro/models/ai_conversation.dart';
import 'package:klaro/services/gemini_service.dart';
import 'package:klaro/services/local_storage_service.dart';
import 'package:klaro/screens/performance_summary_screen.dart';
import 'package:klaro/widgets/message_bubble.dart';
import 'package:klaro/utils/theme.dart';

/// ============================================================
/// AI Conversation Screen
/// ============================================================
/// Interactive chat with Klaro AI to confirm student understanding.
/// The AI asks follow-up questions and provides a final score.

class AIConversationScreen extends StatefulWidget {
  final Lesson lesson;
  final int quizScore;
  final int quizTotal;

  const AIConversationScreen({
    super.key,
    required this.lesson,
    required this.quizScore,
    required this.quizTotal,
  });

  @override
  State<AIConversationScreen> createState() => _AIConversationScreenState();
}

class _AIConversationScreenState extends State<AIConversationScreen> {
  final GeminiService _geminiService = GeminiService();
  final LocalStorageService _localStorage = LocalStorageService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  final List<Map<String, String>> _conversationHistory = [];
  bool _isAITyping = false;
  bool _isConversationComplete = false;
  double _aiScore = 0;
  String _aiSummary = '';

  @override
  void initState() {
    super.initState();
    _startConversation();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startConversation() {
    final greeting = _geminiService.getInitialGreeting(widget.lesson.title);
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
    if (text.isEmpty || _isAITyping || _isConversationComplete) return;

    _messageController.clear();

    // Add student message
    _addMessage('student', text);
    _conversationHistory.add({'role': 'student', 'message': text});

    // Show typing indicator
    setState(() => _isAITyping = true);

    try {
      final response = await _geminiService.conductConversation(
        widget.lesson.content,
        _conversationHistory,
      );

      final aiMessage = response['message'] as String;
      final isComplete = response['isComplete'] as bool? ?? false;

      _addMessage('ai', aiMessage);
      _conversationHistory.add({'role': 'ai', 'message': aiMessage});

      if (isComplete) {
        _aiScore = (response['score'] as num?)?.toDouble() ?? 3.0;
        _aiSummary = response['summary'] as String? ?? 'Conversation completed.';

        // Save conversation
        final conversation = AIConversation(
          lessonId: widget.lesson.id,
          lessonTitle: widget.lesson.title,
          score: _aiScore,
          summary: _aiSummary,
          date: DateTime.now(),
          messages: _messages,
        );
        await _localStorage.saveAIConversation(conversation);

        setState(() => _isConversationComplete = true);
      }
    } catch (e) {
      _addMessage('ai', 'Sorry, I had trouble understanding. Can you try again?');
    } finally {
      setState(() => _isAITyping = false);
    }
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
            Text('Klaro AI Tutor'),
          ],
        ),
      ),
      body: Column(
        children: [
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

          // Conversation complete banner
          if (_isConversationComplete)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              color: KlaroTheme.success.withOpacity(0.1),
              child: Column(
                children: [
                  Icon(Icons.check_circle, color: KlaroTheme.success, size: 32),
                  SizedBox(height: 8),
                  Text(
                    'Conversation Complete!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: KlaroTheme.success,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'AI Score: ${_aiScore.toStringAsFixed(1)} / 5.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: KlaroTheme.textMuted,
                    ),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PerformanceSummaryScreen(
                            lesson: widget.lesson,
                            quizScore: widget.quizScore,
                            quizTotal: widget.quizTotal,
                            aiScore: _aiScore,
                            aiSummary: _aiSummary,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.bar_chart_rounded),
                    label: Text('View Performance Summary'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KlaroTheme.primaryBlue,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Input bar
          if (!_isConversationComplete)
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
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Type your answer...',
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
            ),
        ],
      ),
    );
  }
}

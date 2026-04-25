/// ============================================================
/// AI Conversation Model
/// ============================================================

class ChatMessage {
  final String role;    // 'student' or 'ai'
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      role: map['role'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class AIConversation {
  final String lessonId;
  final String lessonTitle;
  final double score;          // 1-5 scale
  final String summary;
  final DateTime date;
  final List<ChatMessage> messages;

  AIConversation({
    required this.lessonId,
    required this.lessonTitle,
    required this.score,
    required this.summary,
    required this.date,
    this.messages = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'lessonTitle': lessonTitle,
      'score': score,
      'summary': summary,
      'date': date.toIso8601String(),
      'messages': messages.map((m) => m.toMap()).toList(),
    };
  }

  factory AIConversation.fromMap(Map<dynamic, dynamic> map) {
    return AIConversation(
      lessonId: map['lessonId'] ?? '',
      lessonTitle: map['lessonTitle'] ?? '',
      score: (map['score'] ?? 0).toDouble(),
      summary: map['summary'] ?? '',
      date: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : DateTime.now(),
      messages: map['messages'] != null
          ? (map['messages'] as List)
              .map((m) => ChatMessage.fromMap(Map<String, dynamic>.from(m)))
              .toList()
          : [],
    );
  }
}

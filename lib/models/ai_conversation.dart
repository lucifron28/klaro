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
  final String subject;
  final int correctAnswers;
  final int totalAttempts;
  final double score;          // Calculated score
  final String summary;
  final DateTime date;
  final List<ChatMessage> messages;
  final int attemptCount;
  final DateTime? firstAttemptDate;

  AIConversation({
    required this.lessonId,
    required this.lessonTitle,
    required this.subject,
    this.correctAnswers = 0,
    this.totalAttempts = 0,
    required this.score,
    required this.summary,
    required this.date,
    this.messages = const [],
    this.attemptCount = 1,
    this.firstAttemptDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'lessonTitle': lessonTitle,
      'subject': subject,
      'correctAnswers': correctAnswers,
      'totalAttempts': totalAttempts,
      'score': score,
      'summary': summary,
      'date': date.toIso8601String(),
      'timestamp': date.toIso8601String(),
      'messages': messages.map((m) => m.toMap()).toList(),
      'attemptCount': attemptCount,
      'firstAttemptDate': firstAttemptDate?.toIso8601String(),
    };
  }

  factory AIConversation.fromMap(Map<dynamic, dynamic> map) {
    // Handle backward compatibility: try 'subject' first, then 'schoolSubject'
    final subject = map['subject'] ?? map['schoolSubject'] ?? 'Unknown';
    return AIConversation(
      lessonId: map['lessonId'] ?? '',
      lessonTitle: map['lessonTitle'] ?? '',
      subject: subject,
      correctAnswers: map['correctAnswers'] ?? 0,
      totalAttempts: map['totalAttempts'] ?? 0,
      score: (map['score'] ?? 0).toDouble(),
      summary: map['summary'] ?? '',
      date: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : (map['timestamp'] != null
              ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
              : DateTime.now()),
      messages: map['messages'] != null
          ? (map['messages'] as List)
              .map((m) => ChatMessage.fromMap(Map<String, dynamic>.from(m)))
              .toList()
          : [],
      attemptCount: map['attemptCount'] ?? 1,
      firstAttemptDate: map['firstAttemptDate'] != null
          ? DateTime.tryParse(map['firstAttemptDate'])
          : null,
    );
  }
}

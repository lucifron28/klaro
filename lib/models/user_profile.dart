/// ============================================================
/// User Profile Model (Firestore)
/// ============================================================
/// Represents user profile data stored in Cloud Firestore.
/// Collection: users/{uid}

class UserProfile {
  final String uid;
  final String email;
  final String role; // "teacher" or "student"
  final bool isFirstLogin;
  final String preferredLanguage;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.role,
    required this.isFirstLogin,
    required this.preferredLanguage,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'isFirstLogin': isFirstLogin,
      'preferredLanguage': preferredLanguage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
      isFirstLogin: map['isFirstLogin'] ?? true,
      preferredLanguage: map['preferredLanguage'] ?? 'en',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }

  UserProfile copyWith({
    bool? isFirstLogin,
    String? preferredLanguage,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      role: role,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

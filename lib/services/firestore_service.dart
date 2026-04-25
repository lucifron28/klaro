import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:klaro/models/app_user.dart';
import 'package:klaro/models/user_profile.dart';
import 'package:klaro/models/quiz_response.dart';
import 'package:klaro/models/ai_conversation.dart';
import 'package:klaro/models/learned_concept.dart';
import 'package:klaro/models/teacher_student.dart';
import 'package:klaro/models/module_upload.dart';

/// ============================================================
/// Firestore Service
/// ============================================================
/// Manages user data in Cloud Firestore including profiles,
/// quiz results, AI assessment results, and learned concepts.
/// Collections:
/// - users/{uid}
/// - users/{uid}/quizResults/{resultId}
/// - users/{uid}/assessmentResults/{resultId}
/// - users/{uid}/learnedConcepts/{conceptId}

class FirestoreService {
  FirebaseFirestore? get _firestore {
    try {
      if (Firebase.apps.isEmpty) return null;
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Create user profile after registration
  Future<void> createUserProfile(AppUser user) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore not available, skipping profile creation');
      return;
    }

    try {
      final profile = UserProfile(
        uid: user.uid,
        email: user.email,
        role: user.role == UserRole.teacher ? 'teacher' : 'student',
        isFirstLogin: true,
        preferredLanguage: 'en',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await firestore.collection('users').doc(user.uid).set(profile.toMap());
      debugPrint('Created Firestore profile for ${user.email}');
    } on FirebaseException catch (e) {
      debugPrint('Firestore error creating profile: ${e.code} - ${e.message}');
      throw FirestoreErrorHandler.getErrorMessage(e);
    } catch (e) {
      debugPrint('Error creating profile: $e');
      throw 'Failed to create user profile. Please try again.';
    }
  }

  /// Get user profile by UID
  Future<UserProfile?> getUserProfile(String uid) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore not available');
      return null;
    }

    try {
      final doc = await firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        debugPrint('User profile not found for uid: $uid');
        return null;
      }

      return UserProfile.fromMap(doc.data()!);
    } on FirebaseException catch (e) {
      debugPrint('Firestore error getting profile: ${e.code} - ${e.message}');
      throw FirestoreErrorHandler.getErrorMessage(e);
    } catch (e) {
      debugPrint('Error getting profile: $e');
      throw 'Failed to load user profile. Please try again.';
    }
  }

  /// Update user profile fields
  Future<void> updateUserProfile(
      String uid, Map<String, dynamic> updates) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore not available, skipping profile update');
      return;
    }

    // Skip for demo users
    if (uid == 'demo-student' || uid == 'demo-teacher') {
      debugPrint('Skipping Firestore update for demo user: $uid');
      return;
    }

    try {
      updates['updatedAt'] = DateTime.now().toIso8601String();
      await firestore.collection('users').doc(uid).update(updates);
      debugPrint('Updated Firestore profile for uid: $uid');
    } on FirebaseException catch (e) {
      debugPrint('Firestore error updating profile: ${e.code} - ${e.message}');
      throw FirestoreErrorHandler.getErrorMessage(e);
    } catch (e) {
      debugPrint('Error updating profile: $e');
      throw 'Failed to update user profile. Please try again.';
    }
  }

  /// Update language preference
  Future<void> updateLanguagePreference(
      String uid, String languageCode) async {
    await updateUserProfile(uid, {'preferredLanguage': languageCode});
  }

  /// Mark first login as complete
  Future<void> completeFirstLogin(String uid) async {
    await updateUserProfile(uid, {'isFirstLogin': false});
  }

  // ══════════════════════════════════════════════════════════
  // Quiz Results
  // ══════════════════════════════════════════════════════════

  /// Save or update quiz result
  Future<void> saveQuizResult(String uid, QuizResponse quiz) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore not available, skipping quiz save');
      return;
    }

    try {
      // Check for existing result with same lessonId
      final existing = await firestore
          .collection('users')
          .doc(uid)
          .collection('quizResults')
          .where('lessonId', isEqualTo: quiz.lessonId)
          .limit(1)
          .get();

      final data = quiz.toMap();
      
      if (existing.docs.isNotEmpty) {
        // Update existing result
        final docId = existing.docs.first.id;
        final existingData = existing.docs.first.data();
        
        data['firstAttemptDate'] = existingData['firstAttemptDate'] ?? 
            existingData['timestamp'] ?? 
            DateTime.now().toIso8601String();
        data['attemptCount'] = (existingData['attemptCount'] ?? 1) + 1;
        data['timestamp'] = DateTime.now().toIso8601String();
        
        await firestore
            .collection('users')
            .doc(uid)
            .collection('quizResults')
            .doc(docId)
            .update(data);
        
        debugPrint('Updated quiz result for lesson: ${quiz.lessonId}');
      } else {
        // Create new result
        data['firstAttemptDate'] = DateTime.now().toIso8601String();
        data['attemptCount'] = 1;
        data['timestamp'] = DateTime.now().toIso8601String();
        
        await firestore
            .collection('users')
            .doc(uid)
            .collection('quizResults')
            .add(data);
        
        debugPrint('Created quiz result for lesson: ${quiz.lessonId}');
      }
    } on FirebaseException catch (e) {
      debugPrint('Firestore error saving quiz: ${e.code} - ${e.message}');
      throw FirestoreErrorHandler.getErrorMessage(e);
    } catch (e) {
      debugPrint('Error saving quiz result: $e');
      throw 'Failed to save quiz result. Please try again.';
    }
  }

  /// Get all quiz results for a user, ordered by timestamp descending
  Future<List<QuizResponse>> getQuizResults(String uid) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore not available');
      return [];
    }

    try {
      final snapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('quizResults')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => QuizResponse.fromMap(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      debugPrint('Firestore error getting quizzes: ${e.code} - ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Error getting quiz results: $e');
      return [];
    }
  }

  /// Delete a quiz result
  Future<void> deleteQuizResult(String uid, String lessonId) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore not available');
      return;
    }

    try {
      final docs = await firestore
          .collection('users')
          .doc(uid)
          .collection('quizResults')
          .where('lessonId', isEqualTo: lessonId)
          .get();

      for (var doc in docs.docs) {
        await doc.reference.delete();
      }
      
      debugPrint('Deleted quiz result for lesson: $lessonId');
    } on FirebaseException catch (e) {
      debugPrint('Firestore error deleting quiz: ${e.code} - ${e.message}');
      throw FirestoreErrorHandler.getErrorMessage(e);
    }
  }

  // ══════════════════════════════════════════════════════════
  // AI Assessment Results
  // ══════════════════════════════════════════════════════════

  /// Save or update AI assessment result
  Future<void> saveAssessmentResult(String uid, AIConversation assessment) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore not available, skipping assessment save');
      return;
    }

    try {
      // Check for existing result with same lessonId
      final existing = await firestore
          .collection('users')
          .doc(uid)
          .collection('assessmentResults')
          .where('lessonId', isEqualTo: assessment.lessonId)
          .limit(1)
          .get();

      final data = assessment.toMap();
      
      if (existing.docs.isNotEmpty) {
        // Update existing result
        final docId = existing.docs.first.id;
        final existingData = existing.docs.first.data();
        
        data['firstAttemptDate'] = existingData['firstAttemptDate'] ?? 
            existingData['timestamp'] ?? 
            DateTime.now().toIso8601String();
        data['attemptCount'] = (existingData['attemptCount'] ?? 1) + 1;
        data['timestamp'] = DateTime.now().toIso8601String();
        
        await firestore
            .collection('users')
            .doc(uid)
            .collection('assessmentResults')
            .doc(docId)
            .update(data);
        
        debugPrint('Updated assessment result for lesson: ${assessment.lessonId}');
      } else {
        // Create new result
        data['firstAttemptDate'] = DateTime.now().toIso8601String();
        data['attemptCount'] = 1;
        data['timestamp'] = DateTime.now().toIso8601String();
        
        await firestore
            .collection('users')
            .doc(uid)
            .collection('assessmentResults')
            .add(data);
        
        debugPrint('Created assessment result for lesson: ${assessment.lessonId}');
      }
    } on FirebaseException catch (e) {
      debugPrint('Firestore error saving assessment: ${e.code} - ${e.message}');
      throw FirestoreErrorHandler.getErrorMessage(e);
    } catch (e) {
      debugPrint('Error saving assessment result: $e');
      throw 'Failed to save assessment result. Please try again.';
    }
  }

  /// Get all assessment results for a user, ordered by timestamp descending
  Future<List<AIConversation>> getAssessmentResults(String uid) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore not available');
      return [];
    }

    try {
      final snapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('assessmentResults')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AIConversation.fromMap(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      debugPrint('Firestore error getting assessments: ${e.code} - ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Error getting assessment results: $e');
      return [];
    }
  }

  /// Delete an assessment result
  Future<void> deleteAssessmentResult(String uid, String lessonId) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore not available');
      return;
    }

    try {
      final docs = await firestore
          .collection('users')
          .doc(uid)
          .collection('assessmentResults')
          .where('lessonId', isEqualTo: lessonId)
          .get();

      for (var doc in docs.docs) {
        await doc.reference.delete();
      }
      
      debugPrint('Deleted assessment result for lesson: $lessonId');
    } on FirebaseException catch (e) {
      debugPrint('Firestore error deleting assessment: ${e.code} - ${e.message}');
      throw FirestoreErrorHandler.getErrorMessage(e);
    }
  }

  // ══════════════════════════════════════════════════════════
  // Learned Concepts
  // ══════════════════════════════════════════════════════════

  /// Save a learned concept
  Future<void> saveLearnedConcept(
    String uid,
    String lessonId,
    String lessonTitle,
    LearnedConcept concept,
  ) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore not available, skipping concept save');
      return;
    }

    try {
      final data = concept.toMap();
      data['lessonId'] = lessonId;
      data['lessonTitle'] = lessonTitle;
      data['timestamp'] = DateTime.now().toIso8601String();

      await firestore
          .collection('users')
          .doc(uid)
          .collection('learnedConcepts')
          .add(data);
      
      debugPrint('Saved learned concept: ${concept.word}');
    } on FirebaseException catch (e) {
      debugPrint('Firestore error saving concept: ${e.code} - ${e.message}');
    } catch (e) {
      debugPrint('Error saving learned concept: $e');
    }
  }

  /// Get all learned concepts, ordered by timestamp descending
  Future<List<Map<String, dynamic>>> getLearnedConcepts(String uid) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore not available');
      return [];
    }

    try {
      final snapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('learnedConcepts')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } on FirebaseException catch (e) {
      debugPrint('Firestore error getting concepts: ${e.code} - ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Error getting learned concepts: $e');
      return [];
    }
  }

  // ══════════════════════════════════════════════════════════
  // Teacher-Student Management
  // ══════════════════════════════════════════════════════════

  /// Add a student to a teacher's class
  Future<void> addStudentToTeacher(String teacherId, TeacherStudent student) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore not available, skipping student addition');
      return;
    }

    try {
      await firestore
          .collection('teachers')
          .doc(teacherId)
          .collection('students')
          .doc(student.studentId)
          .set(student.toMap());
      
      debugPrint('Added student ${student.studentName} to teacher $teacherId');
    } on FirebaseException catch (e) {
      debugPrint('Firestore error adding student: ${e.code} - ${e.message}');
      throw FirestoreErrorHandler.getErrorMessage(e);
    } catch (e) {
      debugPrint('Error adding student: $e');
      throw 'Failed to add student. Please try again.';
    }
  }

  /// Get all students for a teacher
  Future<List<TeacherStudent>> getTeacherStudents(String teacherId) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore not available');
      return [];
    }

    try {
      final snapshot = await firestore
          .collection('teachers')
          .doc(teacherId)
          .collection('students')
          .orderBy('studentName')
          .get();

      return snapshot.docs
          .map((doc) => TeacherStudent.fromMap(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      debugPrint('Firestore error getting students: ${e.code} - ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Error getting students: $e');
      return [];
    }
  }

  /// Remove a student from a teacher's class
  Future<void> removeStudentFromTeacher(String teacherId, String studentId) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore not available');
      return;
    }

    try {
      await firestore
          .collection('teachers')
          .doc(teacherId)
          .collection('students')
          .doc(studentId)
          .delete();
      
      debugPrint('Removed student $studentId from teacher $teacherId');
    } on FirebaseException catch (e) {
      debugPrint('Firestore error removing student: ${e.code} - ${e.message}');
      throw FirestoreErrorHandler.getErrorMessage(e);
    }
  }

  /// Get student progress summary
  Future<StudentProgressSummary?> getStudentProgressSummary(String studentId) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore not available');
      return null;
    }

    try {
      // Get quiz results
      final quizResults = await getQuizResults(studentId);
      
      // Get AI assessment results
      final assessmentResults = await getAssessmentResults(studentId);

      // If no data at all, return null
      if (quizResults.isEmpty && assessmentResults.isEmpty) {
        debugPrint('No progress data found for student: $studentId');
        return null;
      }

      // Calculate averages
      final avgQuizScore = quizResults.isEmpty
          ? 0.0
          : quizResults.map((q) => q.percentage).reduce((a, b) => a + b) / quizResults.length;

      final avgAIScore = assessmentResults.isEmpty
          ? 0.0
          : assessmentResults.map((a) => a.score).reduce((a, b) => a + b) / assessmentResults.length;

      // Debug logging
      debugPrint('📊 Progress Calculation for $studentId:');
      debugPrint('   Quiz Results: ${quizResults.length} quizzes');
      debugPrint('   Quiz Scores: ${quizResults.map((q) => '${q.percentage}%').join(', ')}');
      debugPrint('   Average Quiz Score: ${avgQuizScore.toStringAsFixed(1)}%');
      debugPrint('   AI Results: ${assessmentResults.length} assessments');
      debugPrint('   AI Scores: ${assessmentResults.map((a) => '${a.score}').join(', ')}');
      debugPrint('   Average AI Score: ${avgAIScore.toStringAsFixed(2)}');

      // Calculate overall progress (weighted average: 60% quiz, 40% AI)
      // IMPORTANT: Both quiz and AI scores are stored as percentages (0-100)
      // Quiz: percentage field is already 0-100
      // AI: score field is stored as percentage (0-100), not out of 5
      final overallProgress = (avgQuizScore * 0.6) + (avgAIScore * 0.4);
      
      debugPrint('   Overall Progress: ${overallProgress.toStringAsFixed(1)}%');
      
      // Ensure progress doesn't exceed 100%
      final cappedProgress = overallProgress > 100.0 ? 100.0 : overallProgress;
      
      if (overallProgress > 100.0) {
        debugPrint('   ⚠️ Progress capped from ${overallProgress.toStringAsFixed(1)}% to 100%');
      }

      // Identify struggling topics (quiz score < 60%)
      final strugglingTopics = quizResults
          .where((q) => q.percentage < 60)
          .map((q) => q.lessonTitle)
          .toSet()
          .toList();

      // Get last activity date
      final lastActivity = [
        ...quizResults.map((q) => q.date),
        ...assessmentResults.map((a) => a.date),
      ].fold<DateTime>(
        DateTime.now().subtract(Duration(days: 365)),
        (latest, date) => date.isAfter(latest) ? date : latest,
      );

      // Get student name and email from the teacher's student record
      // For demo users, use default values
      String studentName = 'Student';
      String studentEmail = 'student@test.com';
      
      if (studentId == 'demo-student') {
        studentName = 'Demo Student';
        studentEmail = 'student@test.com';
      } else {
        // Try to get from user profile
        final profile = await getUserProfile(studentId);
        if (profile != null) {
          studentName = profile.email.split('@').first;
          studentEmail = profile.email;
        }
      }

      return StudentProgressSummary(
        studentId: studentId,
        studentName: studentName,
        studentEmail: studentEmail,
        totalLessonsCompleted: {...quizResults.map((q) => q.lessonId), ...assessmentResults.map((a) => a.lessonId)}.length,
        totalQuizzesTaken: quizResults.length,
        averageQuizScore: avgQuizScore,
        totalAIAssessments: assessmentResults.length,
        averageAIScore: avgAIScore,
        overallProgress: cappedProgress,
        strugglingTopics: strugglingTopics,
        lastActivity: lastActivity,
      );
    } catch (e) {
      debugPrint('Error getting student progress: $e');
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════
  // Module Upload Management
  // ══════════════════════════════════════════════════════════

  /// Create a new module
  Future<void> createModule(ModuleUpload module) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore not available, skipping module creation');
      return;
    }

    try {
      await firestore
          .collection('teachers')
          .doc(module.teacherId)
          .collection('modules')
          .doc(module.id)
          .set(module.toMap());
      
      debugPrint('Created module: ${module.title}');
    } on FirebaseException catch (e) {
      debugPrint('Firestore error creating module: ${e.code} - ${e.message}');
      throw FirestoreErrorHandler.getErrorMessage(e);
    } catch (e) {
      debugPrint('Error creating module: $e');
      throw 'Failed to create module. Please try again.';
    }
  }

  /// Get all modules for a teacher
  Future<List<ModuleUpload>> getTeacherModules(String teacherId) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore not available');
      return [];
    }

    try {
      final snapshot = await firestore
          .collection('teachers')
          .doc(teacherId)
          .collection('modules')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ModuleUpload.fromMap(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      debugPrint('Firestore error getting modules: ${e.code} - ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Error getting modules: $e');
      return [];
    }
  }

  /// Update a module
  Future<void> updateModule(ModuleUpload module) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore not available, skipping module update');
      return;
    }

    try {
      await firestore
          .collection('teachers')
          .doc(module.teacherId)
          .collection('modules')
          .doc(module.id)
          .update(module.toMap());
      
      debugPrint('Updated module: ${module.title}');
    } on FirebaseException catch (e) {
      debugPrint('Firestore error updating module: ${e.code} - ${e.message}');
      throw FirestoreErrorHandler.getErrorMessage(e);
    } catch (e) {
      debugPrint('Error updating module: $e');
      throw 'Failed to update module. Please try again.';
    }
  }

  /// Delete a module
  Future<void> deleteModule(String teacherId, String moduleId) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore not available');
      return;
    }

    try {
      await firestore
          .collection('teachers')
          .doc(teacherId)
          .collection('modules')
          .doc(moduleId)
          .delete();
      
      debugPrint('Deleted module: $moduleId');
    } on FirebaseException catch (e) {
      debugPrint('Firestore error deleting module: ${e.code} - ${e.message}');
      throw FirestoreErrorHandler.getErrorMessage(e);
    }
  }

  // ══════════════════════════════════════════════════════════
  // Offline Sync Support
  // ══════════════════════════════════════════════════════════

  /// Check if Firestore is available
  bool get isAvailable => _firestore != null;

  /// Enable offline persistence
  Future<void> enableOfflinePersistence() async {
    final firestore = _firestore;
    if (firestore == null) return;

    try {
      await firestore.enablePersistence();
      debugPrint('Firestore offline persistence enabled');
    } catch (e) {
      debugPrint('Could not enable offline persistence: $e');
    }
  }
}

/// Firestore Error Handler
class FirestoreErrorHandler {
  static String getErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Access denied. Please sign in again.';
      case 'not-found':
        return 'User profile not found. Please contact support.';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again.';
      case 'deadline-exceeded':
        return 'Request timed out. Please check your connection.';
      case 'already-exists':
        return 'User profile already exists.';
      default:
        return 'An error occurred: ${e.message ?? "Unknown error"}';
    }
  }
}

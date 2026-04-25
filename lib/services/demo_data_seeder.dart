import 'package:flutter/foundation.dart';
import 'package:klaro/models/teacher_student.dart';
import 'package:klaro/services/firestore_service.dart';

/// Service to seed demo data for testing
class DemoDataSeeder {
  final FirestoreService _firestoreService = FirestoreService();

  /// Add the demo student to the demo teacher
  Future<void> addDemoStudentToTeacher() async {
    try {
      debugPrint('🚀 Adding demo student to demo teacher...');

      const teacherId = 'demo-teacher';
      const studentId = 'demo-student';

      final teacherStudent = TeacherStudent(
        studentId: studentId,
        studentName: 'Demo Student',
        studentEmail: 'student@test.com',
        gradeLevel: 'Grade 7',
        enrolledAt: DateTime.now(),
        section: 'Demo Section',
      );

      await _firestoreService.addStudentToTeacher(teacherId, teacherStudent);

      debugPrint('✅ Demo student added successfully!');
      debugPrint('   - Student: ${teacherStudent.studentName}');
      debugPrint('   - Email: ${teacherStudent.studentEmail}');
      debugPrint('   - Grade: ${teacherStudent.gradeLevel}');
    } catch (e) {
      debugPrint('❌ Error adding demo student: $e');
      rethrow;
    }
  }

  /// Check if demo student is already added to demo teacher
  Future<bool> isDemoStudentAdded() async {
    try {
      const teacherId = 'demo-teacher';
      final students = await _firestoreService.getTeacherStudents(teacherId);
      return students.any((s) => s.studentId == 'demo-student');
    } catch (e) {
      debugPrint('Error checking demo student: $e');
      return false;
    }
  }

  /// Setup all demo data (can be expanded in the future)
  Future<void> setupDemoData() async {
    try {
      debugPrint('🎯 Setting up demo data...');

      // Check if already set up
      final isAdded = await isDemoStudentAdded();
      if (isAdded) {
        debugPrint('ℹ️ Demo student already added, skipping...');
        return;
      }

      // Add demo student to demo teacher
      await addDemoStudentToTeacher();

      debugPrint('🎉 Demo data setup complete!');
    } catch (e) {
      debugPrint('❌ Error setting up demo data: $e');
      rethrow;
    }
  }
}

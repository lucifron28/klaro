import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:klaro/firebase_options.dart';
import 'package:klaro/models/teacher_student.dart';

/// Script to add the demo-student to the demo-teacher's student list
/// Run this once to set up the demo data

Future<void> main() async {
  print('🚀 Starting demo student setup...');
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized');

    final firestore = FirebaseFirestore.instance;

    // Demo teacher ID (from demo login)
    const teacherId = 'demo-teacher';
    
    // Demo student ID (from demo login)
    const studentId = 'demo-student';

    // Create the teacher-student relationship
    final teacherStudent = TeacherStudent(
      studentId: studentId,
      studentName: 'Demo Student',
      studentEmail: 'student@test.com',
      gradeLevel: 'Grade 7',
      enrolledAt: DateTime.now(),
      section: 'Demo Section',
    );

    // Add to Firestore
    await firestore
        .collection('teachers')
        .doc(teacherId)
        .collection('students')
        .doc(studentId)
        .set(teacherStudent.toMap());

    print('✅ Demo student added to demo teacher successfully!');
    print('');
    print('📊 Student Details:');
    print('   - Student ID: $studentId');
    print('   - Student Name: ${teacherStudent.studentName}');
    print('   - Student Email: ${teacherStudent.studentEmail}');
    print('   - Grade Level: ${teacherStudent.gradeLevel}');
    print('   - Section: ${teacherStudent.section}');
    print('');
    print('🎉 Setup complete! You can now:');
    print('   1. Login as teacher (teacher@test.com / test123)');
    print('   2. Go to "My Students"');
    print('   3. See the demo student in the list');
    print('   4. Click on the student to view their progress');
    
  } catch (e) {
    print('❌ Error: $e');
    print('');
    print('Make sure:');
    print('   1. Firebase is properly configured');
    print('   2. You have internet connection');
    print('   3. Firestore is enabled in your Firebase project');
  }
}

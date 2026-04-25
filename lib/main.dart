import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:klaro/services/env_service.dart';
import 'package:klaro/services/local_storage_service.dart';
import 'package:klaro/screens/login_screen.dart';
import 'package:klaro/utils/theme.dart';
import 'package:klaro/utils/constants.dart';

/// ============================================================
/// Klaro - Main Entry Point
/// ============================================================
/// A Filipino educational app that helps students understand
/// lessons through word simplification, translation, quizzes,
/// and AI-powered conversational assessment.
///
/// Built for InnOlympics 2026 Hackathon
/// Track A: Pangarap sa Pagkatuto (Education & Opportunity Access)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvService.load();

  // Firebase is optional for the local hackathon demo. Without
  // google-services.json, initialization fails before the first frame.
  try {
    await Firebase.initializeApp();
  } catch (error) {
    debugPrint('Firebase initialization skipped: $error');
  }

  // Initialize local storage (Hive)
  final localStorage = LocalStorageService();
  await localStorage.init();

  runApp(const KlaroApp());
}

class KlaroApp extends StatelessWidget {
  const KlaroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: KlaroTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}

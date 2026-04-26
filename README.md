# Klaro

Klaro is a Flutter learning app for Filipino Grade 7 students. It organizes the curriculum as `Subject -> Module -> Lesson`, lets students read lessons, tap unfamiliar words for simple AI explanations, review learned words in a recap, take a quiz, and complete an AI assessment conversation.

Built for InnOlympics 2026, Track A: Pangarap sa Pagkatuto.

## Submission

| Item | Link / Details |
| --- | --- |
| GitHub repository | [https://github.com/lucifron28/klaro](https://github.com/lucifron28/klaro) |
| Release APK | [`release/klaro-v1.0.0-release.apk`](release/klaro-v1.0.0-release.apk) |
| Release APK SHA-256 | `7DCC1D0ED046A461E79C4D4F6643D2DF89710E2B418EDD5E37AB1E2EA8B58766` |
| Built APK output | `build/app/outputs/flutter-apk/app-release.apk` |
| Android package id | `com.example.klaro` |

The submitted APK is a release-mode Android build generated with:

```powershell
C:\Users\Ron\develop\flutter\bin\flutter.bat build apk --release
```

Note: the current Android release build is signed with the debug signing config for hackathon distribution. It is installable on Android devices, but it is not Play Store production-signed.

## How To Download And Run

### Run The APK On Android

1. Download [`release/klaro-v1.0.0-release.apk`](release/klaro-v1.0.0-release.apk) from the repository.
2. Transfer it to an Android phone, or download it directly on the phone.
3. If Android blocks installation, enable installation from unknown apps for the browser/file manager you are using.
4. Open the APK and install Klaro.
5. Launch the app and use the demo accounts below.

### Run Locally For Development

```powershell
cd C:\Users\Ron\InnOlympics\klaro
C:\Users\Ron\develop\flutter\bin\flutter.bat pub get
C:\Users\Ron\develop\flutter\bin\flutter.bat run
```

Optional web/localhost run for development:

```powershell
C:\Users\Ron\develop\flutter\bin\flutter.bat run -d chrome --web-port 8080
```

Android is the primary tested target for the submitted build.

## Project Overview

### Specific Problem

Many Grade 7 learners struggle to understand lesson materials when vocabulary, academic English, or unfamiliar concepts get in the way. Teachers also need a fast way to see which students are struggling and what topics need intervention.

### Proposed Solution

Klaro provides an AI-assisted reading and assessment flow for Grade 7 lessons. Students read lessons, tap confusing words for simplified explanations and dialect support, review the words they learned, take a quiz, and complete an AI assessment conversation. Teachers can view student progress, manage students/modules, and generate AI-backed lesson suggestions for topics where learners struggle.

### Features Used To Implement The Solution

- DepEd Grade 7 curriculum structure: `Subject -> Module -> Lesson`.
- Interactive lesson reading with tappable words.
- Google Cloud Translation API for dialect translation through `TranslationService`.
- Firebase AI Logic with Gemini for word simplification, quiz generation, quiz evaluation, AI assessment, and teacher suggestions.
- Firebase Auth for student and teacher accounts.
- Cloud Firestore for user profiles, quiz results, AI assessment results, learned concepts, teacher-student records, and teacher modules.
- Hive local storage for offline-friendly user/session/progress/cache data.
- Dialect selector and settings for English, Tagalog, Cebuano, Ilocano, Hiligaynon, Waray, Kapampangan, Bikol, and Pangasinan.
- Learning recap that logs selected words/concepts before the quiz.
- Student progress screen and teacher dashboard.

### Credits, Tools, Frameworks, And Resources

- Flutter and Dart for the mobile application framework.
- Firebase Core, Firebase Auth, Cloud Firestore, and Firebase AI Logic.
- Gemini through Firebase AI Logic.
- Google Cloud Translation API.
- Google Fonts Flutter package.
- Hive / Hive Flutter for local persistence.
- Material Design / Material 3 Flutter widgets.
- DepEd Grade 7 curriculum outline supplied for the project module list.

## Current Scope

The current app supports:

- Firebase initialization through `lib/firebase_options.dart` and Android `google-services.json`.
- Firebase Auth email/password login, with local demo fallback accounts.
- Student and teacher roles.
- First-login dialect selector and dialect settings.
- Grade 7 Science, English, and Mathematics curriculum seed data.
- Curriculum hierarchy: `Subject -> Module -> Lesson`.
- Realistic seed lesson content generated from the curriculum module and lesson titles.
- Interactive reading with tappable content words.
- Firebase AI Logic word explanations in English plus the selected Filipino dialect.
- Local caching for word explanations and UI translations.
- Learned word/concept logging per lesson.
- Learning recap before quiz.
- AI-generated quiz questions with fallback questions.
- AI quiz evaluation with fallback evaluation.
- AI assessment conversation after the quiz.
- Local progress storage through Hive.
- Firestore-backed quiz results, AI assessment results, learned concepts, teacher-student links, and teacher module uploads.
- Teacher dashboard, student management, module management, and AI lesson suggestions for struggling topics.

The app is Android-first. iOS, web, desktop, and release signing are present in the Flutter project structure but are not the main tested target.

## Quick Start

```powershell
cd C:\Users\Ron\InnOlympics\klaro
flutter pub get
flutter run
```

If `flutter` is not on PATH:

```powershell
C:\Users\Ron\develop\flutter\bin\flutter.bat pub get
C:\Users\Ron\develop\flutter\bin\flutter.bat run
```

Build a debug APK:

```powershell
flutter build apk --debug
```

Debug APK output:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Demo Accounts

These accounts are defined in `lib/utils/constants.dart`.

| Role | Email | Password | Notes |
| --- | --- | --- | --- |
| Student | `student@test.com` | `password123` | Local demo fallback user id is `demo-student`. |
| Teacher | `teacher@test.com` | `password123` | Local demo fallback user id is `demo-teacher`. |

The demo credentials are checked before Firebase Auth. This means the demo login can work even if Firebase Auth is unavailable, but AI and Firestore features still need Firebase configured.

## Firebase Setup

Required generated/config files:

```text
android/app/google-services.json
lib/firebase_options.dart
firebase.json
```

Current Firebase project id:

```text
klaro-851a6
```

Current Android package id:

```text
com.example.klaro
```

Firebase services used by the app:

- Firebase Core
- Firebase Auth
- Cloud Firestore
- Firebase AI Logic

The app initializes Firebase in `lib/main.dart` with:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

Firebase initialization is wrapped in `try/catch` so the local demo can still open when Firebase is missing, but Firebase-dependent features will fail or fall back.

## Environment Files

The current Firebase AI Logic setup does not require a separate Gemini API key in Dart code.

```text
.env
.env.example
```

`.env.example` includes:

```text
GOOGLE_TRANSLATE_API_KEY
```

Use this key name for Google Cloud Translation API work. Do not hardcode translation keys, Gemini keys, or other Google API keys in Dart files. Firebase AI Logic uses the Firebase app configuration.

Implementation note: `.env` is loaded at startup and is listed as a Flutter asset for local development. `TranslationService` uses Google Cloud Translation API first, then falls back to the local static translation map when Cloud Translation is unavailable.

## Tech Stack

| Area | Implementation |
| --- | --- |
| App framework | Flutter / Dart |
| UI | Material 3, Google Fonts, Flutter Animate, Shimmer |
| Auth | Firebase Auth plus local demo fallback |
| Backend data | Cloud Firestore |
| Local storage | Hive / Hive Flutter |
| AI | Firebase AI Logic SDK |
| AI package | `firebase_ai: ^2.3.0` |
| Gemini model | `gemini-3.1-flash-lite-preview` from `AppConstants.geminiModel` |
| State management | Mostly local `StatefulWidget` state and services |
| Curriculum source | Local Dart seed data in `lib/data/sample_lessons.dart` |

## Google Technologies Used

Klaro uses these Google technologies:

| Technology | Where it is used |
| --- | --- |
| Flutter | Main cross-platform app framework for the Android app. |
| Dart | Application programming language. |
| Firebase Core | Initializes the Firebase app through `Firebase.initializeApp`. |
| Firebase Auth | Email/password authentication for student and teacher accounts. |
| Cloud Firestore | Stores user profiles, quiz results, AI assessment results, learned concepts, teacher-student records, and teacher-created modules. |
| Firebase AI Logic | Connects the Flutter app to Gemini models through Firebase. |
| Gemini | Powers word simplification, dialect explanations, quiz generation, quiz evaluation, AI assessment conversations, UI translation, and teacher lesson suggestions. |
| Google Cloud Translation API | Runtime provider for UI and learned-concept dialect translation through `TranslationService`. |
| FlutterFire CLI | Generates Firebase platform configuration such as `lib/firebase_options.dart`. |
| Firebase CLI | Required by FlutterFire configuration workflows. |
| Google Services Gradle Plugin | Reads `android/app/google-services.json` for Android Firebase configuration. |
| Google Fonts | Provides app typography through the `google_fonts` Flutter package. |

## App Architecture

High-level startup:

```text
main.dart
  -> Firebase.initializeApp(DefaultFirebaseOptions.currentPlatform)
  -> LocalStorageService.init()
  -> KlaroApp
  -> LoginScreen
```

Student flow:

```text
LoginScreen
  -> LanguageSelectorScreen on first login
  -> StudentHomeScreen
  -> SubjectModulesScreen
  -> ModuleLessonsScreen
  -> LessonReadingScreen
  -> LearningRecapScreen
  -> QuizScreen
  -> AIAssessmentScreen
```

Teacher flow:

```text
LoginScreen
  -> LanguageSelectorScreen on first login
  -> TeacherDashboardScreen
  -> TeacherStudentsScreen
  -> TeacherStudentDetailScreen
  -> TeacherModulesScreen
  -> TeacherModuleUploadScreen
```

## Curriculum Model

Klaro models curriculum as:

```text
CurriculumSubject
  -> List<CurriculumModule>
    -> List<Lesson>
```

Main model files:

| File | Purpose |
| --- | --- |
| `lib/models/curriculum.dart` | `CurriculumSubject` and `CurriculumModule`. |
| `lib/models/lesson.dart` | Individual lesson records. |
| `lib/data/sample_lessons.dart` | Grade 7 subject/module/lesson seed data. |

Current seeded curriculum:

| Subject | Modules | Lessons |
| --- | ---: | ---: |
| Science 7 | 4 | 31 |
| English 7 | 4 | 32 |
| Mathematics 7 | 4 | 33 |

Module map:

| Subject | Quarter | Module |
| --- | --- | --- |
| Science | Quarter 1 | Matter |
| Science | Quarter 2 | Living Things and Their Environment |
| Science | Quarter 3 | Force, Motion and Energy |
| Science | Quarter 4 | Earth and Space |
| English | Quarter 1 | Reading Comprehension, Vocabulary, Grammar |
| English | Quarter 2 | Listening Comprehension |
| English | Quarter 3 | Oral Language and Fluency |
| English | Quarter 4 | Writing and Composition |
| Mathematics | Quarter 1 | Numbers and Number Sense |
| Mathematics | Quarter 2 | Measurement and Algebra |
| Mathematics | Quarter 3 | Geometry |
| Mathematics | Quarter 4 | Statistics and Probability |

The seed includes the supplied DepEd Grade 7 module/lesson titles. Lesson content is realistic app seed content, not a verbatim copy of official DepEd modules or PDFs.

## AI Features

AI calls are centralized in:

```text
lib/services/gemini_service.dart
lib/services/lesson_suggestion_service.dart
```

`GeminiService` handles:

- `simplifyWord`
- `generateQuizQuestions`
- `evaluateQuizAnswers`
- `conductAssessmentConversation`
- `getAssessmentGreeting`
- `conductConversation`
- `getInitialGreeting`
- `translateText`

`LessonSuggestionService` handles:

- Teacher recommendations for student struggling topics.
- Class intervention plans.

AI error handling:

- Empty responses are converted to user-facing retry messages.
- Firebase AI SDK parsing failures are caught.
- Service-disabled, invalid API key, zero quota, quota exceeded, and permission errors are mapped to clearer app messages.
- Quiz generation and quiz evaluation both have fallback behavior so the student can continue if AI fails.

## Dialect Support

The UI now uses the word "dialect" because the supported choices are Filipino languages/dialects used by students.

Supported choices are defined in `lib/models/translation_models.dart`:

| Code | Display |
| --- | --- |
| `en` | English |
| `tl` | Tagalog |
| `ceb` | Cebuano |
| `ilo` | Ilocano |
| `hil` | Hiligaynon |
| `war` | Waray |
| `pam` | Kapampangan |
| `bik` | Bikol |
| `pan` | Pangasinan |

Important implementation note: several internal class names, field names, and Hive keys still use `language` or `preferredLanguage`. These names are kept for compatibility with existing local and Firestore data. User-facing copy should say `dialect`.

Translation-related files:

| File | Purpose |
| --- | --- |
| `lib/screens/language_selector_screen.dart` | First-login dialect selection UI. |
| `lib/screens/student_settings_screen.dart` | Dialect setting after login. |
| `lib/services/translation_service.dart` | Runtime translation with memory and Hive cache. |
| `lib/widgets/translatable_text.dart` | Widget for translated UI strings. |
| `lib/utils/translations.dart` | Static translated labels. |
| `lib/models/translation_models.dart` | Supported dialect enum and cache models. |

Google Cloud Translation API note: keep the API key in `.env` as `GOOGLE_TRANSLATE_API_KEY`. Screens should use `TranslatableText` or `TranslationService`; do not call the Cloud Translation endpoint directly from UI code.

## Data Storage

### Hive

Hive is initialized in `LocalStorageService.init()`.

| Box | Purpose |
| --- | --- |
| `lessons` | Lesson completion and learned concepts. |
| `scores` | Quiz responses. |
| `conversations` | AI assessment/conversation records. |
| `user` | Current local user. |
| `word_cache` | Cached word explanations. |
| `translation_cache` | Cached UI translations. |
| `language_preference` | Preferred dialect and seeder status. |

Common Hive keys:

```text
currentUser
completed_<lessonId>
learned_<lessonId>
quiz_<lessonId>
ai_<lessonId>
preferred_language
seeder_completed
```

### Firestore

Firestore access is centralized in `lib/services/firestore_service.dart`.

Collections currently used:

```text
users/{uid}
users/{uid}/quizResults/{resultId}
users/{uid}/assessmentResults/{resultId}
users/{uid}/learnedConcepts/{conceptId}
teachers/{teacherId}/students/{studentId}
teachers/{teacherId}/modules/{moduleId}
```

Firestore is treated as optional in some flows. When unavailable, the app logs the error and keeps local progress where possible.

## Important Files

| Path | Purpose |
| --- | --- |
| `lib/main.dart` | App startup, Firebase init, Hive init, Material app. |
| `lib/firebase_options.dart` | FlutterFire-generated Firebase config. Do not edit by hand unless regenerating is impossible. |
| `lib/utils/constants.dart` | Model name, demo credentials, Hive box names, app info. |
| `lib/utils/theme.dart` | Global Material theme. |
| `lib/data/sample_lessons.dart` | Official Grade 7 curriculum outline mapped into subject/module/lesson seed data. |
| `lib/data/sample_students.dart` | Demo teacher/student data. |
| `lib/services/auth_service.dart` | Firebase Auth, demo login fallback, local user session. |
| `lib/services/local_storage_service.dart` | Hive persistence. |
| `lib/services/firestore_service.dart` | Firestore persistence and teacher/student/module APIs. |
| `lib/services/gemini_service.dart` | Student-facing Firebase AI Logic calls. |
| `lib/services/lesson_suggestion_service.dart` | Teacher-facing AI suggestions. |
| `lib/services/translation_service.dart` | Runtime translation cache and dialect preference support. |
| `lib/screens/login_screen.dart` | Login and quick demo buttons. |
| `lib/screens/student_home_screen.dart` | Student subject dashboard. |
| `lib/screens/subject_modules_screen.dart` | Modules inside a subject. |
| `lib/screens/module_lessons_screen.dart` | Lessons inside a module. |
| `lib/screens/lesson_reading_screen.dart` | Tappable reading experience and learned concept logging. |
| `lib/screens/learning_recap_screen.dart` | Review screen for selected words/concepts before quiz. |
| `lib/screens/quiz_screen.dart` | AI quiz generation, answer submission, save results. |
| `lib/screens/ai_assessment_screen.dart` | AI assessment conversation after quiz. |
| `lib/screens/my_progress_screen.dart` | Student progress view. |
| `lib/screens/teacher_dashboard_screen.dart` | Teacher overview and actions. |
| `lib/screens/teacher_students_screen.dart` | Teacher student list and enrollment. |
| `lib/screens/teacher_student_detail_screen.dart` | Student progress details and suggestions. |
| `lib/screens/teacher_modules_screen.dart` | Teacher module list. |
| `lib/screens/teacher_module_upload_screen.dart` | Create/edit teacher modules. |
| `assets/images/Klaro-logo.png` | App logo. |
| `scripts/add_demo_student_to_teacher.dart` | One-off helper script for adding `demo-student` to `demo-teacher` in Firestore. |

## Models

| Model | File | Notes |
| --- | --- | --- |
| `AppUser` | `lib/models/app_user.dart` | Current signed-in app user and role. |
| `UserProfile` | `lib/models/user_profile.dart` | Firestore user profile. |
| `CurriculumSubject` | `lib/models/curriculum.dart` | Subject containing modules. |
| `CurriculumModule` | `lib/models/curriculum.dart` | Module containing lessons. |
| `Lesson` | `lib/models/lesson.dart` | Lesson content, key terms, module metadata. |
| `LearnedConcept` | `lib/models/learned_concept.dart` | Word/concept selected during reading. |
| `QuizQuestion` | `lib/models/quiz_question.dart` | Multiple-choice and short-answer questions. |
| `QuizResponse` | `lib/models/quiz_response.dart` | Saved quiz result and attempt metadata. |
| `AIConversation` | `lib/models/ai_conversation.dart` | AI assessment conversation and score. |
| `TeacherStudent` | `lib/models/teacher_student.dart` | Teacher class enrollment record. |
| `StudentProgressSummary` | `lib/models/teacher_student.dart` | Aggregated quiz/AI progress for teachers. |
| `ModuleUpload` | `lib/models/module_upload.dart` | Teacher-created module content. |
| `LessonSuggestion` | `lib/models/lesson_suggestion.dart` | AI-generated teaching suggestion. |
| `TranslationRequest`, `TranslationResponse`, `TranslationCacheEntry`, `LanguagePreference` | `lib/models/translation_models.dart` | Translation and dialect cache support. |

## Development Workflow

Install dependencies:

```powershell
flutter pub get
```

Format Dart files:

```powershell
dart format lib test scripts
```

Analyze:

```powershell
flutter analyze
```

Run on connected Android device:

```powershell
flutter run
```

Build debug APK:

```powershell
flutter build apk --debug
```

Run the demo Firestore helper script:

```powershell
dart run scripts/add_demo_student_to_teacher.dart
```

## Testing Checklist

Use this after major changes:

1. Confirm `android/app/google-services.json` exists.
2. Confirm `lib/firebase_options.dart` exists.
3. Confirm both files point to Firebase project `klaro-851a6`.
4. Confirm Firebase Auth email/password sign-in is enabled.
5. Confirm Firestore is enabled.
6. Confirm Firebase AI Logic is enabled and has quota for `gemini-3.1-flash-lite-preview`.
7. Run `flutter pub get`.
8. Run `flutter build apk --debug`.
9. Run on an Android phone.
10. Log in with the student demo account.
11. Select a dialect.
12. Open a subject, module, and lesson.
13. Tap a content word and confirm the popup returns an explanation.
14. Tap `Review Learning Recap` and confirm selected words are listed.
15. Start and submit a quiz.
16. Continue to AI assessment and complete the conversation.
17. Check `My Progress`.
18. Log in with the teacher demo account.
19. Open students, modules, and dashboard views.
20. Confirm teacher suggestions load when progress data exists.

## Troubleshooting

### `flutterfire` is not recognized

The Dart global pub cache bin folder is not on PATH. Use the full command:

```powershell
dart pub global run flutterfire_cli:flutterfire configure --project=klaro-851a6
```

The FlutterFire CLI also requires the official Firebase CLI.

### Firebase CLI login fails

Install or repair the official Firebase CLI, then run:

```powershell
firebase --version
firebase login
```

If the packaged Firebase CLI is broken, install the npm version from a working Node setup.

### Word explanation says Firebase AI Logic is not enabled

Enable Firebase AI Logic for the same Firebase project used by the Android app. Wait a few minutes, restart the app, then try again.

### Word explanation says quota is `limit: 0`

That means the selected Firebase project/model currently has zero available quota. It is a project/model quota issue, not a local app counter. Check Firebase AI Logic and Google AI quota/billing for `gemini-3.1-flash-lite-preview`, or switch `AppConstants.geminiModel` to a model with available quota.

### Firebase rejects the Android API key

Check that:

- `android/app/google-services.json` belongs to project `klaro-851a6`.
- The Android app package is `com.example.klaro`.
- `lib/firebase_options.dart` was generated for the same Firebase project.
- The app was rebuilt after replacing Firebase config files.

### Login fails

Check that Firebase Auth email/password sign-in is enabled and that the account exists in Firebase. The local demo credentials should still work because `AuthService` checks them before Firebase Auth.

### Translated text overflows

Most recent UI work uses wrapping/flexible text in key screens, but longer dialect translations can still expose layout issues. Prefer `Flexible`, `Expanded`, `Wrap`, `maxLines`, or scrollable content when adding new translated labels.

### Firestore data does not appear in teacher screens

Check the teacher id and collection path:

```text
teachers/{teacherId}/students/{studentId}
teachers/{teacherId}/modules/{moduleId}
```

For demo mode, the expected ids are:

```text
demo-teacher
demo-student
```

## Known Gaps

- Android is the primary tested platform.
- Release signing is not configured.
- Some internal names still say `language` even though the UI says `dialect`.
- Lesson content is generated seed content, not full official DepEd module text.
- `ai_conversation_screen.dart`, `performance_summary_screen.dart`, and `student_dashboard_screen.dart` are still present as older or alternate screens.
- Firestore and Firebase AI failures are handled with fallbacks in some student flows, but teacher AI suggestions depend on Firebase AI being available.
- Analyzer may still report style/deprecation warnings in older UI code.

## Contributor Notes

- Keep curriculum navigation as `Subject -> Module -> Lesson`.
- Add curriculum seed updates in `lib/data/sample_lessons.dart`.
- Keep AI prompt work in `GeminiService` or `LessonSuggestionService`.
- Keep local persistence changes inside `LocalStorageService`.
- Keep Firestore path changes inside `FirestoreService`.
- Do not commit real API keys, private service accounts, or local signing secrets.
- User-facing copy should say `dialect`; internal compatibility fields may still say `language`.

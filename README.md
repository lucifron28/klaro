# Klaro

Klaro is a Flutter Android app for Filipino students. It helps students read a lesson, tap unfamiliar words for simple explanations and Tagalog/Taglish support, review the words they explored, take an AI-generated quiz, and then talk to an AI tutor for a final understanding check.

Built for InnOlympics 2026, Track A: Pangarap sa Pagkatuto.

## Current Status

The app currently supports:

- Student quick demo login and Firebase email/password login.
- Teacher quick demo login with a demo class dashboard.
- Interactive reading with tappable words.
- Gemini-powered word simplification and Tagalog/Taglish explanation.
- Learned words/concepts logging per lesson.
- Learning recap before quiz.
- Gemini-generated quiz questions.
- Gemini-based quiz answer evaluation.
- Klaro AI conversation after the quiz.
- Local progress storage with Hive.
- Firebase Android configuration through `android/app/google-services.json`.

The app is Android-first right now. iOS, web, desktop, and production backend behavior are not fully configured.

## Developer Quick Start

Use this when setting up a fresh machine.

```powershell
cd C:\Users\Ron\InnOlympics\klaro
flutter pub get
```

Create a local `.env` file in the project root:

```env
GEMINI_API_KEY=your_gemini_api_key_here
```

Make sure Firebase Android config exists:

```text
android/app/google-services.json
```

Then run:

```powershell
flutter run
```

For a debug APK:

```powershell
flutter build apk --debug
```

Output:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Required Local Files

These are required for a full working local build, but should be handled carefully.

### `.env`

Project root:

```text
.env
```

Expected content:

```env
GEMINI_API_KEY=your_gemini_api_key_here
```

`.env` is ignored by Git through `.gitignore`. Use [.env.example](./.env.example) as the template.

Important: because Flutter bundles assets into the APK, this only keeps the key out of source control. It is not production-grade secret protection. For production, Gemini calls should go through a backend or Cloud Function.

### `google-services.json`

Android Firebase config must be here:

```text
android/app/google-services.json
```

The current Android package/application id is:

```text
com.example.klaro
```

The Firebase Android app must use that package name unless `applicationId` is changed in [android/app/build.gradle.kts](./android/app/build.gradle.kts).

## Common Commands

Analyze Dart code:

```powershell
flutter analyze
```

If `flutter` is not on PATH on this machine, use:

```powershell
C:\Users\Ron\develop\flutter\bin\flutter.bat analyze
```

Format changed Dart files:

```powershell
dart format lib test
```

Build Android debug APK:

```powershell
flutter build apk --debug
```

Run on connected Android device:

```powershell
flutter devices
flutter run
```

Clean generated build output:

```powershell
flutter clean
flutter pub get
```

## Tech Stack

| Area | Current implementation |
| --- | --- |
| App framework | Flutter / Dart |
| UI | Material 3, Google Fonts |
| Authentication | Firebase Auth plus local demo fallback |
| Android Firebase config | Google Services Gradle plugin |
| AI provider | Google Gemini REST API |
| Gemini model | `gemini-flash-latest` |
| AI networking | `http` package |
| Local persistence | Hive / Hive Flutter |
| Demo lesson data | Hardcoded Dart data |
| Demo teacher data | Hardcoded Dart data |

Note: `google_generative_ai` is still listed in `pubspec.yaml`, but the active Gemini integration uses REST through [lib/services/gemini_service.dart](./lib/services/gemini_service.dart).

## Main User Flows

### Student Flow

1. Open app.
2. Tap `Student` quick demo login or sign in with Firebase.
3. Choose a lesson from the lessons list.
4. Read the lesson.
5. Tap unfamiliar words.
6. Klaro opens a bottom sheet with:
   - Simple explanation
   - Tagalog/Taglish explanation
7. Each successfully explained word is saved as a learned concept for that lesson.
8. Tap `Review Learning Recap`.
9. Review:
   - Lesson concept chips from `lesson.keyTerms`
   - Words the student tapped while reading
   - Explanation and Tagalog/Taglish text for each word
10. Tap `Start Quiz`.
11. Answer the Gemini-generated quiz.
12. Submit answers.
13. Continue to `Talk to Klaro AI`.
14. Complete the AI tutor conversation.
15. View the performance summary.

### Teacher Flow

1. Open app.
2. Tap `Teacher` quick demo login.
3. View the class dashboard.

Teacher mode currently uses hardcoded demo student data in [lib/data/sample_students.dart](./lib/data/sample_students.dart). It does not yet read real class data from Firestore.

## Project Structure

```text
lib/
  main.dart
  data/
    sample_lessons.dart
    sample_students.dart
  models/
    ai_conversation.dart
    app_user.dart
    learned_concept.dart
    lesson.dart
    quiz_question.dart
    quiz_response.dart
  screens/
    ai_conversation_screen.dart
    learning_recap_screen.dart
    lesson_reading_screen.dart
    login_screen.dart
    performance_summary_screen.dart
    quiz_screen.dart
    student_dashboard_screen.dart
    student_home_screen.dart
    teacher_dashboard_screen.dart
  services/
    auth_service.dart
    env_service.dart
    gemini_service.dart
    local_storage_service.dart
    translation_service.dart
  utils/
    constants.dart
    helpers.dart
    theme.dart
  widgets/
    message_bubble.dart
    quiz_card.dart
    score_card.dart
    word_popup.dart
```

## Important Files

### App entry point

[lib/main.dart](./lib/main.dart)

Responsibilities:

- Initializes Flutter bindings.
- Loads `.env` through `EnvService`.
- Tries to initialize Firebase.
- Initializes Hive boxes.
- Starts `KlaroApp`.

Firebase init is wrapped in `try/catch` so the app can still render in local demo mode if Firebase is not configured.

### Environment loading

[lib/services/env_service.dart](./lib/services/env_service.dart)

Responsibilities:

- Loads `.env` from Flutter assets.
- Parses `KEY=VALUE` lines.
- Exposes values through `EnvService.get(key)`.

The `.env` asset is declared in [pubspec.yaml](./pubspec.yaml).

### Constants

[lib/utils/constants.dart](./lib/utils/constants.dart)

Responsibilities:

- App name/tagline/version.
- Hive box names.
- Demo login credentials.
- Gemini model name.
- Gemini API key lookup.

API key behavior:

1. First uses `--dart-define=GEMINI_API_KEY=...` if provided.
2. Otherwise uses `GEMINI_API_KEY` from `.env`.

There must be no hardcoded API key in this file.

### Authentication

[lib/services/auth_service.dart](./lib/services/auth_service.dart)

Behavior:

- Quick demo credentials bypass Firebase and create a local `AppUser`.
- Non-demo credentials use Firebase Auth.
- Role is determined by email:
  - Email containing `teacher` becomes teacher.
  - Everything else becomes student.
- Current user data is saved in Hive.

Demo accounts:

```text
student1@test.com / password123
teacher1@test.com / password123
```

### Gemini service

[lib/services/gemini_service.dart](./lib/services/gemini_service.dart)

This service owns all Gemini interactions:

- `simplifyWord`
- `generateQuizQuestions`
- `evaluateQuizAnswers`
- `conductConversation`
- `getInitialGreeting`

It calls:

```text
https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent
```

Headers:

```text
Content-Type: application/json
X-goog-api-key: <GEMINI_API_KEY>
```

The service expects JSON for structured calls and falls back where appropriate:

- Word simplification throws if Gemini returns incomplete JSON.
- Quiz generation falls back to hardcoded questions.
- Quiz evaluation falls back to basic answer matching.
- AI conversation returns a retry-style response if the API call fails.

### Local storage

[lib/services/local_storage_service.dart](./lib/services/local_storage_service.dart)

Hive boxes:

| Box | Constant | Purpose |
| --- | --- | --- |
| `lessons` | `AppConstants.lessonsBox` | Lesson completion and learned concepts |
| `scores` | `AppConstants.scoresBox` | Quiz responses |
| `conversations` | `AppConstants.conversationsBox` | AI conversation records |
| `user` | `AppConstants.userBox` | Current signed-in user |
| `word_cache` | `AppConstants.cacheBox` | Cached Gemini word explanations |

Important keys:

```text
currentUser
completed_<lessonId>
learned_<lessonId>
quiz_<lessonId>
ai_<lessonId>
```

Learned concepts are saved per lesson as a list of `LearnedConcept`.

### Lesson data

[lib/data/sample_lessons.dart](./lib/data/sample_lessons.dart)

Current lessons:

- The Water Cycle
- Photosynthesis

Each lesson has:

- `id`
- `title`
- `subject`
- `gradeLevel`
- `content`
- `keyTerms`

Add demo lessons here until Firestore lesson management exists.

## Screen Responsibilities

| Screen | Responsibility |
| --- | --- |
| `LoginScreen` | Email/password login plus Student/Teacher quick login buttons |
| `StudentHomeScreen` | Student lesson list and progress tab navigation |
| `LessonReadingScreen` | Interactive lesson reader, word tapping, learned concept logging |
| `LearningRecapScreen` | Review selected words and lesson concepts before quiz |
| `QuizScreen` | Generate/display/evaluate quiz questions |
| `AIConversationScreen` | Tutor-style AI conversation after quiz |
| `PerformanceSummaryScreen` | Combined quiz and AI assessment summary |
| `StudentDashboardScreen` | Local student progress dashboard |
| `TeacherDashboardScreen` | Demo teacher/class overview |

## Data Models

| Model | Purpose |
| --- | --- |
| `AppUser` | Local representation of student/teacher user |
| `Lesson` | Lesson metadata and content |
| `LearnedConcept` | Word selected during reading plus explanation and Tagalog/Taglish text |
| `QuizQuestion` | Generated quiz question, answer, feedback state |
| `QuizResponse` | Saved quiz score record |
| `AIConversation` | Saved AI conversation assessment |

## Reading and Recap Flow Details

The current reading flow is:

```text
LessonReadingScreen
  -> user taps word
  -> check Hive word_cache
  -> if cached and usable, show cached explanation
  -> otherwise call Gemini simplifyWord
  -> cache result in word_cache
  -> save LearnedConcept under learned_<lessonId>
  -> show WordPopup
  -> Review Learning Recap
  -> LearningRecapScreen
  -> Start Quiz
  -> QuizScreen
```

A cached explanation is ignored if it looks like an old failed response, for example:

- Empty explanation
- Starts with `Unable to explain`
- Starts with `{`
- Contains `"explanation"`

That prevents old partial JSON responses from being reused.

## Firebase / Android Setup

Firebase is wired through Kotlin Gradle files.

[android/settings.gradle.kts](./android/settings.gradle.kts):

```kotlin
id("com.google.gms.google-services") version "4.4.4" apply false
```

[android/app/build.gradle.kts](./android/app/build.gradle.kts):

```kotlin
id("com.google.gms.google-services")
```

Android package:

```text
com.example.klaro
```

Main manifest:

[android/app/src/main/AndroidManifest.xml](./android/app/src/main/AndroidManifest.xml)

Includes:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

This is required for Gemini API calls on Android builds.

## Environment Variables

Current variables:

| Name | Required | Used by |
| --- | --- | --- |
| `GEMINI_API_KEY` | Yes for AI features | `GeminiService` |

Example:

```env
GEMINI_API_KEY=your_gemini_api_key_here
```

Alternative override:

```powershell
flutter run --dart-define=GEMINI_API_KEY=your_gemini_api_key_here
```

`--dart-define` takes priority over `.env`.

## Testing Checklist

Use this before handing the app to another teammate.

1. Confirm `.env` exists and has `GEMINI_API_KEY`.
2. Confirm `android/app/google-services.json` exists.
3. Run `flutter pub get`.
4. Run `flutter analyze`.
5. Run `flutter build apk --debug`.
6. Install/run on Android phone.
7. Test Student quick login.
8. Open The Water Cycle lesson.
9. Tap `Evaporation` or another word.
10. Confirm the word popup has:
    - Simple explanation
    - Tagalog/Taglish explanation
11. Tap `Review Learning Recap`.
12. Confirm selected words appear in the recap.
13. Tap `Start Quiz`.
14. Confirm quiz questions generate.
15. Submit quiz and continue to AI conversation.
16. Test Teacher quick login and dashboard.

## Troubleshooting

### Black screen on launch

Usually caused by startup work failing before the first frame.

Check:

- `android/app/google-services.json` exists.
- Firebase package name matches `com.example.klaro`.
- `Firebase.initializeApp()` errors in logs.
- `.env` exists because it is declared as an asset.

Useful command:

```powershell
adb logcat -d -v time -t 1000
```

### Gemini says API key is not configured

Check:

- `.env` exists in project root.
- It contains `GEMINI_API_KEY=...`.
- `pubspec.yaml` includes `.env` under `flutter.assets`.
- The app was rebuilt after editing `.env`.

### Gemini works in curl but not in app

Check:

- Android app has `INTERNET` permission in the main manifest.
- Model is `gemini-flash-latest` in `AppConstants.geminiModel`.
- Phone has internet.
- The API key in `.env` is the same key used in curl.
- The debug APK was rebuilt and reinstalled.

### Firebase login fails

Check:

- Firebase Authentication has Email/Password enabled.
- Test accounts exist in Firebase.
- `android/app/google-services.json` belongs to the same Firebase project.
- Android package in Firebase is `com.example.klaro`.

Student/Teacher quick login should still work even if Firebase is unavailable.

### Build fails because `.env` is missing

Create `.env` from `.env.example`:

```powershell
Copy-Item .env.example .env
```

Then edit `.env` and set the real API key.

### `flutter` is not recognized

Use the explicit Flutter path on this machine:

```powershell
C:\Users\Ron\develop\flutter\bin\flutter.bat --version
```

Or add Flutter to PATH.

### Gradle says JAVA_HOME is missing

Use Android Studio's bundled JBR:

```powershell
$env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr'
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
```

Then rebuild.

## Development Notes

- Keep UI changes consistent with [lib/utils/theme.dart](./lib/utils/theme.dart).
- Store local-only data through [LocalStorageService](./lib/services/local_storage_service.dart).
- Keep all Gemini prompt and response parsing logic inside [GeminiService](./lib/services/gemini_service.dart).
- Add new lesson demo data in [sample_lessons.dart](./lib/data/sample_lessons.dart).
- Do not hardcode API keys in Dart files.
- Do not commit `.env`.
- Avoid deleting existing Hive data unless deliberately testing first-run behavior.

## Known Gaps / Future Work

- Real teacher-created lessons are not implemented yet.
- Firestore is installed but not yet used for lesson/class data.
- Teacher dashboard uses demo data.
- API key is still bundled into the APK via `.env`; production needs a backend proxy.
- Release signing is not configured; release currently uses debug signing.
- `google_generative_ai` dependency appears unused after the REST migration and can be removed later after confirming no imports depend on it.
- Existing analyzer output includes warnings/infos such as deprecated `withOpacity` usage and dangling doc comments.

## Color Palette

| Color | Hex | Usage |
| --- | --- | --- |
| Primary Blue | `#1E4BB3` | Headers, primary actions, key text |
| Light Blue | `#85D7FF` | Highlights, secondary accents |
| Accent Yellow | `#FFD863` | Main call-to-action buttons |
| White | `#FFFFFF` | Cards and surfaces |
| Surface Light | `#F5F8FC` | Page background |
| Text Dark | `#1A1A2E` | Main text |
| Text Muted | `#6B7280` | Secondary text |
| Success | `#22C55E` | Positive status |
| Error | `#EF4444` | Error state |
| Warning | `#F59E0B` | Warning state |

## Handoff Summary

For teammates: start with `.env`, Firebase config, and `flutter pub get`. The main app behavior is local-first with Firebase Auth and Gemini API calls layered on top. Most feature work will happen in `screens/`, `services/`, and `models/`; keep cross-feature logic in services so the screens stay focused on UI and navigation.

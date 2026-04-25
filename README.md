# Klaro

Klaro is a Flutter Android app for Filipino Grade 7 learners. Students browse the DepEd K-12 curriculum by subject, module, and lesson, read a lesson, tap unfamiliar words for simple explanations and Tagalog/Taglish support, review selected words in a learning recap, take a quiz, and talk to Klaro AI for a final understanding check.

Built for InnOlympics 2026, Track A: Pangarap sa Pagkatuto.

## Current Status

The app currently supports:

- Student quick demo login and Firebase email/password login.
- Teacher quick demo login with a demo class dashboard.
- Grade 7 curriculum browsing as `Subject -> Module -> Lesson`.
- Science 7, English 7, and Mathematics 7 module lists from the supplied DepEd LRMDS curriculum outline.
- Interactive reading with tappable words.
- Firebase AI Logic powered word simplification and Tagalog/Taglish explanation.
- Learned words/concepts logging per lesson.
- Learning recap before quiz.
- Firebase AI Logic powered quiz generation, quiz evaluation, and AI conversation.
- Local progress storage with Hive.
- Firebase Android configuration through `android/app/google-services.json` and `lib/firebase_options.dart`.

The app is Android-first right now. iOS, web, desktop, real teacher lesson management, and production backend behavior are not fully configured.

## Developer Quick Start

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

Output:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Firebase Setup

Required files:

```text
android/app/google-services.json
lib/firebase_options.dart
```

Current Android package/application id:

```text
com.example.klaro
```

Both Firebase files must point to the same Firebase project. The current local files point to project `klaro-851a6`.

Firebase AI Logic must be enabled for the same project:

```text
https://console.firebase.google.com/project/klaro-851a6/genai
```

The app initializes Firebase with:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## Environment Files

No `.env` file is required for the current Firebase AI Logic setup. The app does not read a separate Gemini API key from Dart code.

`.env.example` is only a note for teammates. Do not put Gemini API keys in Dart files.

## Tech Stack

| Area | Current implementation |
| --- | --- |
| App framework | Flutter / Dart |
| UI | Material 3, Google Fonts |
| Authentication | Firebase Auth plus local demo fallback |
| Android Firebase config | Google Services Gradle plugin |
| AI provider | Firebase AI Logic SDK |
| AI SDK | `firebase_ai` |
| Gemini model | `gemini-2.5-flash-lite` in `AppConstants.geminiModel` |
| Local persistence | Hive / Hive Flutter |
| Curriculum data | Hardcoded Dart data in `SampleLessons` |
| Demo teacher data | Hardcoded Dart data |

## Curriculum Structure

The curriculum is modeled as:

```text
CurriculumSubject
  -> CurriculumModule
    -> Lesson
```

Current subjects:

| Subject | Modules | Lessons |
| --- | ---: | ---: |
| Science 7 | 4 | 31 |
| English 7 | 4 | 32 |
| Mathematics 7 | 4 | 33 |

Module mapping:

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

The app includes every lesson title from the supplied curriculum list. Lesson bodies are currently generated starter text from the curriculum metadata, not full official DepEd module content.

## Main Student Flow

1. Open app.
2. Tap `Student` quick demo login or sign in with Firebase.
3. Choose a Grade 7 subject.
4. Choose a quarter module.
5. Choose a lesson.
6. Read the lesson.
7. Tap unfamiliar words.
8. Klaro opens a bottom sheet with a simple explanation and Tagalog/Taglish explanation.
9. Each successfully explained word is saved as a learned concept for that lesson.
10. Tap `Review Learning Recap`.
11. Review selected words and lesson concepts.
12. Tap `Start Quiz`.
13. Answer the AI-generated quiz.
14. Submit answers.
15. Continue to `Talk to Klaro AI`.
16. Complete the AI tutor conversation.
17. View the performance summary.

## Project Structure

```text
lib/
  main.dart
  firebase_options.dart
  data/
    sample_lessons.dart
    sample_students.dart
  models/
    ai_conversation.dart
    app_user.dart
    curriculum.dart
    learned_concept.dart
    lesson.dart
    quiz_question.dart
    quiz_response.dart
  screens/
    ai_conversation_screen.dart
    learning_recap_screen.dart
    lesson_reading_screen.dart
    login_screen.dart
    module_lessons_screen.dart
    performance_summary_screen.dart
    quiz_screen.dart
    student_dashboard_screen.dart
    student_home_screen.dart
    subject_modules_screen.dart
    teacher_dashboard_screen.dart
  services/
    auth_service.dart
    gemini_service.dart
    local_storage_service.dart
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

### `lib/data/sample_lessons.dart`

Owns the current Grade 7 curriculum seed data.

- `SampleLessons.subjects`: full subject/module/lesson hierarchy.
- `SampleLessons.lessons`: flattened lesson list for lookup and progress use.
- `getSubjectById`, `getModuleById`, `getLessonById`: lookup helpers.

### `lib/models/curriculum.dart`

Defines:

- `CurriculumSubject`
- `CurriculumModule`

`CurriculumSubject` contains modules. `CurriculumModule` contains lessons.

### `lib/models/lesson.dart`

Defines individual lesson records. Current fields include:

- `id`
- `title`
- `subject`
- `gradeLevel`
- `moduleId`
- `moduleTitle`
- `quarter`
- `content`
- `keyTerms`
- `dateCompleted`

### `lib/services/gemini_service.dart`

Owns all Firebase AI Logic calls:

- `simplifyWord`
- `generateQuizQuestions`
- `evaluateQuizAnswers`
- `conductConversation`
- `getInitialGreeting`

It uses:

```dart
FirebaseAI.googleAI().generativeModel(
  model: AppConstants.geminiModel,
)
```

Firebase AI errors are logged with `debugPrint` and converted into clearer app messages.

### `lib/screens/student_home_screen.dart`

Shows the Grade 7 subject list and links to module browsing.

### `lib/screens/subject_modules_screen.dart`

Shows the selected subject's quarter modules.

### `lib/screens/module_lessons_screen.dart`

Shows lessons inside one module and opens `LessonReadingScreen`.

### `lib/screens/lesson_reading_screen.dart`

Renders tappable lesson text, checks the word cache, calls `GeminiService.simplifyWord`, saves learned concepts, and opens the learning recap.

### `lib/services/local_storage_service.dart`

Hive boxes:

| Box | Constant | Purpose |
| --- | --- | --- |
| `lessons` | `AppConstants.lessonsBox` | Lesson completion and learned concepts |
| `scores` | `AppConstants.scoresBox` | Quiz responses |
| `conversations` | `AppConstants.conversationsBox` | AI conversation records |
| `user` | `AppConstants.userBox` | Current signed-in user |
| `word_cache` | `AppConstants.cacheBox` | Cached AI word explanations |

Important keys:

```text
currentUser
completed_<lessonId>
learned_<lessonId>
quiz_<lessonId>
ai_<lessonId>
```

## Testing Checklist

1. Confirm `android/app/google-services.json` exists.
2. Confirm `lib/firebase_options.dart` exists.
3. Confirm both Firebase files use the same project.
4. Enable Firebase AI Logic for the project.
5. Run `flutter pub get`.
6. Run `flutter build apk --debug`.
7. Run on Android phone.
8. Test Student quick login.
9. Open `Science 7 -> Quarter 1 Matter -> Scientific Ways of Acquiring Knowledge and Solving Problems`.
10. Tap a word and confirm the explanation popup works.
11. Tap `Review Learning Recap` and confirm selected words appear.
12. Start and submit a quiz.
13. Continue to AI conversation.
14. Test Teacher quick login and dashboard.

## Troubleshooting

### Tapping words says Firebase AI Logic is not enabled

Enable Firebase AI Logic for the project:

```text
https://console.firebase.google.com/project/klaro-851a6/genai
```

Wait a few minutes after enabling, then restart the app.

### Firebase AI says quota exceeded with `limit: 0`

That means the Firebase project has no quota for the selected Gemini model, not that the app already used too much. Klaro currently uses `gemini-2.5-flash-lite`.

### Firebase login fails

Check:

- Firebase Authentication has Email/Password enabled.
- Test accounts exist in Firebase.
- `android/app/google-services.json` belongs to the same Firebase project.
- Android package in Firebase is `com.example.klaro`.

Student/Teacher quick login should still work even if Firebase login is unavailable.

### `flutter` is not recognized

Use:

```powershell
C:\Users\Ron\develop\flutter\bin\flutter.bat --version
```

### Gradle says `JAVA_HOME` is missing

Use Android Studio's bundled JBR:

```powershell
$env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr'
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
```

Then rebuild.

## Development Notes

- Keep UI changes consistent with `lib/utils/theme.dart`.
- Store local-only data through `LocalStorageService`.
- Keep AI prompt and response parsing logic inside `GeminiService`.
- Add or update curriculum seed data in `lib/data/sample_lessons.dart`.
- Keep the hierarchy as `Subject -> Module -> Lesson`.
- Do not hardcode separate Gemini API keys in Dart files.
- Avoid deleting Hive data unless deliberately testing first-run behavior.

## Known Gaps / Future Work

- Full official DepEd lesson body content is not imported yet; current lessons use generated starter text from the curriculum metadata.
- Real teacher-created lessons are not implemented yet.
- Firestore is installed but not yet used for lesson/class data.
- Teacher dashboard uses demo data.
- Release signing is not configured; release currently uses debug signing.
- Existing analyzer output may include older style warnings such as deprecated `withOpacity` usage.

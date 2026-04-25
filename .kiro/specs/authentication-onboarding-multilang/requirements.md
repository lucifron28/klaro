# Requirements Document

## Introduction

This document specifies the requirements for implementing a complete authentication system, onboarding flow, and multi-language support in the Klaro Flutter app. The system will replace the current quick demo login with full Firebase Authentication, create test accounts in Firebase, implement role-based navigation, provide first-time user onboarding with language selection, and integrate Gemini-powered translation for static UI text across nine Philippine languages.

## Glossary

- **Auth_System**: The Firebase Authentication service managing user accounts and sessions
- **Firestore_Service**: The Firebase Firestore database storing user profile data
- **Seeder_Service**: A service that creates test accounts in Firebase Authentication and Firestore
- **Login_Screen**: The UI screen where users enter credentials to authenticate
- **Register_Screen**: The UI screen where new users create accounts
- **Onboarding_Flow**: The first-time user experience that collects language preferences
- **Language_Selector**: The UI component allowing users to choose their preferred language
- **Translation_Service**: A service using Gemini API to translate static UI text
- **Role**: A user classification (teacher or student) determining navigation destination
- **Session**: An authenticated user state persisted across app restarts
- **Static_Text**: Hardcoded UI strings in Flutter code (labels, buttons, instructions)
- **Dynamic_Content**: Runtime data from Firestore, APIs, or user input (not translated)
- **Test_Account**: A pre-seeded Firebase account for development and testing purposes

## Requirements

### Requirement 1: Firebase Authentication System

**User Story:** As a user, I want to authenticate with email and password, so that I can securely access my personalized learning experience.

#### Acceptance Criteria

1. THE Auth_System SHALL support email and password authentication using Firebase Authentication
2. WHEN a user enters valid credentials, THE Auth_System SHALL authenticate the user and create a session
3. WHEN a user enters invalid credentials, THE Auth_System SHALL return a descriptive error message
4. THE Auth_System SHALL persist the authentication session across app restarts
5. WHEN an authenticated user opens the app, THE Auth_System SHALL automatically restore the session without requiring re-login
6. THE Auth_System SHALL provide a logout function that terminates the current session
7. WHEN a user logs out, THE Auth_System SHALL clear the session and redirect to the Login_Screen

### Requirement 2: Authentication User Interface

**User Story:** As a user, I want to use the existing login screen with enhanced Firebase integration, so that I can authenticate and access my personalized learning experience.

#### Acceptance Criteria

1. THE Login_Screen SHALL continue to display email and password input fields (existing implementation)
2. THE Login_Screen SHALL continue to display quick demo login buttons for Student and Teacher (existing implementation)
3. WHEN the login button is tapped with valid inputs, THE Login_Screen SHALL call the Auth_System to authenticate
4. WHEN authentication succeeds, THE Login_Screen SHALL check the isFirstLogin flag from Firestore
5. WHEN isFirstLogin is true, THE Login_Screen SHALL navigate to the Language_Selector screen
6. WHEN isFirstLogin is false, THE Login_Screen SHALL navigate to the appropriate dashboard based on user role (TeacherDashboardScreen for teachers, StudentHomeScreen for students)
7. WHEN authentication fails, THE Login_Screen SHALL display the error message from the Auth_System

### Requirement 3: Test Account Seeding

**User Story:** As a developer, I want test accounts automatically created in Firebase, so that I can test authentication without manual account setup.

#### Acceptance Criteria

1. THE Seeder_Service SHALL create a teacher test account with email teacher@test.com and password password123
2. THE Seeder_Service SHALL create a student test account with email student@test.com and password password123
3. THE Seeder_Service SHALL create accounts in both Firebase Authentication and Firestore
4. THE Seeder_Service SHALL check if test accounts already exist before attempting creation
5. WHEN a test account already exists, THE Seeder_Service SHALL skip creation for that account
6. THE Seeder_Service SHALL execute automatically when the app launches in development mode
7. WHEN seeding completes, THE Seeder_Service SHALL log success or failure messages for debugging
8. THE Seeder_Service SHALL set isFirstLogin to true for newly created test accounts

### Requirement 4: Firestore User Data Structure

**User Story:** As a system, I want user profile data stored in Firestore, so that I can retrieve role and preferences after authentication.

#### Acceptance Criteria

1. THE Firestore_Service SHALL store user documents in a collection named users
2. THE Firestore_Service SHALL include the following fields in each user document: uid, email, role, isFirstLogin, preferredLanguage
3. THE Firestore_Service SHALL set uid to the Firebase Authentication user ID
4. THE Firestore_Service SHALL set role to either teacher or student
5. THE Firestore_Service SHALL set isFirstLogin to true when creating a new user document
6. THE Firestore_Service SHALL set preferredLanguage to en by default
7. WHEN a new Firebase Authentication account is created, THE Firestore_Service SHALL automatically create a corresponding user document

### Requirement 5: Role-Based Navigation

**User Story:** As a user, I want to be directed to the appropriate dashboard based on my role, so that I see relevant features for my account type.

#### Acceptance Criteria

1. WHEN a user successfully authenticates, THE Auth_System SHALL fetch the user document from Firestore
2. WHEN the user role is teacher, THE Auth_System SHALL navigate to TeacherDashboardScreen
3. WHEN the user role is student, THE Auth_System SHALL navigate to StudentHomeScreen
4. WHEN the Firestore user document cannot be retrieved, THE Auth_System SHALL display an error message and remain on the Login_Screen

### Requirement 6: First-Time Login Onboarding

**User Story:** As a first-time user, I want to select my preferred language during onboarding, so that the app interface matches my language preference.

#### Acceptance Criteria

1. WHEN a user successfully authenticates, THE Onboarding_Flow SHALL check the isFirstLogin field in Firestore
2. WHEN isFirstLogin is true, THE Onboarding_Flow SHALL navigate to the Language_Selector screen before the dashboard
3. WHEN isFirstLogin is false, THE Onboarding_Flow SHALL navigate directly to the role-based dashboard
4. WHEN the user completes language selection, THE Onboarding_Flow SHALL set isFirstLogin to false in Firestore
5. WHEN the user completes language selection, THE Onboarding_Flow SHALL save the selected language to preferredLanguage in Firestore

### Requirement 7: Multi-Language Selection System

**User Story:** As a user, I want to choose from nine Philippine languages, so that I can use the app in my preferred language.

#### Acceptance Criteria

1. THE Language_Selector SHALL support the following languages: English, Tagalog, Cebuano, Ilocano, Hiligaynon, Waray, Kapampangan, Bikol, Pangasinan
2. THE Language_Selector SHALL use the following language codes: en, tl, ceb, ilo, hil, war, pam, bik, pan
3. THE Language_Selector SHALL display all nine languages as selectable options
4. WHEN a user selects a language, THE Language_Selector SHALL save the language code to Firestore preferredLanguage field
5. WHEN a user selects a language, THE Language_Selector SHALL save the language code to local storage
6. WHEN a language is selected, THE Translation_Service SHALL apply translations immediately to the current screen
7. THE Language_Selector SHALL set English (en) as the default language when no preference exists

### Requirement 8: Gemini Translation Integration for Static Text

**User Story:** As a user, I want static UI text translated to my preferred language, so that I can understand the app interface in my native language.

#### Acceptance Criteria

1. THE Translation_Service SHALL translate only static UI text defined in Flutter code
2. THE Translation_Service SHALL NOT translate Firestore data, API responses, user-generated content, or runtime computed values
3. THE Translation_Service SHALL use the Gemini API to generate translations
4. WHEN a translation is requested, THE Translation_Service SHALL send the static text and target language code to Gemini
5. WHEN Gemini returns a translation, THE Translation_Service SHALL cache the result in memory
6. WHEN a previously translated text is requested again, THE Translation_Service SHALL return the cached translation without calling Gemini
7. THE Translation_Service SHALL apply translations to at least one complete screen as a demonstration
8. WHEN the Translation_Service encounters an error, THE Translation_Service SHALL fall back to displaying the original English text
9. THE Translation_Service SHALL load the user's preferred language from Firestore on app startup
10. WHEN the preferred language is loaded, THE Translation_Service SHALL apply translations to all static text in the current view

### Requirement 9: Translation Service Parser and Printer

**User Story:** As a developer, I want a structured translation format, so that I can reliably parse and apply translations in the UI.

#### Acceptance Criteria

1. THE Translation_Service SHALL define a translation request format containing the source text and target language code
2. THE Translation_Service SHALL define a translation response format containing the translated text and language code
3. THE Translation_Service SHALL parse Gemini API responses into the translation response format
4. WHEN Gemini returns invalid or unparseable output, THE Translation_Service SHALL log the error and return the original text
5. THE Translation_Service SHALL format translation requests as structured prompts for Gemini
6. FOR ALL valid translation responses, parsing the response then formatting it then parsing again SHALL produce an equivalent translation object (round-trip property)

### Requirement 10: Authentication Error Handling

**User Story:** As a user, I want clear error messages when authentication fails, so that I understand what went wrong and how to fix it.

#### Acceptance Criteria

1. WHEN Firebase Authentication returns an error code, THE Auth_System SHALL map it to a user-friendly error message
2. THE Auth_System SHALL handle the following error codes: user-not-found, wrong-password, email-already-in-use, weak-password, invalid-email, network-request-failed
3. WHEN an unknown error occurs, THE Auth_System SHALL display a generic error message with the error code
4. THE Login_Screen SHALL display authentication errors below the login button
5. THE Register_Screen SHALL display registration errors below the register button

### Requirement 11: Session Persistence

**User Story:** As a user, I want to remain logged in after closing the app, so that I don't have to re-enter my credentials every time.

#### Acceptance Criteria

1. THE Auth_System SHALL persist the Firebase Authentication session using Firebase SDK default persistence
2. WHEN the app starts, THE Auth_System SHALL check for an existing Firebase Authentication session
3. WHEN a valid session exists, THE Auth_System SHALL restore the user state and navigate to the appropriate dashboard
4. WHEN no valid session exists, THE Auth_System SHALL navigate to the Login_Screen
5. THE Auth_System SHALL store the user's role and preferred language in local storage for offline access

### Requirement 12: Language Persistence

**User Story:** As a user, I want my language preference saved, so that the app remembers my choice across sessions.

#### Acceptance Criteria

1. THE Translation_Service SHALL save the selected language code to Firestore preferredLanguage field
2. THE Translation_Service SHALL save the selected language code to local Hive storage
3. WHEN the app starts, THE Translation_Service SHALL load the preferred language from local storage first
4. WHEN local storage has no language preference, THE Translation_Service SHALL load the preferred language from Firestore
5. WHEN both local and Firestore have no language preference, THE Translation_Service SHALL default to English (en)
6. WHEN the user changes their language preference, THE Translation_Service SHALL update both Firestore and local storage

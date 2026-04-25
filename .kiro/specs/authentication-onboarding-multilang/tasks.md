# Implementation Plan: Authentication, Onboarding, and Multi-Language Support

## Overview

This implementation plan covers the complete authentication system, first-time user onboarding flow, and multi-language support for the Klaro Flutter app. The implementation replaces the current demo login with Firebase Authentication, implements role-based navigation, provides language selection during onboarding, and integrates Gemini-powered translation for static UI text across nine Philippine languages.

The implementation follows a phased approach: authentication infrastructure first, then onboarding flow, then translation services, and finally UI integration with comprehensive testing throughout.

## Tasks

- [x] 1. Set up enhanced data models and Firestore structure
  - Update AppUser model to include isFirstLogin and preferredLanguage fields
  - Create UserProfile model for Firestore documents
  - Create TranslationRequest and TranslationResponse models
  - Create TranslationCacheEntry model for local caching
  - Create LanguagePreference model
  - Create SupportedLanguage enum with all 9 Philippine languages
  - _Requirements: 4.2, 4.3, 4.4, 4.5, 4.6, 7.1, 7.2, 9.1, 9.2_

- [ ]\* 1.1 Write property test for user document structure
  - **Property 3: User Document Structure Completeness**
  - **Validates: Requirements 4.2, 4.3, 4.4, 4.5, 4.6**
  - Generate random users with various field values
  - Assert all required fields (uid, email, role, isFirstLogin, preferredLanguage) are present with valid values
  - Tag: `// Feature: authentication-onboarding-multilang, Property 3: User Document Structure Completeness`

- [ ]\* 1.2 Write property test for translation format validity
  - **Property 8: Translation Request/Response Format Validity**
  - **Validates: Requirements 9.1, 9.2**
  - Generate random translation requests and responses
  - Assert all required fields are present and non-empty
  - Tag: `// Feature: authentication-onboarding-multilang, Property 8: Translation Request/Response Format Validity`

- [ ]\* 1.3 Write property test for translation round-trip preservation
  - **Property 9: Translation Round-Trip Preservation**
  - **Validates: Requirements 9.6**
  - Generate random translation responses
  - Assert parse(format(parse(response))) == parse(response)
  - Tag: `// Feature: authentication-onboarding-multilang, Property 9: Translation Round-Trip Preservation`

- [x] 2. Implement Firestore Service
  - Create FirestoreService class in lib/services/firestore_service.dart
  - Implement createUserProfile method to create user documents in Firestore
  - Implement getUserProfile method to fetch user documents by UID
  - Implement updateUserProfile method for updating user fields
  - Implement updateLanguagePreference method
  - Implement completeFirstLogin method to set isFirstLogin=false
  - Add error handling with FirestoreErrorHandler
  - _Requirements: 4.1, 4.2, 4.7, 6.4, 6.5, 7.4, 12.1_

- [ ]\* 2.1 Write unit tests for Firestore Service
  - Test user profile creation with all required fields
  - Test user profile retrieval with valid UID
  - Test user profile updates
  - Test language preference updates
  - Test first login flag updates
  - Test error handling for missing documents
  - Use mocked Firestore for all tests

- [x] 3. Enhance Auth Service with Firestore integration
  - Update AuthService in lib/services/auth_service.dart
  - Implement signIn method that authenticates with Firebase and fetches Firestore profile
  - Implement signUp method that creates both Firebase Auth account and Firestore profile
  - Implement signOut method that clears session and local storage
  - Implement getCurrentUser method that checks Firebase Auth and Firestore
  - Add authStateChanges stream for reactive auth state
  - Implement AuthErrorHandler with all Firebase error code mappings
  - Update LocalStorageService to save/load AppUser with new fields
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 2.8, 2.9, 10.1, 10.2, 10.3, 11.1, 11.2, 11.5_

- [ ]\* 3.1 Write property test for error code mapping completeness
  - **Property 10: Error Code Mapping Completeness**
  - **Validates: Requirements 1.3, 10.1, 10.3**
  - Generate random Firebase error codes
  - Assert all map to non-empty, user-friendly messages
  - Tag: `// Feature: authentication-onboarding-multilang, Property 10: Error Code Mapping Completeness`

- [ ]\* 3.2 Write unit tests for Auth Service
  - Test successful sign-in with valid credentials
  - Test sign-in failure with invalid credentials
  - Test sign-up with valid data
  - Test sign-up with duplicate email
  - Test error message mapping for all Firebase error codes
  - Test session persistence after app restart
  - Test sign-out clears local session
  - Use mocked Firebase Auth and Firestore

- [x] 4. Implement Seeder Service for test accounts
  - Create SeederService class in lib/services/seeder_service.dart
  - Implement seedTestAccounts method that creates teacher@test.com and student@test.com
  - Implement \_createTestAccount method for individual account creation
  - Implement \_accountExists method to check if account already exists
  - Add logging for seeding results
  - Integrate seeder with app initialization in main.dart (development mode only)
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_

- [ ]\* 4.1 Write property test for seeder idempotence
  - **Property 5: Seeder Idempotence**
  - **Validates: Requirements 3.4, 3.5**
  - Generate random number of seeder executions (1-10)
  - Assert test accounts are created exactly once
  - Tag: `// Feature: authentication-onboarding-multilang, Property 5: Seeder Idempotence`

- [ ]\* 4.2 Write integration tests for Seeder Service
  - Test first run creates accounts in Firebase Auth and Firestore
  - Test second run skips existing accounts
  - Test error handling for Firebase failures
  - Test logging of seeding results
  - Use Firebase test project

- [x] 5. Checkpoint - Ensure authentication tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. Update existing Login Screen with Firestore integration
  - Update LoginScreen in lib/screens/login_screen.dart to integrate with Firestore
  - Keep existing email/password fields and quick demo login buttons
  - Update \_navigateToHome method to check isFirstLogin flag from Firestore
  - If isFirstLogin is true, navigate to Language Selector screen
  - If isFirstLogin is false, navigate to existing role-based dashboard (TeacherDashboardScreen or StudentHomeScreen)
  - Update error message display to show Firestore errors
  - Ensure quick demo login buttons work with new Firestore integration
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 10.4_

- [ ]\* 6.1 Write property test for error message display
  - **Property 2: Error Message Display Completeness**
  - **Validates: Requirements 2.7**
  - Generate random error messages (non-empty strings)
  - Assert error message displayed in UI without modification
  - Tag: `// Feature: authentication-onboarding-multilang, Property 2: Error Message Display Completeness`

- [ ]\* 6.2 Write widget tests for updated Login Screen
  - Test email and password fields are present
  - Test login button triggers authentication
  - Test error messages displayed correctly
  - Test quick demo login buttons work
  - Test navigation to language selector for first-time users
  - Test navigation to dashboard for returning users

- [x] 7. Checkpoint - Ensure authentication UI tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 10. Create Language Selector Screen
  - Create LanguageSelectorScreen in lib/screens/language_selector_screen.dart
  - Display all 9 Philippine languages (English, Tagalog, Cebuano, Ilocano, Hiligaynon, Waray, Kapampangan, Bikol, Pangasinan)
  - Implement language selection UI (grid or list layout)
  - Add visual indicator for currently selected language
  - Add confirmation button to save language preference
  - Call FirestoreService.updateLanguagePreference on confirmation
  - Call LocalStorageService to save language to Hive
  - Navigate to TeacherDashboardScreen for teachers or StudentHomeScreen for students after confirmation
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.7_
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.7_

- [ ]\* 10.1 Write widget tests for Language Selector Screen
  - Test all 9 languages are displayed
  - Test language selection updates UI
  - Test confirmation button enabled after selection
  - Test navigation after confirmation

- [x] 11. Implement Onboarding Flow Manager
  - Create OnboardingFlowManager in lib/services/onboarding_flow_manager.dart
  - Implement shouldShowOnboarding method that checks isFirstLogin field
  - Implement navigateAfterLogin method that routes based on isFirstLogin
  - Implement completeOnboarding method that updates Firestore and navigates
  - Integrate with AuthService to trigger onboarding after successful login
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ]\* 11.1 Write property test for onboarding navigation logic
  - **Property 6: Onboarding Navigation Logic**
  - **Validates: Requirements 6.2, 6.3**
  - Generate random users with isFirstLogin true/false
  - Assert navigation matches isFirstLogin state
  - Tag: `// Feature: authentication-onboarding-multilang, Property 6: Onboarding Navigation Logic`

- [ ]\* 11.2 Write integration tests for Onboarding Flow
  - Test first-time user navigates to language selector
  - Test returning user skips to dashboard
  - Test language selection updates Firestore and Hive
  - Test role-based navigation after onboarding
  - Use Firebase test project

- [x] 12. Checkpoint - Ensure onboarding tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 13. Implement Translation Service core infrastructure
  - Create TranslationService class in lib/services/translation_service.dart
  - Implement initialize method to load user's preferred language
  - Implement translate method for single text translation
  - Implement translateBatch method for multiple strings
  - Implement getCachedTranslation method for cache lookups
  - Implement cacheTranslation method to save to memory and Hive
  - Implement setPreferredLanguage method
  - Implement getPreferredLanguage method
  - Create in-memory cache (Map<String, String>)
  - Open Hive box for translation_cache
  - _Requirements: 8.1, 8.9, 8.10, 12.2, 12.3, 12.4, 12.5_

- [ ]\* 13.1 Write unit tests for Translation Service
  - Test cache key generation
  - Test request/response parsing
  - Test fallback logic
  - Test language preference loading priority
  - Use mocked Gemini API

- [x] 14. Implement Gemini API integration for translations
  - Update GeminiService or create GeminiTranslationClient in lib/services/gemini_service.dart
  - Implement \_buildTranslationPrompt method with proper prompt template
  - Implement API call to Gemini with translation request
  - Implement response parsing to extract translated text
  - Add error handling with TranslationErrorHandler
  - Implement fallback to original text on error
  - _Requirements: 8.3, 8.4, 8.5, 8.8, 9.3, 9.4_

- [ ]\* 14.1 Write property test for translation cache efficiency
  - **Property 7: Translation Cache Efficiency**
  - **Validates: Requirements 8.5, 8.6**
  - Generate random translation requests (some repeated)
  - Assert cached translations don't call API, new translations do
  - Tag: `// Feature: authentication-onboarding-multilang, Property 7: Translation Cache Efficiency`

- [ ]\* 14.2 Write property test for translation error fallback
  - **Property 12: Translation Error Fallback**
  - **Validates: Requirements 8.8, 9.4**
  - Generate random translation errors
  - Assert original text displayed, no crash
  - Tag: `// Feature: authentication-onboarding-multilang, Property 12: Translation Error Fallback`

- [ ]\* 14.3 Write integration tests for Translation Service
  - Test language selection calls Gemini API
  - Test translation caching (subsequent requests use cache)
  - Test translation error falls back to English
  - Test app restart restores language preference
  - Use real Gemini API with test project

- [x] 15. Implement language preference persistence
  - Update LocalStorageService to save/load language preference to Hive
  - Implement language preference loading on app startup
  - Implement priority: local storage first, then Firestore, then default to English
  - Update TranslationService to sync language preference between Firestore and Hive
  - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6_

- [ ]\* 15.1 Write property test for language preference persistence
  - **Property 11: Language Preference Persistence**
  - **Validates: Requirements 7.5, 12.2, 12.6**
  - Generate random language codes
  - Assert language saved to both Firestore and Hive
  - Tag: `// Feature: authentication-onboarding-multilang, Property 11: Language Preference Persistence`

- [x] 16. Checkpoint - Ensure translation service tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 17. Create TranslatableText widget for UI integration
  - Create TranslatableText widget in lib/widgets/translatable_text.dart
  - Implement FutureBuilder to fetch translation asynchronously
  - Implement fallback to original text while loading
  - Add support for TextStyle parameter
  - Integrate with TranslationService
  - _Requirements: 8.6, 8.7, 8.10_

- [ ]\* 17.1 Write widget tests for TranslatableText
  - Test widget displays original text while loading
  - Test widget displays translated text after loading
  - Test widget falls back to original text on error
  - Test widget respects TextStyle parameter

- [x] 18. Integrate translations into Login Screen
  - Update LoginScreen to use TranslatableText for all static UI text
  - Translate labels: "Email", "Password", "Login", "Don't have an account? Register"
  - Translate error messages using TranslationService
  - Test translation updates immediately when language changes
  - _Requirements: 8.7, 8.10_

- [ ]\* 18.1 Write integration tests for translated Login Screen
  - Test Login Screen displays English by default
  - Test Login Screen updates to Tagalog when language changed
  - Test all static text is translated
  - Test error messages are translated

- [x] 19. Update session persistence and restoration
  - Update main.dart to check for existing Firebase Auth session on startup
  - Implement session restoration that loads user from Firestore
  - Implement navigation to appropriate dashboard when session exists
  - Implement navigation to Login Screen when no session exists
  - Load language preference from local storage on startup
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

- [ ]\* 19.1 Write integration tests for session persistence
  - Test app restart restores session
  - Test app restart navigates to dashboard
  - Test app restart with no session navigates to login
  - Test language preference persists across restarts
  - Use Firebase test project

- [x] 20. Final integration and end-to-end testing
  - Test complete new user journey: register → onboarding → language selection → dashboard
  - Test complete returning user journey: login → skip onboarding → dashboard
  - Test language change journey: settings → change language → UI updates → restart → language persisted
  - Test offline mode journey: offline → cached translations → online → new translations
  - Test seeder service creates test accounts on first run
  - Test all error handling paths
  - _Requirements: All requirements_

- [ ]\* 20.1 Write end-to-end tests
  - Test new user registration flow
  - Test returning user login flow
  - Test language change flow
  - Test offline mode with cached translations
  - Use Firebase test project and real Gemini API

- [x] 21. Final checkpoint - Ensure all tests pass
  - Run all unit tests, property tests, widget tests, integration tests, and end-to-end tests
  - Verify code coverage meets target (>80%)
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at reasonable breaks
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- Integration tests validate interactions with Firebase and Gemini API
- The implementation uses Dart/Flutter as specified in the design document
- Firebase test project should be used for all integration and end-to-end tests
- Test accounts (teacher@test.com, student@test.com) are created by the seeder service
- All property tests must run at least 100 iterations
- Translation service only translates static UI text, not dynamic content from Firestore
- **No Register Screen is needed** - the existing Login Screen will be enhanced with Firestore integration
- **Navigation targets**: Teachers go to TeacherDashboardScreen, Students go to StudentHomeScreen
- **Quick demo login buttons** remain functional and work with the new Firestore integration
- **First-time login flow**: Login → Check isFirstLogin → If true, show Language Selector → Navigate to dashboard

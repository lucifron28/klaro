# Requirements Document

## Introduction

This document specifies the requirements for transforming the existing "Klaro AI Tutor" into "Klaro AI Assessment" - a conversation-based assessment system that evaluates student understanding through AI-powered dialogue. The system will track correct and incorrect answers, store results in Firestore, and provide a comprehensive progress tracking interface.

## Glossary

- **Assessment_System**: The Klaro AI Assessment feature that conducts conversation-based evaluations
- **Conversation_Engine**: The AI-powered component that asks questions and evaluates student responses
- **Firestore_Service**: The service that handles all Firebase Firestore database operations
- **Progress_Tracker**: The component that displays historical assessment and quiz results
- **Recap_Manager**: The component that manages and displays learned concepts with recent-first ordering
- **Score_Calculator**: The component that calculates scores in correct-answers/attempts format
- **Result_Record**: A stored assessment or quiz result containing score, timestamp, and metadata
- **My_Progress_Tab**: The UI tab that displays all historical results and learned concepts

## Requirements

### Requirement 1: AI Conversation-Based Assessment

**User Story:** As a student, I want to have a conversation with the AI that tracks my correct and incorrect answers, so that I can demonstrate my understanding and receive a fair assessment.

#### Acceptance Criteria

1. THE Conversation_Engine SHALL distinguish between student questions or clarifications and actual answer attempts
2. WHEN a student asks a question or requests clarification, THE Conversation_Engine SHALL respond without evaluating or scoring the message
3. WHEN a student provides an answer attempt, THE Conversation_Engine SHALL evaluate the answer as correct or incorrect
4. THE Score_Calculator SHALL track only actual answer attempts in the format "correct-ans/attempts"
5. THE Conversation_Engine SHALL not increment the attempts counter for student questions or clarifications
6. WHEN a student reaches 3 correct answers, THE Assessment_System SHALL end the conversation with a success message
7. THE Assessment_System SHALL display a message directing students to view results in the My_Progress_Tab after 3 correct answers
8. WHEN a student provides 3 incorrect answers, THE Assessment_System SHALL end the conversation with a suggestion to review the lesson and retake the quiz
9. THE Assessment_System SHALL provide an option to retake the assessment after 3 incorrect answers
10. FOR ALL assessment conversations, THE Conversation_Engine SHALL maintain a history of all questions asked and answers provided

### Requirement 2: Firestore Data Persistence

**User Story:** As a student, I want my assessment results stored in the cloud, so that I can access my progress from any device and my data is preserved.

#### Acceptance Criteria

1. THE Firestore_Service SHALL store quiz results with fields: lessonId, lessonTitle, schoolSubject, topic, score, total, percentage, timestamp, and questionResults
2. THE Firestore_Service SHALL store AI assessment results with fields: lessonId, lessonTitle, schoolSubject, topic, correctAnswers, totalAttempts, score, summary, timestamp, and conversationMessages
3. WHEN a student completes an assessment for the second time, THE Firestore_Service SHALL replace the previous result for that topic with the new result
4. THE Firestore_Service SHALL organize results under the authenticated user's document path: users/{userId}/assessmentResults/{resultId}
5. THE Firestore_Service SHALL organize quiz results under the path: users/{userId}/quizResults/{resultId}
6. THE Firestore_Service SHALL store recap data under the path: users/{userId}/learnedConcepts/{conceptId}
7. FOR ALL write operations, THE Firestore_Service SHALL include error handling and retry logic for network failures

### Requirement 3: Result Retrieval and Ordering

**User Story:** As a student, I want to see my most recent assessment results first, so that I can quickly review my latest performance.

#### Acceptance Criteria

1. WHEN the My_Progress_Tab is displayed, THE Progress_Tracker SHALL retrieve all results ordered by timestamp descending (most recent first)
2. THE Progress_Tracker SHALL display quiz results and AI assessment results in separate sections
3. THE Progress_Tracker SHALL show the score, topic, subject, and date for each result
4. WHEN a student taps "View Results", THE Progress_Tracker SHALL display the detailed result including all questions and answers
5. WHEN a student taps "Review Again", THE Assessment_System SHALL navigate to the lesson content for that topic
6. THE Progress_Tracker SHALL display a loading indicator while fetching results from Firestore
7. IF no results exist, THE Progress_Tracker SHALL display an empty state message encouraging the student to complete assessments

### Requirement 4: Recap Feature with Recent-First Ordering

**User Story:** As a student, I want to see my recently learned words and definitions first in the recap, so that I can review the most relevant concepts.

#### Acceptance Criteria

1. THE Recap_Manager SHALL order learned concepts by timestamp descending (most recent first)
2. WHEN a student learns a new word or concept, THE Recap_Manager SHALL save it to Firestore with a timestamp
3. THE Recap_Manager SHALL store each concept with fields: word, definition, tagalogTranslation, lessonId, lessonTitle, and timestamp
4. WHEN displaying the recap, THE Recap_Manager SHALL show the most recently learned concepts at the top
5. THE Recap_Manager SHALL allow students to filter concepts by lesson or subject
6. THE Recap_Manager SHALL display the date when each concept was learned

### Requirement 5: UI Rebranding from Tutor to Assessment

**User Story:** As a user, I want the interface to clearly indicate this is an assessment tool, so that I understand the purpose of the AI conversation.

#### Acceptance Criteria

1. THE Assessment_System SHALL display "Klaro AI Assessment" instead of "Klaro AI Tutor" in all UI elements
2. THE Assessment_System SHALL update the app bar title to "Klaro AI Assessment"
3. THE Assessment_System SHALL update all translation files to replace "AI Tutor" with "AI Assessment"
4. THE Assessment_System SHALL update button labels from "Talk to Klaro AI" to "Start Assessment"
5. THE Assessment_System SHALL update the performance summary section title from "AI Tutor Summary" to "AI Assessment Summary"
6. THE Assessment_System SHALL update the GeminiService prompt to identify the AI as "Klaro, your AI Assessment assistant"

### Requirement 6: My Progress Tab Implementation

**User Story:** As a student, I want a dedicated tab to view all my assessment history, so that I can track my learning progress over time.

#### Acceptance Criteria

1. THE Assessment_System SHALL add a "My Progress" tab to the student dashboard navigation
2. THE My_Progress_Tab SHALL display two sections: "Quiz Results" and "AI Assessment Results"
3. WHEN a result is displayed, THE My_Progress_Tab SHALL show action buttons: "View Results" and "Review Again"
4. THE My_Progress_Tab SHALL display results in card format with subject, topic, score, and date
5. THE My_Progress_Tab SHALL support pull-to-refresh to fetch the latest results from Firestore
6. THE My_Progress_Tab SHALL display a visual indicator (icon or badge) for high-scoring results (≥80%)
7. THE My_Progress_Tab SHALL allow students to delete individual results with a confirmation dialog

### Requirement 7: Second Attempt Result Replacement

**User Story:** As a student, I want my second attempt to replace my first attempt's score, so that my progress reflects my improved understanding.

#### Acceptance Criteria

1. WHEN a student completes an assessment for a topic they have previously assessed, THE Firestore_Service SHALL query for existing results with the same lessonId
2. IF an existing result is found, THE Firestore_Service SHALL update that document instead of creating a new one
3. THE Firestore_Service SHALL preserve the original timestamp in a field called "firstAttemptDate"
4. THE Firestore_Service SHALL update the timestamp field to reflect the most recent attempt
5. THE Firestore_Service SHALL increment an "attemptCount" field to track the number of attempts
6. THE My_Progress_Tab SHALL display the attempt count for results with multiple attempts
7. THE My_Progress_Tab SHALL provide an option to view the history of all attempts for a given topic

### Requirement 8: Assessment Success and Failure Messages

**User Story:** As a student, I want clear feedback when I complete an assessment, so that I know whether I should review the material or move forward.

#### Acceptance Criteria

1. WHEN a student achieves 3 correct answers, THE Assessment_System SHALL display a success message: "Great job! You've demonstrated understanding of this topic. View your results in the My Progress tab."
2. WHEN a student provides 3 incorrect answers, THE Assessment_System SHALL display a message: "It looks like this topic needs more review. We recommend reviewing the lesson content and trying again."
3. THE Assessment_System SHALL display the final score in "correct-ans/attempts" format in the completion message
4. THE Assessment_System SHALL provide a "View Results" button that navigates to the My_Progress_Tab
5. THE Assessment_System SHALL provide a "Review Lesson" button that navigates back to the lesson content
6. THE Assessment_System SHALL provide a "Retake Assessment" button that restarts the conversation
7. THE Assessment_System SHALL save the result to Firestore before displaying the completion message

### Requirement 9: Firestore Security and Data Validation

**User Story:** As a developer, I want to ensure that students can only access their own assessment data, so that privacy and security are maintained.

#### Acceptance Criteria

1. THE Firestore_Service SHALL only allow authenticated users to read and write their own data
2. THE Firestore_Service SHALL validate that all required fields are present before writing to Firestore
3. THE Firestore_Service SHALL validate that score values are within expected ranges (0-100 for percentages, positive integers for counts)
4. THE Firestore_Service SHALL validate that timestamps are valid DateTime objects
5. IF authentication fails, THE Firestore_Service SHALL display an error message and prevent data access
6. THE Firestore_Service SHALL log all database errors for debugging purposes
7. THE Firestore_Service SHALL implement Firestore security rules that enforce user-specific data access

### Requirement 10: Offline Support and Data Synchronization

**User Story:** As a student, I want to complete assessments even when offline, so that connectivity issues don't interrupt my learning.

#### Acceptance Criteria

1. WHEN a student completes an assessment while offline, THE Assessment_System SHALL store the result locally using Hive
2. WHEN the device regains connectivity, THE Firestore_Service SHALL automatically synchronize local results to Firestore
3. THE Assessment_System SHALL display a visual indicator when operating in offline mode
4. THE My_Progress_Tab SHALL display locally stored results when offline
5. THE Firestore_Service SHALL handle conflicts when the same assessment is completed offline and online
6. WHEN synchronization completes, THE Assessment_System SHALL display a success notification
7. THE Assessment_System SHALL prioritize Firestore data over local data when both are available and in conflict

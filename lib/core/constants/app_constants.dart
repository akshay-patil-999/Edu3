class AppConstants {
  static const String appName = 'Vedo';
  static const String defaultAvatar = '';
  
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String tuitionsCollection = 'tuitions';
  static const String tasksCollection = 'tasks';
  static const String feedbackCollection = 'feedback';
  static const String studySessionsCollection = 'study_sessions';
  
  // Shared Preferences Keys
  static const String completedTasksKey = 'completed_tasks';
  
  // Tuition Code Length
  static const int tuitionCodeLength = 6;
  
  // Study Timer
  static const int pomodoroDurationMinutes = 25;
}

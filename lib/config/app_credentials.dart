/// Centralized configuration for Firebase, MongoDB Atlas, and external API credentials.
///
/// SECURITY: these values must NEVER be hardcoded/committed. They are read at
/// build time via --dart-define-from-file=secrets.json (which stays out of git).
///
/// The credential that used to be hardcoded here was already pushed to a
/// public repo and MUST be rotated in MongoDB Atlas immediately.
class AppCredentials {
  static const String firebaseProjectId =
      String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: '');
  static const String firebaseApiKey =
      String.fromEnvironment('FIREBASE_API_KEY', defaultValue: '');
  static const String firebaseAppId =
      String.fromEnvironment('FIREBASE_APP_ID', defaultValue: '');
  static const String firebaseMessagingSenderId =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '');

  static const String mongoDbUri =
      String.fromEnvironment('MONGODB_URI', defaultValue: '');
  static const String mongoDbDatabase =
      String.fromEnvironment('MONGODB_DATABASE', defaultValue: 'Safe-Walk');

  static bool get isMongoDbConfigured =>
      mongoDbUri.isNotEmpty && mongoDbUri.contains('mongodb+srv://');

  static bool get isFirebaseConfigured =>
      firebaseApiKey.isNotEmpty && firebaseApiKey.startsWith('AIzaSy');
}

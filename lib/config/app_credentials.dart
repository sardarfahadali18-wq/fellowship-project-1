/// Centralized configuration for Firebase, MongoDB Atlas, and external API credentials.
class AppCredentials {
  // ==================== FIREBASE CONFIGURATION ====================
  static const String firebaseProjectId = 'safe-walk-d2c51';
  static const String firebaseApiKey = 'AIzaSyDMfH4SWl0DpFQtLWsb6aW2hQlUR6jfX4I';
  static const String firebaseAppId = '1:118818940478:android:a60079ed3c043f1c34d36f';
  static const String firebaseMessagingSenderId = '118818940478';

  // ==================== MONGODB ATLAS CONFIGURATION ====================
  static const String mongoDbUri =
      'mongodb+srv://hafizmfaizanali26688_db_user:WmwjzJwYxLMttUPV@cluster0.jevboec.mongodb.net/Safe-Walk?appName=Cluster0';
  static const String mongoDbDatabase = 'Safe-Walk';

  /// Check if live MongoDB Atlas credentials have been configured
  static bool get isMongoDbConfigured =>
      mongoDbUri.isNotEmpty && mongoDbUri.contains('mongodb+srv://');

  /// Check if live Firebase API keys have been set
  static bool get isFirebaseConfigured =>
      firebaseApiKey.isNotEmpty && firebaseApiKey.startsWith('AIzaSy');
}

/// Defaults for local persistence.
abstract final class PersistenceDefaults {
  /// How long startup waits for the database to load.
  static const Duration loadTimeout = Duration(seconds: 10);

  /// Delay between failed persistence attempts.
  static const Duration retryDelay = Duration(milliseconds: 200);

  /// Number of attempts before a failure is reported.
  static const int maxAttempts = 3;
}

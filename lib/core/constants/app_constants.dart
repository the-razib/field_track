/// Application-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'FieldTrack';

  // ─── Storage keys ─────────────────────────────────────────────
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String enteredGeofencesKey = 'entered_geofences';

  // ─── Database ─────────────────────────────────────────────────
  static const String databaseName = 'field_track.db';
  static const int databaseVersion = 1;

  // ─── Geofence ─────────────────────────────────────────────────
  /// Multiplier applied to radius to determine "exit" (e.g., 1.2x)
  static const double geofenceExitMultiplier = 1.2;

  /// Minimum distance change (meters) before location update triggers
  static const int locationDistanceFilter = 50;

  // ─── Sync ─────────────────────────────────────────────────────
  /// Max retry attempts for sync
  static const int maxSyncRetries = 3;

  /// Delay between retries in seconds (multiplied by attempt number)
  static const int syncRetryBaseDelay = 2;
}

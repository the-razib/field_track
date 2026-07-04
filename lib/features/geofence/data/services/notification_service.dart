import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Handle tap here if needed
      },
    );

    // Android 13+ (API 33) requires an explicit runtime permission request,
    // otherwise notifications are silently suppressed.
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showEntryNotification(String locationName) async {
    const androidDetails = AndroidNotificationDetails(
      'geofence_channel_id',
      'Geofence Notifications',
      channelDescription: 'Notifications triggered when entering locations',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Use a stable id derived from the location name so each geofence gets its
    // own notification instead of overwriting the previous one (DateTime.millisecond
    // is only 0–999 and collides frequently).
    final notificationId = locationName.hashCode & 0x7fffffff;

    await _notificationsPlugin.show(
      id: notificationId,
      title: 'Location Entered',
      body: 'You entered $locationName',
      notificationDetails: details,
    );
  }
}

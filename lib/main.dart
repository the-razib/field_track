import 'package:flutter/material.dart';
import 'package:field_track/app/app.dart';
import 'package:field_track/app/di/injection_container.dart';
import 'package:field_track/features/geofence/data/services/geofence_service.dart';
import 'package:field_track/features/geofence/data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize DI Container
  await initDependencies();

  // 2. Initialize Local Notifications (must not block app startup)
  try {
    await NotificationService.init();
  } catch (e, s) {
    debugPrint('NotificationService.init failed: $e\n$s');
  }

  // 3. Start Background/Foreground Geofence Monitoring (fire-and-forget)
  try {
    sl<GeofenceService>().startMonitoring();
  } catch (e, s) {
    debugPrint('GeofenceService.startMonitoring failed: $e\n$s');
  }

  // 4. Run App
  runApp(const MyApp());
}

import 'package:flutter/material.dart';
import 'package:field_track/app/app.dart';
import 'package:field_track/app/di/injection_container.dart';
import 'package:field_track/features/geofence/data/services/geofence_service.dart';
import 'package:field_track/features/geofence/data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize DI Container
  await initDependencies();

  // 2. Initialize Local Notifications
  await NotificationService.init();

  // 3. Start Background/Foreground Geofence Monitoring
  sl<GeofenceService>().startMonitoring();

  // 4. Run App
  runApp(const MyApp());
}

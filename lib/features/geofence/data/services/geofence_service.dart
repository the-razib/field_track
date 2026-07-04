import 'dart:async';
import 'package:geolocator/geolocator.dart';

import 'package:field_track/features/locations/domain/repositories/location_repository.dart';
import 'package:field_track/features/geofence/data/services/notification_service.dart';

class GeofenceService {
  final LocationRepository _locationRepository;
  StreamSubscription<Position>? _positionSubscription;
  final Set<String> _currentlyInside = {};

  GeofenceService({required LocationRepository locationRepository})
      : _locationRepository = locationRepository;

  Future<void> startMonitoring() async {
    // 1. Request permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return;
    }

    // 2. Cancel any existing stream
    await stopMonitoring();

    // 3. Configure location settings (battery efficient)
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 30, // Trigger every 30 meters
    );

    // 4. Start listening
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _evaluateGeofences(position);
    });
  }

  Future<void> stopMonitoring() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _currentlyInside.clear();
  }

  Future<void> _evaluateGeofences(Position position) async {
    final result = await _locationRepository.getLocations();
    result.fold(
      (failure) => null, // Ignore fetch failures
      (locations) {
        final activeLocations = locations.where((l) => l.isActive).toList();

        for (final loc in activeLocations) {
          final distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            loc.latitude,
            loc.longitude,
          );

          final isInside = distance <= loc.radiusM;
          final wasInside = _currentlyInside.contains(loc.id);

          if (isInside && !wasInside) {
            // Entered geofence! Trigger notification
            _currentlyInside.add(loc.id);
            NotificationService.showEntryNotification(loc.locationName);
          } else if (!isInside && wasInside) {
            // Exited geofence with buffer (1.2x radius) to avoid border flickering
            if (distance > loc.radiusM * 1.2) {
              _currentlyInside.remove(loc.id);
            }
          }
        }
      },
    );
  }
}

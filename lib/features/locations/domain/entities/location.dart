import 'package:equatable/equatable.dart';

/// Domain entity for a geofence location.
class GeoLocation extends Equatable {
  final String id;
  final String locationName;
  final double latitude;
  final double longitude;
  final double radiusM;
  final bool isActive;

  const GeoLocation({
    required this.id,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.radiusM,
    this.isActive = true,
  });

  GeoLocation copyWith({
    String? id,
    String? locationName,
    double? latitude,
    double? longitude,
    double? radiusM,
    bool? isActive,
  }) {
    return GeoLocation(
      id: id ?? this.id,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusM: radiusM ?? this.radiusM,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Format coordinates as "lat, lng" for display.
  String get formattedCoordinates =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  /// Format radius for display (e.g., "150 m radius").
  String get formattedRadius => '${radiusM.toInt()} m radius';

  @override
  List<Object?> get props =>
      [id, locationName, latitude, longitude, radiusM, isActive];
}

import 'package:field_track/features/locations/domain/entities/location.dart';

/// Data model for GeoLocation — handles JSON serialization.
class LocationModel extends GeoLocation {
  const LocationModel({
    required super.id,
    required super.locationName,
    required super.latitude,
    required super.longitude,
    required super.radiusM,
    super.isActive,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      locationName: json['location_name'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      radiusM: (json['radius_m'] as num?)?.toDouble() ?? 100.0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'radius_m': radiusM,
      'is_active': isActive,
    };
  }
}

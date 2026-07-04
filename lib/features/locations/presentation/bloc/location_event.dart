import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();
  @override
  List<Object?> get props => [];
}

class LocationsFetchRequested extends LocationEvent {
  const LocationsFetchRequested();
}

class LocationAddRequested extends LocationEvent {
  final String locationName;
  final double latitude;
  final double longitude;
  final double radiusM;
  final bool isActive;

  const LocationAddRequested({
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.radiusM,
    this.isActive = true,
  });

  @override
  List<Object?> get props =>
      [locationName, latitude, longitude, radiusM, isActive];
}

class LocationUpdateRequested extends LocationEvent {
  final String id;
  final String locationName;
  final double latitude;
  final double longitude;
  final double radiusM;
  final bool isActive;

  const LocationUpdateRequested({
    required this.id,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.radiusM,
    required this.isActive,
  });

  @override
  List<Object?> get props =>
      [id, locationName, latitude, longitude, radiusM, isActive];
}

class LocationDeleteRequested extends LocationEvent {
  final String id;
  const LocationDeleteRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

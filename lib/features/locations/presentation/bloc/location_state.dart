import 'package:equatable/equatable.dart';

import 'package:field_track/features/locations/domain/entities/location.dart';

abstract class LocationState extends Equatable {
  const LocationState();
  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationLoaded extends LocationState {
  final List<GeoLocation> locations;
  const LocationLoaded({required this.locations});

  @override
  List<Object?> get props => [locations];
}

class LocationActionSuccess extends LocationState {
  final String message;
  const LocationActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class LocationError extends LocationState {
  final String message;
  const LocationError({required this.message});

  @override
  List<Object?> get props => [message];
}

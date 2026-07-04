import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:field_track/core/error/failures.dart';
import 'package:field_track/core/usecases/usecase.dart';
import 'package:field_track/features/locations/domain/entities/location.dart';
import 'package:field_track/features/locations/domain/repositories/location_repository.dart';

class UpdateLocationUseCase extends UseCase<GeoLocation, UpdateLocationParams> {
  final LocationRepository repository;
  UpdateLocationUseCase(this.repository);

  @override
  Future<Either<Failure, GeoLocation>> call(UpdateLocationParams params) {
    return repository.updateLocation(
      id: params.id,
      locationName: params.locationName,
      latitude: params.latitude,
      longitude: params.longitude,
      radiusM: params.radiusM,
      isActive: params.isActive,
    );
  }
}

class UpdateLocationParams extends Equatable {
  final String id;
  final String locationName;
  final double latitude;
  final double longitude;
  final double radiusM;
  final bool isActive;

  const UpdateLocationParams({
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

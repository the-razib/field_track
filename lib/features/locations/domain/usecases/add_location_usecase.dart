import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:field_track/core/error/failures.dart';
import 'package:field_track/core/usecases/usecase.dart';
import 'package:field_track/features/locations/domain/entities/location.dart';
import 'package:field_track/features/locations/domain/repositories/location_repository.dart';

class AddLocationUseCase extends UseCase<GeoLocation, AddLocationParams> {
  final LocationRepository repository;
  AddLocationUseCase(this.repository);

  @override
  Future<Either<Failure, GeoLocation>> call(AddLocationParams params) {
    return repository.addLocation(
      locationName: params.locationName,
      latitude: params.latitude,
      longitude: params.longitude,
      radiusM: params.radiusM,
      isActive: params.isActive,
    );
  }
}

class AddLocationParams extends Equatable {
  final String locationName;
  final double latitude;
  final double longitude;
  final double radiusM;
  final bool isActive;

  const AddLocationParams({
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

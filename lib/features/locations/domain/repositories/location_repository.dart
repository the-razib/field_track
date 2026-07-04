import 'package:dartz/dartz.dart';

import 'package:field_track/core/error/failures.dart';
import 'package:field_track/features/locations/domain/entities/location.dart';

/// Location repository contract.
abstract class LocationRepository {
  Future<Either<Failure, List<GeoLocation>>> getLocations();

  Future<Either<Failure, GeoLocation>> addLocation({
    required String locationName,
    required double latitude,
    required double longitude,
    required double radiusM,
    bool isActive = true,
  });

  Future<Either<Failure, GeoLocation>> updateLocation({
    required String id,
    required String locationName,
    required double latitude,
    required double longitude,
    required double radiusM,
    required bool isActive,
  });

  Future<Either<Failure, void>> deleteLocation(String id);
}

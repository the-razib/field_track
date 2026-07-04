import 'package:dartz/dartz.dart';

import 'package:field_track/core/error/error_mapper.dart';
import 'package:field_track/core/error/failures.dart';
import 'package:field_track/core/network/connectivity_service.dart';
import 'package:field_track/features/locations/domain/entities/location.dart';
import 'package:field_track/features/locations/domain/repositories/location_repository.dart';
import 'package:field_track/features/locations/data/datasources/location_remote_data_source.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;

  LocationRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, List<GeoLocation>>> getLocations() async {
    if (!await connectivityService.isOnline) {
      return const Left(NetworkFailure());
    }
    try {
      final locations = await remoteDataSource.getLocations();
      return Right(locations);
    } catch (e) {
      return Left(mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, GeoLocation>> addLocation({
    required String locationName,
    required double latitude,
    required double longitude,
    required double radiusM,
    bool isActive = true,
  }) async {
    if (!await connectivityService.isOnline) {
      return const Left(NetworkFailure());
    }
    try {
      final location = await remoteDataSource.addLocation({
        'location_name': locationName,
        'latitude': latitude,
        'longitude': longitude,
        'radius_m': radiusM,
      });
      return Right(location);
    } catch (e) {
      return Left(mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, GeoLocation>> updateLocation({
    required String id,
    required String locationName,
    required double latitude,
    required double longitude,
    required double radiusM,
    required bool isActive,
  }) async {
    if (!await connectivityService.isOnline) {
      return const Left(NetworkFailure());
    }
    try {
      final location = await remoteDataSource.updateLocation(id, {
        'location_name': locationName,
        'latitude': latitude,
        'longitude': longitude,
        'radius_m': radiusM,
        'is_active': isActive,
      });
      return Right(location);
    } catch (e) {
      return Left(mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLocation(String id) async {
    if (!await connectivityService.isOnline) {
      return const Left(NetworkFailure());
    }
    try {
      await remoteDataSource.deleteLocation(id);
      return const Right(null);
    } catch (e) {
      return Left(mapErrorToFailure(e));
    }
  }
}

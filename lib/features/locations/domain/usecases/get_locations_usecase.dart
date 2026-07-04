import 'package:dartz/dartz.dart';

import 'package:field_track/core/error/failures.dart';
import 'package:field_track/core/usecases/usecase.dart';
import 'package:field_track/features/locations/domain/entities/location.dart';
import 'package:field_track/features/locations/domain/repositories/location_repository.dart';

class GetLocationsUseCase extends UseCase<List<GeoLocation>, NoParams> {
  final LocationRepository repository;
  GetLocationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<GeoLocation>>> call(NoParams params) {
    return repository.getLocations();
  }
}

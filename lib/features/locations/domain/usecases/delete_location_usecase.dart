import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:field_track/core/error/failures.dart';
import 'package:field_track/core/usecases/usecase.dart';
import 'package:field_track/features/locations/domain/repositories/location_repository.dart';

class DeleteLocationUseCase extends UseCase<void, DeleteLocationParams> {
  final LocationRepository repository;
  DeleteLocationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteLocationParams params) {
    return repository.deleteLocation(params.id);
  }
}

class DeleteLocationParams extends Equatable {
  final String id;
  const DeleteLocationParams({required this.id});

  @override
  List<Object?> get props => [id];
}

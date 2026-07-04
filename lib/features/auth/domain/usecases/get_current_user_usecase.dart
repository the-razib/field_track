import 'package:dartz/dartz.dart';

import 'package:field_track/core/error/failures.dart';
import 'package:field_track/core/usecases/usecase.dart';
import 'package:field_track/features/auth/domain/entities/user.dart';
import 'package:field_track/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase extends UseCase<User, NoParams> {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return repository.getCurrentUser();
  }
}

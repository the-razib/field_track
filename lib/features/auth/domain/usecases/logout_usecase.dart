import 'package:dartz/dartz.dart';

import 'package:field_track/core/error/failures.dart';
import 'package:field_track/core/usecases/usecase.dart';
import 'package:field_track/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase extends UseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.logout();
  }
}

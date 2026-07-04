import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:field_track/core/error/failures.dart';
import 'package:field_track/core/usecases/usecase.dart';
import 'package:field_track/features/auth/domain/entities/auth_token.dart';
import 'package:field_track/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase extends UseCase<AuthToken, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, AuthToken>> call(RegisterParams params) {
    return repository.register(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
    );
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String fullName;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.fullName,
  });

  @override
  List<Object?> get props => [email, password, fullName];
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:field_track/core/error/failures.dart';
import 'package:field_track/core/usecases/usecase.dart';
import 'package:field_track/features/auth/domain/entities/auth_token.dart';
import 'package:field_track/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase extends UseCase<AuthToken, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, AuthToken>> call(LoginParams params) {
    return repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

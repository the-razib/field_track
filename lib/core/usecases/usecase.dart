import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:field_track/core/error/failures.dart';

/// Base use case interface for Clean Architecture.
///
/// Every use case takes [Params] and returns [Either<Failure, Output>].
abstract class UseCase<Output, Params> {
  Future<Either<Failure, Output>> call(Params params);
}

/// Use when a use case takes no parameters.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}

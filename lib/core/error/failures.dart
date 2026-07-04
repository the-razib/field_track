import 'package:equatable/equatable.dart';

/// Base failure class — all domain-level errors extend this.
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Server returned an error response.
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Network is unavailable.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
  });
}

/// Local storage (SQLite / Secure Storage) error.
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to access local storage.',
  });
}

/// Authentication failure — token expired, invalid credentials, etc.
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

/// Validation failure — input validation errors.
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, fieldErrors];
}

/// Unknown / unexpected error.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred. Please try again.',
  });
}

import 'package:dartz/dartz.dart';

import 'package:field_track/core/error/failures.dart';
import 'package:field_track/features/auth/domain/entities/auth_token.dart';
import 'package:field_track/features/auth/domain/entities/user.dart';

/// Auth repository contract — domain layer depends on this interface.
abstract class AuthRepository {
  /// Login with email and password → returns tokens.
  Future<Either<Failure, AuthToken>> login({
    required String email,
    required String password,
  });

  /// Register a new user → returns tokens.
  Future<Either<Failure, AuthToken>> register({
    required String email,
    required String password,
    required String fullName,
  });

  /// Logout — invalidate tokens server-side and clear local storage.
  Future<Either<Failure, void>> logout();

  /// Get the current authenticated user profile.
  Future<Either<Failure, User>> getCurrentUser();

  /// Check if user has valid stored tokens.
  Future<bool> isAuthenticated();
}

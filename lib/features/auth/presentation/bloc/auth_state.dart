import 'package:equatable/equatable.dart';

import 'package:field_track/features/auth/domain/entities/user.dart';

/// Auth states emitted by [AuthBloc].
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state — before checking auth status.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading — checking tokens, logging in, registering, etc.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated.
class AuthAuthenticated extends AuthState {
  final User? user;

  const AuthAuthenticated({this.user});

  @override
  List<Object?> get props => [user];
}

/// User is not authenticated (no tokens or expired).
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Authentication failed with an error message.
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

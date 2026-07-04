import 'package:equatable/equatable.dart';

/// Auth events dispatched to [AuthBloc].
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check stored tokens on app launch.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Login with email and password.
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Register a new user.
class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.fullName,
  });

  @override
  List<Object?> get props => [email, password, fullName];
}

/// Logout the current user.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

import 'package:equatable/equatable.dart';

/// Domain entity for authentication tokens.
class AuthToken extends Equatable {
  final String accessToken;
  final String refreshToken;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken];
}

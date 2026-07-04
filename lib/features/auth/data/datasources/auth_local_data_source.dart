import 'package:field_track/core/storage/secure_storage.dart';
import 'package:field_track/features/auth/data/models/auth_token_model.dart';

/// Local data source for auth — handles token persistence.
abstract class AuthLocalDataSource {
  Future<void> saveTokens(AuthTokenModel tokens);
  Future<AuthTokenModel?> getTokens();
  Future<void> clearTokens();
  Future<bool> hasTokens();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> saveTokens(AuthTokenModel tokens) async {
    await secureStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
  }

  @override
  Future<AuthTokenModel?> getTokens() async {
    final accessToken = await secureStorage.getAccessToken();
    final refreshToken = await secureStorage.getRefreshToken();

    if (accessToken == null || refreshToken == null) return null;

    return AuthTokenModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<void> clearTokens() async {
    await secureStorage.clearTokens();
  }

  @override
  Future<bool> hasTokens() async {
    return secureStorage.hasTokens();
  }
}

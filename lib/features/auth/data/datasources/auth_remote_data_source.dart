import 'package:field_track/core/constants/api_constants.dart';
import 'package:field_track/core/error/exceptions.dart';
import 'package:field_track/core/network/api_client.dart';
import 'package:field_track/features/auth/data/models/auth_token_model.dart';
import 'package:field_track/features/auth/data/models/user_model.dart';

/// Remote data source for authentication API calls.
abstract class AuthRemoteDataSource {
  Future<AuthTokenModel> login({
    required String email,
    required String password,
  });

  Future<AuthTokenModel> register({
    required String email,
    required String password,
    required String fullName,
  });

  Future<void> logout();

  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthTokenModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      return AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
    } on Exception catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<AuthTokenModel> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
        },
      );

      return AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
    } on Exception catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.dio.post(ApiConstants.logout);
    } on Exception catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await apiClient.dio.get(ApiConstants.me);
      final data = response.data;

      // Handle both { user: {...} } and { ...user fields } formats
      final userData = data is Map<String, dynamic>
          ? (data.containsKey('user') ? data['user'] as Map<String, dynamic> : data)
          : <String, dynamic>{};

      return UserModel.fromJson(userData);
    } on Exception catch (e) {
      throw _handleError(e);
    }
  }

  ServerException _handleError(Exception e) {
    if (e is ServerException) return e;

    // Extract Dio error details
    final message = e.toString();
    return ServerException(message: message);
  }
}

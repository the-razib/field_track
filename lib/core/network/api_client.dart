import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:field_track/core/constants/api_constants.dart';
import 'package:field_track/core/storage/secure_storage.dart';

/// Configured Dio HTTP client with auth interceptor and logging.
class ApiClient {
  late final Dio dio;
  final SecureStorage _secureStorage;

  ApiClient({required SecureStorage secureStorage})
      : _secureStorage = secureStorage {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Auth interceptor — attaches Bearer token + handles 401 refresh
    dio.interceptors.add(_AuthInterceptor(
      dio: dio,
      secureStorage: _secureStorage,
    ));

    // Logging in debug mode
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
        error: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }
  }
}

/// Interceptor that auto-attaches auth tokens and handles token refresh.
class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  final SecureStorage _secureStorage;
  bool _isRefreshing = false;

  _AuthInterceptor({
    required Dio dio,
    required SecureStorage secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for login/register/refresh endpoints
    final noAuthPaths = [
      ApiConstants.login,
      ApiConstants.register,
      ApiConstants.refresh,
      ApiConstants.health,
    ];

    if (!noAuthPaths.contains(options.path)) {
      final token = await _secureStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // If 401 and not already refreshing → attempt token refresh
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      try {
        final refreshToken = await _secureStorage.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          _isRefreshing = false;
          return handler.next(err);
        }

        // Call refresh endpoint with a fresh Dio instance to avoid loops
        final refreshDio = Dio(BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          headers: {'Content-Type': 'application/json'},
        ));

        final response = await refreshDio.post(
          ApiConstants.refresh,
          data: {'refresh_token': refreshToken},
        );

        if (response.statusCode == 200) {
          final newAccessToken = response.data['access_token'] as String?;
          final newRefreshToken = response.data['refresh_token'] as String?;

          if (newAccessToken != null) {
            await _secureStorage.saveAccessToken(newAccessToken);
          }
          if (newRefreshToken != null) {
            await _secureStorage.saveRefreshToken(newRefreshToken);
          }

          // Retry the original request with new token
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newAccessToken';

          final retryResponse = await _dio.fetch(opts);
          _isRefreshing = false;
          return handler.resolve(retryResponse);
        }
      } catch (_) {
        // Refresh failed — clear tokens (force logout)
        await _secureStorage.clearTokens();
      }

      _isRefreshing = false;
    }

    handler.next(err);
  }
}

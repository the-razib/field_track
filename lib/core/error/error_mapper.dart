import 'package:dio/dio.dart';

import 'package:field_track/core/error/exceptions.dart';
import 'package:field_track/core/error/failures.dart';

/// Central place that turns *any* thrown error into a user-friendly [Failure].
///
/// Data sources let [DioException] propagate; repositories call this so the UI
/// only ever sees short, human-readable messages — never a raw Dio stack dump.
Failure mapErrorToFailure(Object error) {
  if (error is Failure) return error;
  if (error is DioException) return _mapDio(error);
  if (error is AuthException) {
    return AuthFailure(message: error.message, statusCode: error.statusCode);
  }
  if (error is NetworkException) {
    return NetworkFailure(message: error.message);
  }
  if (error is CacheException) {
    return CacheFailure(message: error.message);
  }
  if (error is ServerException) {
    return ServerFailure(message: error.message, statusCode: error.statusCode);
  }
  return const UnexpectedFailure();
}

Failure _mapDio(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const NetworkFailure(
        message: 'Connection timed out. Please try again.',
      );
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.badCertificate:
      return const NetworkFailure(
        message: 'Could not establish a secure connection.',
      );
    case DioExceptionType.cancel:
      return const UnexpectedFailure(message: 'Request was cancelled.');
    case DioExceptionType.badResponse:
    case DioExceptionType.unknown:
      return _mapResponse(e);
    default:
      return _mapResponse(e);
  }
}

Failure _mapResponse(DioException e) {
  final status = e.response?.statusCode;
  final serverMessage = _extractServerMessage(e.response?.data);

  // No HTTP response usually means a socket/DNS failure surfaced as `unknown`.
  if (status == null) return const NetworkFailure();

  switch (status) {
    case 400:
    case 422:
      return ValidationFailure(
        message: serverMessage ?? 'Please check your input and try again.',
      );
    case 401:
      return AuthFailure(
        message: serverMessage ??
            'Invalid email or password. Please try again.',
        statusCode: 401,
      );
    case 403:
      return AuthFailure(
        message: serverMessage ?? "You don't have permission to do that.",
        statusCode: 403,
      );
    case 404:
      return ServerFailure(
        message: serverMessage ?? 'The requested item was not found.',
        statusCode: 404,
      );
    case 409:
      return ServerFailure(
        message: serverMessage ?? 'This conflicts with existing data.',
        statusCode: 409,
      );
    case 429:
      return ServerFailure(
        message: serverMessage ?? 'Too many attempts. Please wait a moment.',
        statusCode: 429,
      );
    default:
      if (status >= 500) {
        return ServerFailure(
          message: serverMessage ??
              'Server error. Please try again in a moment.',
          statusCode: status,
        );
      }
      return ServerFailure(
        message: serverMessage ?? 'Something went wrong. Please try again.',
        statusCode: status,
      );
  }
}

/// Pull a clean message out of common error-body shapes:
/// `{ "message": ... }`, `{ "error": ... }`, `{ "detail": ... }`,
/// or `{ "errors": { field: ["..."] } }`.
String? _extractServerMessage(dynamic data) {
  if (data is Map) {
    final direct = data['message'] ?? data['error'] ?? data['detail'];
    if (direct is String && direct.trim().isNotEmpty) return direct.trim();

    final errors = data['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
      if (first is String && first.trim().isNotEmpty) return first.trim();
    }
    if (errors is List && errors.isNotEmpty) return errors.first.toString();
  }
  // A short plain-text body is safe to show; a long HTML page is not.
  if (data is String) {
    final trimmed = data.trim();
    if (trimmed.isNotEmpty && trimmed.length < 160 && !trimmed.startsWith('<')) {
      return trimmed;
    }
  }
  return null;
}

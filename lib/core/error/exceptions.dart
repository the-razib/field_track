// Data-layer exceptions — caught in repositories and mapped to [Failure].

/// Thrown when the server returns an error response.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Thrown on network errors (no connectivity, timeout, etc.).
class NetworkException implements Exception {
  final String message;

  const NetworkException({
    this.message = 'Network error occurred.',
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown on local storage errors.
class CacheException implements Exception {
  final String message;

  const CacheException({
    this.message = 'Cache error occurred.',
  });

  @override
  String toString() => 'CacheException: $message';
}

/// Thrown on authentication errors (401, invalid token, etc.).
class AuthException implements Exception {
  final String message;
  final int? statusCode;

  const AuthException({required this.message, this.statusCode});

  @override
  String toString() => 'AuthException($statusCode): $message';
}

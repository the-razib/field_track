/// API endpoint constants derived from the Postman collection.
class ApiConstants {
  ApiConstants._();

  /// Base URL — update this to match the actual backend server.
  static const String baseUrl = 'https://todo.progressivebyte.com';

  // ─── Health ─────────────────────────────────────────────────────
  static const String health = '/health';

  // ─── Auth ───────────────────────────────────────────────────────
  static const String register = '/api/v1/auth/register';
  static const String login = '/api/v1/auth/login';
  static const String refresh = '/api/v1/auth/refresh';
  static const String logout = '/api/v1/auth/logout';
  static const String me = '/api/v1/me';

  // ─── Locations ──────────────────────────────────────────────────
  static const String locations = '/api/v1/locations';
  static String locationById(String id) => '/api/v1/locations/$id';

  // ─── Todos ──────────────────────────────────────────────────────
  static const String todos = '/api/v1/todos';
  static String todoById(String id) => '/api/v1/todos/$id';
  static const String todosSync = '/api/v1/todos/sync';
}

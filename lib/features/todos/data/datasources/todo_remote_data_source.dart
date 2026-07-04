import 'package:field_track/core/constants/api_constants.dart';
import 'package:field_track/core/network/api_client.dart';
import 'package:field_track/features/todos/data/models/todo_model.dart';

abstract class TodoRemoteDataSource {
  Future<List<TodoModel>> getTodos();
  Future<TodoModel> patchTodo(String id, bool isCompleted, String updatedAt);
  Future<void> syncTodos(List<Map<String, dynamic>> changes);
}

class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final ApiClient apiClient;

  TodoRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<TodoModel>> getTodos() async {
    final response = await apiClient.dio.get(ApiConstants.todos);
    final data = response.data;

    final List<dynamic> list;
    if (data is Map<String, dynamic>) {
      list = data['todos'] as List<dynamic>? ?? data['data'] as List<dynamic>? ?? [];
    } else if (data is List) {
      list = data;
    } else {
      list = [];
    }

    return list.map((e) => TodoModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<TodoModel> patchTodo(String id, bool isCompleted, String updatedAt) async {
    final response = await apiClient.dio.patch(
      ApiConstants.todoById(id),
      data: {
        'is_completed': isCompleted,
        'updated_at': updatedAt,
      },
    );

    final data = response.data;
    final todoData = data is Map<String, dynamic>
        ? (data.containsKey('todo') ? data['todo'] as Map<String, dynamic> : data)
        : <String, dynamic>{};

    return TodoModel.fromJson(todoData);
  }

  @override
  Future<void> syncTodos(List<Map<String, dynamic>> changes) async {
    await apiClient.dio.post(
      ApiConstants.todosSync,
      data: {
        'changes': changes,
      },
    );
  }
}

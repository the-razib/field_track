import 'package:dartz/dartz.dart';
import 'package:field_track/core/error/failures.dart';
import 'package:field_track/features/todos/domain/entities/todo.dart';

abstract class TodoRepository {
  Future<Either<Failure, List<Todo>>> getTodos();
  Future<Either<Failure, Todo>> toggleTodo(String id, bool isCompleted);
  Future<Either<Failure, void>> syncTodos();
}

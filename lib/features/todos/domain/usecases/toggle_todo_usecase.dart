import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:field_track/core/error/failures.dart';
import 'package:field_track/core/usecases/usecase.dart';
import 'package:field_track/features/todos/domain/entities/todo.dart';
import 'package:field_track/features/todos/domain/repositories/todo_repository.dart';

class ToggleTodoUseCase extends UseCase<Todo, ToggleTodoParams> {
  final TodoRepository repository;

  ToggleTodoUseCase(this.repository);

  @override
  Future<Either<Failure, Todo>> call(ToggleTodoParams params) {
    return repository.toggleTodo(params.id, params.isCompleted);
  }
}

class ToggleTodoParams extends Equatable {
  final String id;
  final bool isCompleted;

  const ToggleTodoParams({required this.id, required this.isCompleted});

  @override
  List<Object?> get props => [id, isCompleted];
}

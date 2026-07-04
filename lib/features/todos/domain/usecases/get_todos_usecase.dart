import 'package:dartz/dartz.dart';
import 'package:field_track/core/error/failures.dart';
import 'package:field_track/core/usecases/usecase.dart';
import 'package:field_track/features/todos/domain/entities/todo.dart';
import 'package:field_track/features/todos/domain/repositories/todo_repository.dart';

class GetTodosUseCase extends UseCase<List<Todo>, NoParams> {
  final TodoRepository repository;

  GetTodosUseCase(this.repository);

  @override
  Future<Either<Failure, List<Todo>>> call(NoParams params) {
    return repository.getTodos();
  }
}

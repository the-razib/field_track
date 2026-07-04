import 'package:dartz/dartz.dart';
import 'package:field_track/core/error/failures.dart';
import 'package:field_track/core/usecases/usecase.dart';
import 'package:field_track/features/todos/domain/repositories/todo_repository.dart';

class SyncTodosUseCase extends UseCase<void, NoParams> {
  final TodoRepository repository;

  SyncTodosUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.syncTodos();
  }
}

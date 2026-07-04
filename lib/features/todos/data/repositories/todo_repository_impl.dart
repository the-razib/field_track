import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:field_track/core/error/failures.dart';
import 'package:field_track/core/network/connectivity_service.dart';
import 'package:field_track/features/todos/domain/entities/todo.dart';
import 'package:field_track/features/todos/domain/repositories/todo_repository.dart';
import 'package:field_track/features/todos/data/datasources/todo_local_data_source.dart';
import 'package:field_track/features/todos/data/datasources/todo_remote_data_source.dart';
import 'package:field_track/features/todos/data/models/pending_change_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource remoteDataSource;
  final TodoLocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  TodoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, List<Todo>>> getTodos() async {
    final isOnline = await connectivityService.isOnline;
    if (isOnline) {
      try {
        final remoteTodos = await remoteDataSource.getTodos();
        await localDataSource.cacheTodos(remoteTodos);
        
        // Return latest merge
        final mergedTodos = await localDataSource.getCachedTodos();
        return Right(mergedTodos);
      } on DioException catch (_) {
        // Fallback to cache on api failure
        final cachedTodos = await localDataSource.getCachedTodos();
        return Right(cachedTodos);
      } catch (_) {
        final cachedTodos = await localDataSource.getCachedTodos();
        return Right(cachedTodos);
      }
    } else {
      final cachedTodos = await localDataSource.getCachedTodos();
      return Right(cachedTodos);
    }
  }

  @override
  Future<Either<Failure, Todo>> toggleTodo(String id, bool isCompleted) async {
    final updatedAt = DateTime.now().toUtc().toIso8601String();
    
    // Optimistically update cache and add pending change
    await localDataSource.updateCachedTodo(id, isCompleted, updatedAt);
    
    final change = PendingChangeModel(
      todoId: id,
      isCompleted: isCompleted,
      updatedAt: updatedAt,
    );
    await localDataSource.savePendingChange(change);

    final isOnline = await connectivityService.isOnline;
    if (isOnline) {
      try {
        // Attempt immediate sync
        final updatedTodo = await remoteDataSource.patchTodo(id, isCompleted, updatedAt);
        
        // Remove from pending on success
        final pending = await localDataSource.getPendingChanges();
        final match = pending.firstWhere((element) => element.todoId == id);
        if (match.id != null) {
          await localDataSource.deletePendingChanges([match.id!]);
        }
        
        await localDataSource.updateCachedTodo(id, isCompleted, updatedAt);
        return Right(updatedTodo.copyWith(isPendingSync: false));
      } catch (_) {
        // Keep pending change if sync failed, returning optimistic cached todo
      }
    }

    final cached = await localDataSource.getCachedTodos();
    final item = cached.firstWhere((element) => element.id == id);
    return Right(item);
  }

  @override
  Future<Either<Failure, void>> syncTodos() async {
    final isOnline = await connectivityService.isOnline;
    if (!isOnline) {
      return const Left(NetworkFailure());
    }

    try {
      final pending = await localDataSource.getPendingChanges();
      if (pending.isEmpty) {
        return const Right(null);
      }

      final pendingIds = pending.map((e) => e.id!).toList();
      await localDataSource.updatePendingChangesStatus(pendingIds, 'syncing');

      final changesData = pending.map((e) => e.toSyncJson()).toList();
      await remoteDataSource.syncTodos(changesData);

      // Clean up successfully synced changes
      await localDataSource.deletePendingChanges(pendingIds);

      // Refresh cache to match remote
      final remoteTodos = await remoteDataSource.getTodos();
      await localDataSource.cacheTodos(remoteTodos);

      return const Right(null);
    } on DioException catch (e) {
      // Revert status on failure
      final pending = await localDataSource.getPendingChanges();
      final pendingIds = pending.where((e) => e.syncStatus == 'syncing').map((e) => e.id!).toList();
      await localDataSource.updatePendingChangesStatus(pendingIds, 'failed');
      
      return Left(ServerFailure(message: e.toString()));
    } catch (e) {
      final pending = await localDataSource.getPendingChanges();
      final pendingIds = pending.where((e) => e.syncStatus == 'syncing').map((e) => e.id!).toList();
      await localDataSource.updatePendingChangesStatus(pendingIds, 'failed');

      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}

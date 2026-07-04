import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_track/core/network/connectivity_service.dart';
import 'package:field_track/core/usecases/usecase.dart';
import 'package:field_track/features/todos/domain/usecases/get_todos_usecase.dart';
import 'package:field_track/features/todos/domain/usecases/sync_todos_usecase.dart';
import 'package:field_track/features/todos/domain/usecases/toggle_todo_usecase.dart';
import 'package:field_track/features/todos/presentation/bloc/todo_event.dart';
import 'package:field_track/features/todos/presentation/bloc/todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final GetTodosUseCase getTodosUseCase;
  final ToggleTodoUseCase toggleTodoUseCase;
  final SyncTodosUseCase syncTodosUseCase;
  final ConnectivityService connectivityService;
  StreamSubscription? _connectivitySubscription;

  TodoBloc({
    required this.getTodosUseCase,
    required this.toggleTodoUseCase,
    required this.syncTodosUseCase,
    required this.connectivityService,
  }) : super(const TodoInitial()) {
    on<TodosLoadRequested>(_onLoadTodos);
    on<TodoToggleRequested>(_onToggleTodo);
    on<TodosSyncRequested>(_onSyncTodos);

    // Auto-sync on connectivity restored
    _connectivitySubscription = connectivityService.statusStream.listen((status) {
      if (status == ConnectivityStatus.online) {
        add(const TodosSyncRequested());
      }
    });
  }

  Future<void> _onLoadTodos(
    TodosLoadRequested event,
    Emitter<TodoState> emit,
  ) async {
    emit(const TodoLoading());
    final result = await getTodosUseCase(const NoParams());
    result.fold(
      (failure) => emit(TodoError(message: failure.message)),
      (todos) => emit(TodoLoaded(todos: todos)),
    );
  }

  Future<void> _onToggleTodo(
    TodoToggleRequested event,
    Emitter<TodoState> emit,
  ) async {
    final currentState = state;
    if (currentState is TodoLoaded) {
      // Optimistically update UI immediately to preserve Snappy UX
      final updatedTodos = currentState.todos.map((todo) {
        if (todo.id == event.id) {
          return todo.copyWith(
            isCompleted: event.isCompleted,
            isPendingSync: true,
          );
        }
        return todo;
      }).toList();
      emit(TodoLoaded(todos: updatedTodos, isSyncing: currentState.isSyncing));
    }

    final result = await toggleTodoUseCase(
      ToggleTodoParams(id: event.id, isCompleted: event.isCompleted),
    );

    result.fold(
      (failure) {
        // If operation failed entirely (e.g. database error), we reload
        add(const TodosLoadRequested());
      },
      (updatedTodo) {
        if (state is TodoLoaded) {
          final s = state as TodoLoaded;
          final finalTodos = s.todos.map((todo) {
            if (todo.id == updatedTodo.id) {
              return updatedTodo;
            }
            return todo;
          }).toList();
          emit(TodoLoaded(todos: finalTodos, isSyncing: s.isSyncing));
        }
      },
    );
  }

  Future<void> _onSyncTodos(
    TodosSyncRequested event,
    Emitter<TodoState> emit,
  ) async {
    final currentState = state;
    if (currentState is TodoLoaded) {
      emit(currentState.copyWith(isSyncing: true));
    }

    final result = await syncTodosUseCase(const NoParams());

    result.fold(
      (failure) {
        if (state is TodoLoaded) {
          emit((state as TodoLoaded).copyWith(isSyncing: false));
        }
      },
      (_) {
        // Reload todos to fetch fresh state from server/cache
        add(const TodosLoadRequested());
      },
    );
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}

import 'package:equatable/equatable.dart';
import 'package:field_track/features/todos/domain/entities/todo.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {
  const TodoInitial();
}

class TodoLoading extends TodoState {
  const TodoLoading();
}

class TodoLoaded extends TodoState {
  final List<Todo> todos;
  final bool isSyncing;

  const TodoLoaded({
    required this.todos,
    this.isSyncing = false,
  });

  TodoLoaded copyWith({
    List<Todo>? todos,
    bool? isSyncing,
  }) {
    return TodoLoaded(
      todos: todos ?? this.todos,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  @override
  List<Object?> get props => [todos, isSyncing];
}

class TodoError extends TodoState {
  final String message;

  const TodoError({required this.message});

  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class TodosLoadRequested extends TodoEvent {
  const TodosLoadRequested();
}

class TodoToggleRequested extends TodoEvent {
  final String id;
  final bool isCompleted;

  const TodoToggleRequested({required this.id, required this.isCompleted});

  @override
  List<Object?> get props => [id, isCompleted];
}

class TodosSyncRequested extends TodoEvent {
  const TodosSyncRequested();
}

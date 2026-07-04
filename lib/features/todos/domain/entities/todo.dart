import 'package:equatable/equatable.dart';

/// Domain entity for a todo item.
class Todo extends Equatable {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final String? dueTime;
  final String updatedAt;
  final String? createdAt;
  final bool isPendingSync;

  const Todo({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.dueTime,
    required this.updatedAt,
    this.createdAt,
    this.isPendingSync = false,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    String? dueTime,
    String? updatedAt,
    String? createdAt,
    bool? isPendingSync,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueTime: dueTime ?? this.dueTime,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      isPendingSync: isPendingSync ?? this.isPendingSync,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, description, isCompleted, dueTime, updatedAt, isPendingSync];
}

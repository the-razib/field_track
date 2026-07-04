import 'package:equatable/equatable.dart';

/// Represents a pending offline change to a todo item.
class PendingChange extends Equatable {
  final int? id;
  final String todoId;
  final bool isCompleted;
  final String updatedAt;
  final String syncStatus; // pending | syncing | failed

  const PendingChange({
    this.id,
    required this.todoId,
    required this.isCompleted,
    required this.updatedAt,
    this.syncStatus = 'pending',
  });

  Map<String, dynamic> toSyncJson() {
    return {
      'todo_id': todoId,
      'is_completed': isCompleted,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [id, todoId, isCompleted, updatedAt, syncStatus];
}

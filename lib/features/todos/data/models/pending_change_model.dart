import 'package:field_track/features/todos/domain/entities/pending_change.dart';

class PendingChangeModel extends PendingChange {
  const PendingChangeModel({
    super.id,
    required super.todoId,
    required super.isCompleted,
    required super.updatedAt,
    super.syncStatus,
  });

  factory PendingChangeModel.fromDbMap(Map<String, dynamic> map) {
    return PendingChangeModel(
      id: map['id'] as int?,
      todoId: map['todo_id'] as String,
      isCompleted: (map['is_completed'] as int) == 1,
      updatedAt: map['updated_at'] as String,
      syncStatus: map['sync_status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      if (id != null) 'id': id,
      'todo_id': todoId,
      'is_completed': isCompleted ? 1 : 0,
      'updated_at': updatedAt,
      'sync_status': syncStatus,
    };
  }

  factory PendingChangeModel.fromEntity(PendingChange entity) {
    return PendingChangeModel(
      id: entity.id,
      todoId: entity.todoId,
      isCompleted: entity.isCompleted,
      updatedAt: entity.updatedAt,
      syncStatus: entity.syncStatus,
    );
  }
}

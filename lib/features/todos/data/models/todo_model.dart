import 'package:field_track/features/todos/domain/entities/todo.dart';

class TodoModel extends Todo {
  const TodoModel({
    required super.id,
    required super.title,
    super.description,
    super.isCompleted,
    super.dueTime,
    required super.updatedAt,
    super.createdAt,
    super.isPendingSync,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      dueTime: json['due_time'] as String?,
      updatedAt: json['updated_at'] as String? ?? json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      createdAt: json['created_at'] as String? ?? json['createdAt'] as String?,
      isPendingSync: json['is_pending_sync'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'due_time': dueTime,
      'updated_at': updatedAt,
      'created_at': createdAt,
    };
  }

  TodoModel copyWithModel({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    String? dueTime,
    String? updatedAt,
    String? createdAt,
    bool? isPendingSync,
  }) {
    return TodoModel(
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
}

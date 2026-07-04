import 'package:field_track/core/storage/local_database.dart';
import 'package:field_track/features/todos/data/models/pending_change_model.dart';
import 'package:field_track/features/todos/data/models/todo_model.dart';

abstract class TodoLocalDataSource {
  Future<void> cacheTodos(List<TodoModel> todos);
  Future<List<TodoModel>> getCachedTodos();
  Future<void> updateCachedTodo(String id, bool isCompleted, String updatedAt);
  Future<void> savePendingChange(PendingChangeModel change);
  Future<List<PendingChangeModel>> getPendingChanges();
  Future<void> deletePendingChanges(List<int> ids);
  Future<void> updatePendingChangesStatus(List<int> ids, String status);
  Future<void> clearAll();
}

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  final LocalDatabase localDatabase;

  TodoLocalDataSourceImpl({required this.localDatabase});

  @override
  Future<void> cacheTodos(List<TodoModel> todos) async {
    final db = await localDatabase.database;
    await db.transaction((txn) async {
      // Clear existing cached todos
      await txn.delete('todos');
      
      for (final todo in todos) {
        await txn.insert(
          'todos',
          {
            'id': todo.id,
            'title': todo.title,
            'description': todo.description,
            'is_completed': todo.isCompleted ? 1 : 0,
            'due_time': todo.dueTime,
            'updated_at': todo.updatedAt,
            'created_at': todo.createdAt,
          },
        );
      }
    });
  }

  @override
  Future<List<TodoModel>> getCachedTodos() async {
    final db = await localDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('todos');
    
    // Get pending changes to mark cached todos accordingly
    final pendingChanges = await getPendingChanges();
    final Map<String, PendingChangeModel> pendingMap = {
      for (final change in pendingChanges) change.todoId: change
    };

    return List.generate(maps.length, (i) {
      final id = maps[i]['id'] as String;
      final isCompletedFromDb = (maps[i]['is_completed'] as int) == 1;
      
      // If there's a pending change, use its value instead of the cached DB value
      final pending = pendingMap[id];
      final isCompleted = pending != null ? pending.isCompleted : isCompletedFromDb;
      final isPendingSync = pending != null;

      return TodoModel(
        id: id,
        title: maps[i]['title'] as String,
        description: maps[i]['description'] as String?,
        isCompleted: isCompleted,
        dueTime: maps[i]['due_time'] as String?,
        updatedAt: pending != null ? pending.updatedAt : maps[i]['updated_at'] as String,
        createdAt: maps[i]['created_at'] as String?,
        isPendingSync: isPendingSync,
      );
    });
  }

  @override
  Future<void> updateCachedTodo(String id, bool isCompleted, String updatedAt) async {
    final db = await localDatabase.database;
    await db.update(
      'todos',
      {
        'is_completed': isCompleted ? 1 : 0,
        'updated_at': updatedAt,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> savePendingChange(PendingChangeModel change) async {
    final db = await localDatabase.database;
    await db.transaction((txn) async {
      // Check if there's already a pending change for this todo.
      // If so, update it instead of inserting a new one to prevent duplicates.
      final existing = await txn.query(
        'pending_changes',
        where: 'todo_id = ?',
        whereArgs: [change.todoId],
      );

      if (existing.isNotEmpty) {
        final existingId = existing.first['id'] as int;
        await txn.update(
          'pending_changes',
          {
            'is_completed': change.isCompleted ? 1 : 0,
            'updated_at': change.updatedAt,
            'sync_status': 'pending', // Reset status back to pending
          },
          where: 'id = ?',
          whereArgs: [existingId],
        );
      } else {
        await txn.insert('pending_changes', change.toDbMap());
      }
    });
  }

  @override
  Future<List<PendingChangeModel>> getPendingChanges() async {
    final db = await localDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pending_changes',
      orderBy: 'created_at ASC',
    );
    return maps.map((m) => PendingChangeModel.fromDbMap(m)).toList();
  }

  @override
  Future<void> deletePendingChanges(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = await localDatabase.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.delete(
      'pending_changes',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  @override
  Future<void> updatePendingChangesStatus(List<int> ids, String status) async {
    if (ids.isEmpty) return;
    final db = await localDatabase.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.update(
      'pending_changes',
      {'sync_status': status},
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  @override
  Future<void> clearAll() async {
    final db = await localDatabase.database;
    await db.delete('todos');
    await db.delete('pending_changes');
  }
}

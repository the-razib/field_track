import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:field_track/core/constants/app_constants.dart';

/// SQLite database for offline todo caching and pending changes.
class LocalDatabase {
  static Database? _database;

  /// Get or create the database instance.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Cached todo items from the server
    await db.execute('''
      CREATE TABLE todos (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0,
        due_time TEXT,
        updated_at TEXT NOT NULL,
        created_at TEXT
      )
    ''');

    // Pending unsynced changes (offline-first queue)
    await db.execute('''
      CREATE TABLE pending_changes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        todo_id TEXT NOT NULL,
        is_completed INTEGER NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (todo_id) REFERENCES todos(id)
      )
    ''');

    // Index for fast pending lookups
    await db.execute('''
      CREATE INDEX idx_pending_status ON pending_changes(sync_status)
    ''');

    // Index for deduplicating by todo_id
    await db.execute('''
      CREATE INDEX idx_pending_todo ON pending_changes(todo_id)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future migrations here
  }

  /// Close the database when the app terminates.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Clear all data — useful for logout.
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('pending_changes');
    await db.delete('todos');
  }
}

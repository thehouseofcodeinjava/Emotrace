// TODO: database service | Author: Rajat Mahajan
// Service: DatabaseService — SQLite operations, table creation, CRUD

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Database? _db;

  Database get db {
    if (_db == null) throw StateError('Database not initialized. Call init() first.');
    return _db!;
  }

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'emotrace.db'),
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE mood_entries (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        mood_score INTEGER NOT NULL CHECK(mood_score >= 1 AND mood_score <= 10),
        emotion_tags TEXT,
        notes TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE emotion_tags (
        id TEXT PRIMARY KEY,
        mood_entry_id TEXT NOT NULL,
        tag_name TEXT NOT NULL,
        FOREIGN KEY (mood_entry_id) REFERENCES mood_entries(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL UNIQUE,
        theme TEXT DEFAULT 'dark',
        daily_reminder_enabled INTEGER DEFAULT 1,
        reminder_time TEXT DEFAULT '20:00',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        jwt_token TEXT NOT NULL,
        expires_at DATETIME NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Indexes for performance
    await db.execute('CREATE INDEX idx_mood_entries_user_id ON mood_entries(user_id)');
    await db.execute('CREATE INDEX idx_mood_entries_created_at ON mood_entries(created_at)');
    await db.execute('CREATE INDEX idx_emotion_tags_mood_entry_id ON emotion_tags(mood_entry_id)');
    await db.execute('CREATE INDEX idx_sessions_user_id ON sessions(user_id)');
  }

  // --- Generic CRUD helpers ---

  Future<int> insert(String table, Map<String, dynamic> data) async {
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? args]) async {
    return await db.rawQuery(sql, args);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}

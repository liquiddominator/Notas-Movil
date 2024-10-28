import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'notes_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    // Notes table with user reference
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        dateCreated TEXT NOT NULL,
        userId INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');
  }

  // User methods
  Future<int> insertUser(Map<String, dynamic> user) async {
    final Database db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUser(String username, String password) async {
    final Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Note methods
  Future<int> insertNote(Map<String, dynamic> note) async {
    final Database db = await database;
    return await db.insert('notes', note);
  }

  Future<int> updateNote(Map<String, dynamic> note) async {
    final Database db = await database;
    return await db.update(
      'notes',
      note,
      where: 'id = ?',
      whereArgs: [note['id']],
    );
  }

  Future<int> deleteNote(int id) async {
    final Database db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getNotes(int userId) async {
    final Database db = await database;
    return await db.query(
      'notes',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'dateCreated DESC',
    );
  }

  Future<List<Map<String, dynamic>>> searchNotes(String query, int userId) async {
    final Database db = await database;
    return await db.query(
      'notes',
      where: 'userId = ? AND (title LIKE ? OR content LIKE ?)',
      whereArgs: [userId, '%$query%', '%$query%'],
      orderBy: 'dateCreated DESC',
    );
  }
}
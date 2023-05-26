import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/todo.dart';

class DatabaseService {
  static const _databaseName = 'todo_database.db';
  static const _databaseVersion = 1;

  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    Database? instance = _database;

    if (instance != null) return instance;
    // Initialize the databaseFactory
    databaseFactory = databaseFactoryFfi;
    sqfliteFfiInit();
    instance = await _initDatabase();
    _database = instance;
    return instance;
  }

  Future<Database> _initDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,,
        todo TEXT,
        description TEXT,
        dueDate INTEGER,
        completed INTEGER,
        imageFilePath TEXT
      )
    ''',
    );
  }

  Future<void> addTodo(Todo todo) async {
    final db = await database;
    await db.insert('todos', todo.toMap());
  }

  Future<void> deleteTodoById(int id) async {
    final db = await database;
    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateTodo(Todo updatedTodo) async {
    final db = await database;
    await db.update(
      'todos',
      updatedTodo.toMap(),
      where: 'id = ?',
      whereArgs: [updatedTodo.id],
    );
  }

  Future<List<Todo>> getAllTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');
    return List.generate(maps.length, (index) => Todo.fromMap(maps[index]));
  }
}

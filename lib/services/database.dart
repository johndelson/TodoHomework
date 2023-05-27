import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

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

    // Get the application documents directory
    final appDirectory = await getApplicationDocumentsDirectory();
    final dbPath = join(appDirectory.path, _databaseName);

    instance = await _initDatabase(dbPath);
    _database = instance;
    return instance;
  }

  Future<Database> _initDatabase(String dbPath) async {
    final databaseFactory = databaseFactoryIo;
    final database = await databaseFactory.openDatabase(dbPath);
    return database;
  }

  Future<void> addTodo(Todo todo) async {
    final db = await database;
    final store = intMapStoreFactory.store('todos');

    final finder = Finder(sortOrders: [SortOrder('id', false)]);
    final snapshots = await store.find(db, finder: finder);

    int maxId = snapshots.isNotEmpty ? snapshots.first['id'] as int : 0;
    final newId = maxId + 1;

    final todoWithId = todo.copyWith(id: newId);
    await store.add(db, todoWithId.toMap());
  }

  Future<void> deleteTodoById(int id) async {
    final db = await database;
    final store = intMapStoreFactory.store('todos');
    await store.record(id).delete(db);
  }

  Future<void> updateTodo(Todo updatedTodo) async {
    if (updatedTodo.id != null) {
      final db = await database;
      final store = intMapStoreFactory.store('todos');
      await store.record(updatedTodo.id!).put(db, updatedTodo.toMap());
    }
  }

  Future<List<Todo>> getAllTodos() async {
    final db = await database;
    final store = intMapStoreFactory.store('todos');
    final snapshots = await store.find(db);
    return snapshots.map((snapshot) => Todo.fromMap(snapshot.value)).toList();
  }
}

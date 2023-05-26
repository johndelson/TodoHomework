import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Homework',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodosList(title: 'Homework List'),
    );
  }
}

class TodosList extends StatefulWidget {
  const TodosList({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _TodosListState createState() => _TodosListState();
}

class _TodosListState extends State<TodosList> {
  late Future<Database> _database;
  final List<Todo> _todos = [];
  File? _selectedImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    databaseFactory = databaseFactoryFfi;
    sqfliteFfiInit();
    _database = openDatabase(join(await getDatabasesPath(), 'database.db'),
        version: 1, onCreate: (Database db, int version) async {
      await db.execute(
          '''
        CREATE TABLE IF NOT EXISTS todos(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          todo TEXT,
          description TEXT,
          dueDate INTEGER,
          completed INTEGER,
          imageFilePath TEXT
        )
      ''');
    });
    await _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    final Database db = await _database;
    final List<Map<String, dynamic>> todoRows = await db.query('todos');
    setState(() {
      _todos.clear();
      _todos.addAll(todoRows.map((row) => Todo.fromMap(row)));
      _sortTodosByDueDate();
    });
  }

  void _sortTodosByDueDate() {
    _todos.sort((a, b) {
      if (a.completed != b.completed) {
        return a.completed ? 1 : -1;
      }
      if (a.dueDate.isBefore(DateTime.now()) &&
          !b.dueDate.isBefore(DateTime.now())) {
        return 1;
      }
      if (!a.dueDate.isBefore(DateTime.now()) &&
          b.dueDate.isBefore(DateTime.now())) {
        return -1;
      }
      return a.dueDate.compareTo(b.dueDate);
    });
  }

  void _resetSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _addTodo() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController dueDateController = TextEditingController();
    DateTime? selectedDate;

    _resetSelectedImage();

    final todo = await showDialog<Todo>(
      context: this.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Enter your todo'),
              ),
              TextField(
                controller: descriptionController,
                decoration:
                    const InputDecoration(hintText: 'Enter description'),
              ),
              TextFormField(
                controller: dueDateController,
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: this.context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                      dueDateController.text =
                          DateFormat('MMM dd, yyyy').format(pickedDate);
                    });
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'Select due date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
              ),
              ElevatedButton(
                onPressed: () => _selectImage(),
                child: const Text('Select Image'),
              ),
              if (_selectedImage != null) Image.file(_selectedImage!),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(this.context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newTodo = Todo(
                  todo: titleController.text,
                  description: descriptionController.text,
                  dueDate: selectedDate ?? DateTime.now(),
                  imageFilePath:
                      _selectedImage != null ? _selectedImage!.path : null,
                  completed: false,
                );
                Navigator.of(this.context).pop(newTodo);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (todo != null) {
      final Database db = await _database;
      final todoId = await db.insert('todos', todo.toMap());
      setState(() {
        _todos.add(todo.copyWith(id: todoId));
        _sortTodosByDueDate();
      });
    }
  }

  Future<void> _selectImage() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.files.single.path!);
      });
    }
  }

  String _formatDueDate(DateTime dueDate) {
    final DateFormat formatter = DateFormat('MMM dd, yyyy');
    return 'Due Date: ${formatter.format(dueDate)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            onTap: () => _viewEditTodoItem(index),
            title: Text(_todos[index].todo),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_todos[index].description ?? ''),
                Text(_formatDueDate(_todos[index].dueDate)),
              ],
            ),
            leading: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 0,
                  child: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteTodoItem(index),
                  ),
                ),
                if (_todos[index].imageFilePath != null)
                  CircleAvatar(
                    backgroundImage:
                        FileImage(File(_todos[index].imageFilePath!)),
                  ),
              ],
            ),
            trailing: Checkbox(
              value: _todos[index].completed,
              onChanged: (bool? value) {
                _updateTodoCompleted(index, value);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        tooltip: 'Add Todo',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _viewEditTodoItem(int index) async {
    final TextEditingController titleController =
        TextEditingController(text: _todos[index].todo);
    final TextEditingController descriptionController =
        TextEditingController(text: _todos[index].description);
    final TextEditingController dueDateController = TextEditingController(
        text: DateFormat('MMM dd, yyyy').format(_todos[index].dueDate));
    DateTime? selectedDate = _todos[index].dueDate;

    _resetSelectedImage();

    final updatedTodo = await showDialog<Todo>(
      context: this.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Enter your todo'),
              ),
              TextField(
                controller: descriptionController,
                decoration:
                    const InputDecoration(hintText: 'Enter description'),
              ),
              TextFormField(
                controller: dueDateController,
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: this.context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                      dueDateController.text =
                          DateFormat('MMM dd, yyyy').format(pickedDate);
                    });
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'Select due date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
              ),
              ElevatedButton(
                onPressed: () => _selectImage(),
                child: const Text('Select Image'),
              ),
              if (_selectedImage != null) Image.file(_selectedImage!),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(this.context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final updatedTodo = _todos[index].copyWith(
                  todo: titleController.text,
                  description: descriptionController.text,
                  dueDate: selectedDate ?? DateTime.now(),
                  imageFilePath:
                      _selectedImage != null ? _selectedImage!.path : null,
                );
                Navigator.of(this.context).pop(updatedTodo);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (updatedTodo != null) {
      final Database db = await _database;
      await db.update(
        'todos',
        updatedTodo.toMap(),
        where: 'id = ?',
        whereArgs: [updatedTodo.id],
      );
      setState(() {
        _todos[index] = updatedTodo;
        _sortTodosByDueDate();
      });
    }
  }

  Future<void> _deleteTodoItem(int index) async {
    final confirmed = await showDialog<bool>(
      context: this.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Todo'),
          content: const Text('Are you sure you want to delete this todo?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(this.context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(this.context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final Database db = await _database;
      await db.delete(
        'todos',
        where: 'id = ?',
        whereArgs: [_todos[index].id],
      );
      setState(() {
        _todos.removeAt(index);
      });
    }
  }

  Future<void> _updateTodoCompleted(int index, bool? value) async {
    final updatedTodo = _todos[index].copyWith(completed: value);
    final Database db = await _database;
    await db.update(
      'todos',
      updatedTodo.toMap(),
      where: 'id = ?',
      whereArgs: [updatedTodo.id],
    );
    setState(() {
      _todos[index] = updatedTodo;
      _sortTodosByDueDate();
    });
  }
}

class Todo {
  final int? id;
  final String todo;
  final String? description;
  final DateTime dueDate;
  final bool completed;
  final String? imageFilePath;

  Todo({
    this.id,
    required this.todo,
    this.description,
    required this.dueDate,
    required this.completed,
    this.imageFilePath,
  });

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int?,
      todo: map['todo'],
      description: map['description'],
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate']),
      completed: map['completed'] == 1,
      imageFilePath: map['imageFilePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'todo': todo,
      'description': description,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'completed': completed ? 1 : 0,
      'imageFilePath': imageFilePath,
    };
  }

  Todo copyWith({
    int? id,
    String? todo,
    String? description,
    DateTime? dueDate,
    bool? completed,
    String? imageFilePath,
  }) {
    return Todo(
      id: id ?? this.id,
      todo: todo ?? this.todo,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      imageFilePath: imageFilePath ?? this.imageFilePath,
    );
  }
}

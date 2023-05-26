import 'dart:io';

import 'package:flutter/material.dart';
import 'models/todo.dart';
import 'utils/date_utils.dart';

import 'screens/splash_screen.dart';
import 'screens/add_todo_screen.dart';
import 'screens/todo_detail_screen.dart';
import 'services/database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashPage(),
        '/home': (context) => const TodoListScreen(),
        AddTodoScreen.routeName: (context) => const AddTodoScreen(),
        TodoDetailScreen.routeName: (context) => const TodoDetailScreen(),
      },
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({Key? key}) : super(key: key);

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Todo> _todos = [];

  @override
  void initState() {
    super.initState();
    _loadTodos().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> _loadTodos() async {
    final todos = await DatabaseService.instance.getAllTodos();
    setState(() {
      _todos.clear();
      _todos = todos;
      _sortTodosByDueDate();
    });
  }

  Future<void> _deleteTodoItem(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Todo'),
          content: const Text('Are you sure you want to delete this todo?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await DatabaseService.instance.deleteTodoById(_todos[index].id!);
      setState(() {
        _todos.removeAt(index);
      });
    }
  }

  Future<void> _updateTodoCompleted(int index, bool? value) async {
    final updatedTodo = _todos[index].copyWith(completed: value);

    await DatabaseService.instance.updateTodo(updatedTodo);
    setState(() {
      _todos[index] = updatedTodo;
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

  void _navigateToAddTodoScreen() {
    Navigator.of(context).pushNamed(AddTodoScreen.routeName).then((_) {
      _loadTodos();
    });
  }

  void _navigateToTodoDetailScreen(Todo todo) {
    Navigator.of(context).pushNamed(
      TodoDetailScreen.routeName,
      arguments: todo,
    );
  }

  void _navigateToEditTodoScreen(Todo todo) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => AddTodoScreen(todo: todo),
      ),
    )
        .then((_) {
      _loadTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          final todo = _todos[index];
          return Card(
            elevation: 4,
            color: todo.completed ? Colors.grey[300] : Colors.white,
            child: ListTile(
              onTap: () => _navigateToTodoDetailScreen(todo),
              title: Text(
                todo.todo,
                style: TextStyle(
                  decoration:
                      todo.completed ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(todo.description ?? ''),
                  Text(
                    DateUtil.formatDueDate(todo.dueDate),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: todo.completed ? Colors.grey : Colors.black,
                    ),
                  ),
                ],
              ),
              leading: todo.imageFilePath != null
                  ? CircleAvatar(
                      backgroundImage: FileImage(File(todo.imageFilePath!)),
                    )
                  : const Icon(Icons.photo), // Default icon if no image is uploaded
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    color: Colors.blue,
                    onPressed: () => _navigateToEditTodoScreen(todo),
                  ),
                  Checkbox(
                    value: todo.completed,
                    onChanged: (bool? value) {
                      _updateTodoCompleted(index, value);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () => _deleteTodoItem(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTodoScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}

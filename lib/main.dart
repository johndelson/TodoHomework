import 'dart:io';

import 'package:flutter/material.dart';

import 'models/todo.dart';
import 'utils/date_utils.dart';

import 'screens/add_todo_screen.dart';
import 'screens/todo_detail_screen.dart';
import 'services/database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TodoListScreen(),
      routes: {
        AddTodoScreen.routeName: (context) => const AddTodoScreen(),
        TodoDetailScreen.routeName: (context) => const TodoDetailScreen(),
      },
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

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
      await DatabaseService.instance.deleteTodoById(_todos[index].id as int);
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
          return ListTile(
            onTap: () => _navigateToTodoDetailScreen(todo),
            title: Text(todo.todo),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(todo.description ?? ''),
                Text(DateUtil.formatDueDate(todo.dueDate)),
              ],
            ),
            leading: _todos[index].imageFilePath != null
                ? CircleAvatar(
                    backgroundImage:
                        FileImage(File(_todos[index].imageFilePath!)),
                  )
                : SizedBox(width: 40), //
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
        onPressed: _navigateToAddTodoScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}

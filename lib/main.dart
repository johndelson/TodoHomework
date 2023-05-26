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
      _todos = todos;
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
            title: Text(todo.todo),
            subtitle: Text(DateUtil.formatDueDate(todo.dueDate)),
            trailing: todo.completed
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: () => _navigateToTodoDetailScreen(todo),
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

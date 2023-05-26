import 'dart:io';

import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../services/database.dart';
import '../utils/date_utils.dart';

class TodoDetailScreen extends StatelessWidget {
  static const routeName = '/todo-detail';

  const TodoDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todo = ModalRoute.of(context)!.settings.arguments as Todo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Todo: ${todo.todo}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text('Description: ${todo.description}'),
            const SizedBox(height: 8.0),
            Text('Due Date: ${DateUtil.formatDueDate(todo.dueDate)}'),
            const SizedBox(height: 8.0),
            Text('Completed: ${todo.completed ? 'Yes' : 'No'}'),
            if (todo.imageFilePath != null)
              Image.file(
                File(todo.imageFilePath!),
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await DatabaseService.instance.deleteTodoById(todo.id as int);
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.delete),
      ),
    );
  }
}

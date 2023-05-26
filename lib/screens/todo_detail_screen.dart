import 'dart:io';

import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../services/database.dart';
import '../utils/date_utils.dart';

class TodoDetailScreen extends StatelessWidget {
  static const routeName = '/todo_detail_screen';

  const TodoDetailScreen({Key? key}) : super(key: key);

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
              todo.todo,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Description:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(todo.description ?? ''),
            const SizedBox(height: 16),
            const Text(
              'Due Date:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(DateUtil.formatDueDate(todo.dueDate)),
            const SizedBox(height: 16),
            const Text(
              'Completed:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(todo.completed ? 'Yes' : 'No'),
            const SizedBox(height: 16),
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

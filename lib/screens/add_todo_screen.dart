import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../services/database.dart';
import '../utils/date_utils.dart';

class AddTodoScreen extends StatefulWidget {
  static const routeName = '/add_todo_screen';
  final Todo? todo;
  const AddTodoScreen({Key? key, this.todo}) : super(key: key);

  @override
  _AddTodoScreenState createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  late TextEditingController _todoController;
  late TextEditingController _descriptionController;
  late DateTime _dueDate;
  File? _selectedImage;
  String? _imageFilePath;

  @override
  void dispose() {
    _todoController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _todoController = TextEditingController(text: widget.todo?.todo);
    _descriptionController =
        TextEditingController(text: widget.todo?.description);
    _dueDate = widget.todo?.dueDate ?? DateTime.now();
    _imageFilePath = widget.todo?.imageFilePath;
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
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

  void _resetSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _saveTodo() async {
    final newTodo = Todo(
      todo: _todoController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _dueDate,
      imageFilePath: _imageFilePath ?? '',
      completed: false,
    );

    if (widget.todo == null) {
      // Add new todo
      await DatabaseService.instance.addTodo(newTodo);
    } else {
      // Update existing todo
      final updatedTodo = newTodo.copyWith(
          id: widget.todo!.id, completed: widget.todo!.completed);
      await DatabaseService.instance.updateTodo(updatedTodo);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo == null ? 'Add Todo' : 'Edit Todo'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _todoController,
                decoration: const InputDecoration(
                  labelText: 'Todo',
                ),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Due Date:'),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _selectDueDate(context),
                    child: Text(DateUtil.formatDueDate(_dueDate)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _selectImage,
                child: Row(
                  children: [
                    const Icon(Icons.photo),
                    const SizedBox(width: 8),
                    Text(_imageFilePath != null ? 'Change Image' : 'Add Image'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveTodo,
                child: Text(widget.todo == null ? 'Add' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

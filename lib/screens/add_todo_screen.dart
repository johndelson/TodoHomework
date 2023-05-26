import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/todo.dart';
import '../services/database.dart';

class AddTodoScreen extends StatefulWidget {
  static const routeName = '/add-todo';

  const AddTodoScreen({super.key});

  @override
  _AddTodoScreenState createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();

  String _todo = '';
  String _description = '';
  DateTime _dueDate = DateTime.now();
  File? _selectedImage;

  Future<void> _selectDueDate(BuildContext context) async {
    final currentDate = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: currentDate,
      lastDate: DateTime(currentDate.year + 1),
    );
    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentDate),
      );
      if (selectedTime != null) {
        setState(() {
          _dueDate = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final todo = Todo(
        todo: _todo,
        description: _description,
        dueDate: _dueDate,
        completed: false,
        imageFilePath: _selectedImage?.path,
      );
      await DatabaseService.instance.addTodo(todo);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Todo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Todo'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a todo';
                  }
                  return null;
                },
                onSaved: (value) {
                  _todo = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) {
                  _description = value!;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _dueDate != null
                          ? 'Due Date: ${DateFormat.yMd().format(_dueDate)}'
                          : 'No Due Date',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDueDate(context),
                    child: const Text('Select Due Date'),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Todo'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _selectImage,
                child: const Text('Select Image'),
              ),
              if (_selectedImage != null) Image.file(_selectedImage!),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/todo.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._privateConstructor();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DatabaseService._privateConstructor();

  Future<void> addTodo(Todo todo) async {
    await _firestore.collection('todos').doc().set(todo.toMap());
  }

  Future<void> deleteTodoById(String id) async {
    await _firestore.collection('todos').doc(id).delete();
  }

  Future<void> updateTodo(Todo updatedTodo) async {
    if (updatedTodo.id != null) {
      await _firestore
          .collection('todos')
          .doc(updatedTodo.id as String?)
          .update(updatedTodo.toMap());
    }
  }

  Future<List<Todo>> getAllTodos() async {
    final querySnapshot = await _firestore.collection('todos').get();
    return querySnapshot.docs
        .map((doc) => Todo.fromMap(doc.data(), doc.id))
        .toList();
  }
}

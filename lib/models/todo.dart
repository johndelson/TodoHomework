class Todo {
  int? id;
  String todo;
  String? description;
  DateTime dueDate;
  bool completed;
  String? imageFilePath;

  Todo({
    this.id,
    required this.todo,
    this.description,
    required this.dueDate,
    required this.completed,
    this.imageFilePath,
  });

  Todo.fromMap(Map<String, dynamic> map)
      : id = map['id'] as int?,
        todo = map['todo'],
        description = map['description'],
        dueDate = DateTime.parse(map['dueDate']),
        completed = map['completed'] == 1,
        imageFilePath = map['imageFilePath'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'todo': todo,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
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

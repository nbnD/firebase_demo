class Todo {
  String? id;
  String title;
  bool completed;

  Todo({
    required this.id,
    required this.title,
    required this.completed,
  });


  Todo copyWith({
    String? id,
    String? title,
    bool? completed,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }
}
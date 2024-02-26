class Todo {
  String? id;
  String title;
  String description;
  String date;
  bool completed;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.completed,
  });

  Todo copyWith({
    String? id,
    String? title,
    String?description,
    String? date,
    bool? completed,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }
}

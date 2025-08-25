class Todo {
  final int todoId;
  final String date;
  final String todo;
  final bool done;

  Todo({
    required this.todoId,
    required this.date,
    required this.todo,
    required this.done,
  });

  //Conversion en JSON 
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      todoId: int.parse(json['todo_id'].toString()),
      date: json['date'] ?? '',
      todo: json['todo'] ?? '',
      done: json['done'] == true || json['done'] == 1 || json['done'] == '1',
    );
  }

  //Conversion en JSON 
  Map<String, dynamic> toJson() {
    return {
      "todo_id": todoId,
      "date": date,
      "todo": todo,
      "done": done ? 1 : 0, 
    };
  }
  //Méthode pour copier un objet Todo avec des modifications optionnelles
  Todo copyWith({
    int? todoId,
    String? date,
    String? todo,
    bool? done,
  }) {
    return Todo(
      todoId: todoId ?? this.todoId,
      date: date ?? this.date,
      todo: todo ?? this.todo,
      done: done ?? this.done,
    );
  }
}

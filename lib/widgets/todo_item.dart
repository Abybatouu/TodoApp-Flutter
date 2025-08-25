import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;

  const TodoItem({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        leading: Checkbox(
          value: todo.done,
          onChanged: (_) {
            Provider.of<TodoProvider>(context, listen: false).toggleDone(todo);
          },
        ),
        title: Text(
          todo.todo,
          style: TextStyle(
            decoration: todo.done ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text("Date : ${todo.date}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () async {
                final controller = TextEditingController(text: todo.todo);
                final newText = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Modifier la tâche"),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(labelText: "Nouvelle valeur"),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
                      ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text("Valider")),
                    ],
                  ),
                );

                if (newText != null && newText.trim().isNotEmpty) {
                  final updated = todo.copyWith(todo: newText);
                  Provider.of<TodoProvider>(context, listen: false).updateTodo(updated);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                Provider.of<TodoProvider>(context, listen: false).deleteTodo(todo.todoId);
              },
            ),
          ],
        ),
      ),
    );
  }
}

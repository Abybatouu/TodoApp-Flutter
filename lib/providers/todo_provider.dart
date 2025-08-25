import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/api_service.dart';
import '../services/local_db_service.dart';

class TodoProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  final LocalDbService _local = LocalDbService();

  List<Todo> _todos = [];
  List<Todo> _history = [];
  bool _isLoading = false;
  int? _loadedForAccount;

  List<Todo> get todos => _todos;
  List<Todo> get history => _history;
  bool get isLoading => _isLoading;

  Future<void> fetchTodos(int accountId) async {
    final localList = _local.loadTodos().map((m) => Todo.fromJson(m)).toList();
    if (localList.isNotEmpty) {
      _todos = localList;
      _history = _todos.where((t) => t.done).toList();
      notifyListeners();
    }

    _isLoading = true;
    notifyListeners();
    try {
      final data = await _api.getTodos(accountId);             // peut échouer offline
      _todos = data.map((t) => Todo.fromJson(t)).toList();
      _history = _todos.where((t) => t.done).toList();
      _loadedForAccount = accountId;

      await _local.saveTodos(_todos.map((t) => {
        "todo_id": t.todoId,
        "date": t.date,
        "todo": t.todo,
        "done": t.done ? 1 : 0,
      }).toList());

      await _local.saveHistory(_history.map((t) => {
        "todo_id": t.todoId,
        "date": t.date,
        "todo": t.todo,
        "done": t.done ? 1 : 0,
      }).toList());

    } catch (_) {
      // on reste avec les données locales 
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool needsFetch(int accountId) {
    return _loadedForAccount != accountId || _todos.isEmpty;
  }

  Future<void> addTodo({
    required int accountId,
    required String todo,
    String? date,
  }) async {
    final nowDate = date ?? DateTime.now().toIso8601String().split('T').first;

    final tempId = DateTime.now().millisecondsSinceEpoch * -1;

    final localTodo = Todo(
      todoId: tempId,
      date: nowDate,
      todo: todo,
      done: false,
    );

    _todos = [..._todos, localTodo];
    _history = _todos.where((t) => t.done).toList();
    notifyListeners();

    await _local.upsertTodo({
      "todo_id": localTodo.todoId,
      "date": localTodo.date,
      "todo": localTodo.todo,
      "done": localTodo.done ? 1 : 0,
    });

    try {
      final res = await _api.insertTodo(
        accountId: accountId,
        date: nowDate,
        todo: todo,
        done: false,
      );
      if (res["status"] == "success") {
        await fetchTodos(accountId);
      }
    } catch (_) {
      
    }
  }

  Future<void> updateTodo(Todo updatedTodo) async {
    final index = _todos.indexWhere((t) => t.todoId == updatedTodo.todoId);
    if (index != -1) {
      _todos[index] = updatedTodo;
      _history = _todos.where((t) => t.done).toList();
      notifyListeners();
      await _local.upsertTodo({
        "todo_id": updatedTodo.todoId,
        "date": updatedTodo.date,
        "todo": updatedTodo.todo,
        "done": updatedTodo.done ? 1 : 0,
      });
    }

    try {
      final res = await _api.updateTodo(
        todoId: updatedTodo.todoId,
        date: updatedTodo.date,
        todo: updatedTodo.todo,
        done: updatedTodo.done,
      );
      if (res["status"] == "success") {
        
      }
    } catch (_) {}
  }

  Future<void> deleteTodo(int todoId) async {
    _todos.removeWhere((t) => t.todoId == todoId);
    _history = _todos.where((t) => t.done).toList();
    notifyListeners();
    await _local.removeTodo(todoId);

    try {
      final res = await _api.deleteTodo(todoId);
      if (res["status"] == "success") {
        
      }
    } catch (_) {}
  }

  Future<void> toggleDone(Todo todo) async {
    final updatedTodo = todo.copyWith(done: !todo.done);
    await updateTodo(updatedTodo);
  }

  //local
  List<Todo> search(String query) {
    if (query.isEmpty) return _todos;
    return _todos
        .where((t) => t.todo.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  //local
  List<Todo> getCompleted() {
    return _todos.where((t) => t.done).toList();
  }
}

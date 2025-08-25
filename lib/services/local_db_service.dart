import 'package:hive/hive.dart';

class LocalDbService {
  static const String todosBoxName = 'todos_box';
  static const String historyBoxName = 'history_box';

  Box get _todosBox => Hive.box(todosBoxName);
  Box get _historyBox => Hive.box(historyBoxName);

  Future<void> saveTodos(List<Map<String, dynamic>> todos) async {
    await _todosBox.put('todos', todos);
  }

  List<Map<String, dynamic>> loadTodos() {
    final data = _todosBox.get('todos');
    if (data is List) {
      return data.cast<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
    }
    return [];
    }

  Future<void> upsertTodo(Map<String, dynamic> todo) async {
    final list = loadTodos();
    final idx = list.indexWhere((t) => t['todo_id'].toString() == todo['todo_id'].toString());
    if (idx >= 0) {
      list[idx] = todo;
    } else {
      list.add(todo);
    }
    await saveTodos(list);
  }

  Future<void> removeTodo(int todoId) async {
    final list = loadTodos();
    list.removeWhere((t) => t['todo_id'].toString() == todoId.toString());
    await saveTodos(list);
  }

  Future<void> saveHistory(List<Map<String, dynamic>> doneTodos) async {
    await _historyBox.put('history', doneTodos);
  }

  List<Map<String, dynamic>> loadHistory() {
    final data = _historyBox.get('history');
    if (data is List) {
      return data.cast<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
    }
    return [];
  }
}

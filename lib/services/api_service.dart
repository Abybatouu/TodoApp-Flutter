import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class ApiService {
  /// ---- LOGIN ----
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse("${baseUrl}post.php?action=login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    print("➡️ [LOGIN] STATUS: ${res.statusCode}");
    print("➡️ [LOGIN] BODY: ${res.body}");

    return _decode(res.body);
  }

  /// ---- REGISTER ----
  Future<Map<String, dynamic>> signup(String email, String password) async {
    final res = await http.post(
      Uri.parse("${baseUrl}post.php?action=register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    print("➡️ [SIGNUP] STATUS: ${res.statusCode}");
    print("➡️ [SIGNUP] BODY: ${res.body}");

    return _decode(res.body);
  }

  /// ---- GET TODOS ----
  Future<List<dynamic>> getTodos(int accountId) async {
    final res = await http.post(
      Uri.parse("${baseUrl}post.php?action=getTodos"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"account_id": accountId}),
    );

    print("➡️ [GET TODOS] STATUS: ${res.statusCode}");
    print("➡️ [GET TODOS] BODY: ${res.body}");

    final data = _decode(res.body);
    if (data is List) return data;
    return (data['todos'] as List?) ?? [];
  }

  /// ---- INSERT TODO ----
  Future<Map<String, dynamic>> insertTodo({
    required int accountId,
    required String date,
    required String todo,
    required bool done,
  }) async {
    final res = await http.post(
      Uri.parse("${baseUrl}post.php?action=insertTodo"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "account_id": accountId,
        "date": date,
        "todo": todo,
        "done": done,
      }),
    );

    print("➡️ [INSERT TODO] STATUS: ${res.statusCode}");
    print("➡️ [INSERT TODO] BODY: ${res.body}");

    return _decode(res.body);
  }

  /// ---- UPDATE TODO ----
  Future<Map<String, dynamic>> updateTodo({
    required int todoId,
    required String date,
    required String todo,
    required bool done,
  }) async {
    final res = await http.post(
      Uri.parse("${baseUrl}post.php?action=updateTodo"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "todo_id": todoId,
        "date": date,
        "todo": todo,
        "done": done,
      }),
    );

    print("➡️ [UPDATE TODO] STATUS: ${res.statusCode}");
    print("➡️ [UPDATE TODO] BODY: ${res.body}");

    return _decode(res.body);
  }

  /// ---- DELETE TODO ----
  Future<Map<String, dynamic>> deleteTodo(int todoId) async {
    final res = await http.post(
      Uri.parse("${baseUrl}post.php?action=deleteTodo"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"todo_id": todoId}),
    );

    print("➡️ [DELETE TODO] STATUS: ${res.statusCode}");
    print("➡️ [DELETE TODO] BODY: ${res.body}");

    return _decode(res.body);
  }

  /// ---- DECODE ----
  dynamic _decode(String body) {
    try {
      return json.decode(body);
    } catch (_) {
      return {"status": "error", "message": "Invalid JSON", "raw": body};
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_item.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final todos = Provider.of<TodoProvider>(context, listen: false);
    if (auth.user != null) {
      todos.fetchTodos(auth.user!.accountId);
    }
  }

  void _addTask(BuildContext context) async {
    final todoController = TextEditingController();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final todos = Provider.of<TodoProvider>(context, listen: false);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nouvelle tâche"),
        content: TextField(
          controller: todoController,
          decoration: const InputDecoration(
            labelText: "Tâche",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, todoController.text),
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      await todos.addTodo(
        accountId: auth.user!.accountId,
        todo: result,
      );
    }
  }

  void _showHistory(BuildContext context) {
    final todos = Provider.of<TodoProvider>(context, listen: false);
    final history = todos.getCompleted();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Historique des tâches accomplies"),
        content: SizedBox(
          width: double.maxFinite,
          child: history.isEmpty
              ? const Text("Aucune tâche accomplie pour le moment")
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: history.length,
                  itemBuilder: (_, i) {
                    final todo = history[i];
                    return ListTile(
                      title: Text(
                        todo.todo,
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      subtitle: Text("Fait le : ${todo.date}"),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: _isSearching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Rechercher une tâche...",
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) => setState(() => _searchQuery = value),
              )
            : const Text("Mes Tâches", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) _searchQuery = "";
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => _showHistory(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => _addTask(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todos, _) {
          if (todos.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final displayedTodos = _isSearching
              ? todos.search(_searchQuery)
              : todos.todos;

          if (displayedTodos.isEmpty) {
            return const Center(
              child: Text(
                "Aucune tâche pour le moment",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: displayedTodos.length,
            itemBuilder: (_, i) => TodoItem(todo: displayedTodos[i]),
          );
        },
      ),
    );
  }
}
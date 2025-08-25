import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  final ApiService _api = ApiService();

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  Future<void> login(String email, String password) async {
    final data = await _api.login(email, password);
    if (data['status'] == 'success' && data['user'] != null) {
      _user = User.fromJson(data['user']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('accountId', _user!.accountId);
      await prefs.setString('email', _user!.email);
      notifyListeners();
    } else {
      throw Exception(data['message'] ?? "Échec de connexion");
    }
  }

  Future<void> signup(String email, String password) async {
    final data = await _api.signup(email, password);
    if (data['status'] != 'success') {
      throw Exception(data['message'] ?? "Échec d'inscription");
    }
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('accountId');
    final email = prefs.getString('email');
    if (id != null && email != null) {
      _user = User(accountId: id, email: email);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _user = null;
    notifyListeners();
  }
}
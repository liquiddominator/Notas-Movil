import 'package:flutter/material.dart';
import 'package:project_movil/helper/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  User? _currentUser;
  final DatabaseHelper _db = DatabaseHelper();

  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;

  Future<bool> login(String username, String password) async {
    try {
      final userData = await _db.getUser(username, password);
      if (userData != null) {
        _currentUser = User.fromMap(userData);
        _isAuthenticated = true;
        
        // Guardar el estado de la sesión
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', _currentUser!.id!);
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String username, String password) async {
    try {
      final user = User(username: username, password: password);
      final id = await _db.insertUser(user.toMap());
      if (id > 0) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> checkAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null) {
      // Aquí podrías cargar los datos del usuario si es necesario
      _isAuthenticated = true;
      notifyListeners();
    }
  }
}
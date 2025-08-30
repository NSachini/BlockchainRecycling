import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
  
  void _setUser(User? user) {
    _user = user;
    notifyListeners();
  }
  
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await ApiService.register(
        username: username,
        email: email,
        password: password,
      );
      
      if (response['success']) {
        _setUser(User.fromJson(response['user']));
        return true;
      } else {
        _setError(response['message']);
        return false;
      }
    } catch (e) {
      _setError('Registration failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await ApiService.login(
        email: email,
        password: password,
      );
      
      if (response['success']) {
        _setUser(User.fromJson(response['user']));
        return true;
      } else {
        _setError(response['message']);
        return false;
      }
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> logout() async {
    await ApiService.removeToken();
    _setUser(null);
    _setError(null);
  }
  
  Future<void> checkAuthStatus() async {
    final token = await ApiService.getToken();
    if (token != null) {
      try {
        final response = await ApiService.getCurrentUser();
        if (response['success']) {
          _setUser(User.fromJson(response['user']));
        } else {
          await logout();
        }
      } catch (e) {
        await logout();
      }
    }
  }
  
  void clearError() {
    _setError(null);
  }
}

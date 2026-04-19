import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../config/app_config.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.post(
        AppConfig.registerEndpoint,
        {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        },
      );

      await _handleAuthResponse(response);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.post(
        AppConfig.loginEndpoint,
        {
          'email': email,
          'password': password,
        },
      );

      await _handleAuthResponse(response);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Admin Login
  Future<bool> adminLogin({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.post(
        AppConfig.adminLoginEndpoint,
        {
          'email': email,
          'password': password,
        },
      );

      await _handleAuthResponse(response);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Handle Auth Response
  Future<void> _handleAuthResponse(Map<String, dynamic> response) async {
    if (response['success'] == true) {
      _token = response['token'];
      _user = User.fromJson(response['user']);

      // Store in secure storage
      await _apiService.storeToken(_token!);
      await _apiService.storeUser(response['user']);

      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _user = null;
    _token = null;
    await _apiService.clearStorage();
    notifyListeners();
  }

  // Try Auto Login
  Future<bool> tryAutoLogin() async {
    try {
      final storedUser = await _apiService.getStoredUser();
      final storedToken = await _apiService.getStoredToken();

      if (storedUser != null && storedToken != null) {
        _user = User.fromJson(storedUser);
        _token = storedToken;
        notifyListeners();
        return true;
      }
    } catch (e) {
      await logout();
    }
    return false;
  }

  // Refresh user data from storage
  Future<void> refreshUser() async {
    try {
      final storedUser = await _apiService.getStoredUser();
      if (storedUser != null) {
        _user = User.fromJson(storedUser);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing user: $e');
      }
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
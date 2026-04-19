import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _storage = const FlutterSecureStorage();

  // GET Request
  Future<dynamic> get(String endpoint) async {
    try {
      final token = await _storage.read(key: AppConfig.tokenKey);
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.apiPrefix}$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(milliseconds: AppConfig.apiTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST Request
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final token = await _storage.read(key: AppConfig.tokenKey);
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.apiPrefix}$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      ).timeout(const Duration(milliseconds: AppConfig.apiTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PUT Request
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final token = await _storage.read(key: AppConfig.tokenKey);
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.apiPrefix}$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      ).timeout(const Duration(milliseconds: AppConfig.apiTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // DELETE Request
  Future<dynamic> delete(String endpoint) async {
    try {
      final token = await _storage.read(key: AppConfig.tokenKey);
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.apiPrefix}$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(milliseconds: AppConfig.apiTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Handle Response
  dynamic _handleResponse(http.Response response) {
    final responseData = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData;
    } else {
      throw Exception(responseData['message'] ?? 'Something went wrong');
    }
  }

  // Store Token
  Future<void> storeToken(String token) async {
    await _storage.write(key: AppConfig.tokenKey, value: token);
  }

  // Store User Data
  Future<void> storeUser(Map<String, dynamic> user) async {
    await _storage.write(key: AppConfig.userKey, value: json.encode(user));
  }

  // Clear Storage
  Future<void> clearStorage() async {
    await _storage.delete(key: AppConfig.tokenKey);
    await _storage.delete(key: AppConfig.userKey);
  }

  // Get Stored User
  Future<Map<String, dynamic>?> getStoredUser() async {
    final userData = await _storage.read(key: AppConfig.userKey);
    if (userData != null) {
      return json.decode(userData);
    }
    return null;
  }

  // Get Stored Token (public method for AuthProvider)
  Future<String?> getStoredToken() async {
    return await _storage.read(key: AppConfig.tokenKey);
  }
}
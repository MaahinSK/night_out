class AppConfig {
  // API Configuration
  static const String baseUrl = 'http://10.0.2.2:5000'; // For Android Emulator
  // static const String baseUrl = 'http://localhost:5000'; // For iOS Simulator
  // static const String baseUrl = 'http://YOUR_IP_ADDRESS:5000'; // For Real Device

  static const String apiPrefix = '/api';

  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String adminLoginEndpoint = '/auth/admin-login';
  static const String registerEndpoint = '/auth/register';
  static const String profileEndpoint = '/auth/profile';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // App Settings
  static const String appName = 'Night Out';
  static const int apiTimeout = 30000; // 30 seconds
}
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../config/app_config.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<dynamic> _favorites = [];
  List<dynamic> _bookings = [];
  bool _isLoading = false;

  List<dynamic> get favorites => _favorites;
  List<dynamic> get bookings => _bookings;
  bool get isLoading => _isLoading;

  // Fetch user profile
  Future<void> fetchProfile() async {
    _setLoading(true);
    try {
      final response = await _apiService.get(AppConfig.profileEndpoint);
      if (response['success'] == true) {
        // Update user data
        _favorites = response['user']['favorites'] ?? [];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add to favorites
  Future<bool> addToFavorites(String pubId) async {
    try {
      // This endpoint will be created later
      // final response = await _apiService.post('/favorites/add', {'pubId': pubId});
      _favorites.add(pubId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding to favorites: $e');
      return false;
    }
  }

  // Remove from favorites
  Future<bool> removeFromFavorites(String pubId) async {
    try {
      // This endpoint will be created later
      // final response = await _apiService.delete('/favorites/remove/$pubId');
      _favorites.remove(pubId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error removing from favorites: $e');
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
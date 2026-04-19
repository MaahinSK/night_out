import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/pub_model.dart';
import '../services/api_service.dart';
import '../config/app_config.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Pub> _favoritePubs = [];
  List<String> _favoriteIds = [];
  bool _isLoading = false;
  String? _error;

  List<Pub> get favoritePubs => _favoritePubs;
  List<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch favorites
  Future<void> fetchFavorites() async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.get(AppConfig.favoritesEndpoint);

      if (response['success'] == true) {
        final List<dynamic> favoritesJson = response['favorites'] ?? [];
        _favoritePubs = favoritesJson.map((json) => Pub.fromJson(json)).toList();
        _favoriteIds = _favoritePubs.map((pub) => pub.id).toList();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching favorites: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add to favorites
  Future<bool> addToFavorites(String pubId) async {
    try {
      final response = await _apiService.post(
        '${AppConfig.favoritesEndpoint}/$pubId',
        {},
      );

      if (response['success'] == true) {
        await fetchFavorites();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding to favorites: $e');
      return false;
    }
  }

  // Remove from favorites
  Future<bool> removeFromFavorites(String pubId) async {
    try {
      final response = await _apiService.delete(
        '${AppConfig.favoritesEndpoint}/$pubId',
      );

      if (response['success'] == true) {
        _favoritePubs.removeWhere((pub) => pub.id == pubId);
        _favoriteIds.remove(pubId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error removing from favorites: $e');
      return false;
    }
  }

  // Check if pub is favorite
  bool isFavorite(String pubId) {
    return _favoriteIds.contains(pubId);
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
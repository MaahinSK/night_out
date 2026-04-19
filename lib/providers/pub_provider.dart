import 'package:flutter/foundation.dart';
import '../models/pub_model.dart';
import '../services/api_service.dart';
import '../config/app_config.dart';

class PubProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Pub> _pubs = [];
  List<Pub> _featuredPubs = [];
  Pub? _selectedPub;
  bool _isLoading = false;
  String? _error;

  List<Pub> get pubs => _pubs;
  List<Pub> get featuredPubs => _featuredPubs;
  Pub? get selectedPub => _selectedPub;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all pubs
  Future<void> fetchPubs({bool featured = false, int limit = 20}) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.get(
          '${AppConfig.pubsEndpoint}?featured=$featured&limit=$limit'
      );

      if (response['success'] == true) {
        final List<dynamic> pubsJson = response['pubs'] ?? [];
        _pubs = pubsJson.map((json) => Pub.fromJson(json)).toList();

        if (featured) {
          _featuredPubs = _pubs;
        }

        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching pubs: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Fetch single pub details
  Future<void> fetchPubById(String id) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.get('${AppConfig.pubsEndpoint}/$id');

      if (response['success'] == true) {
        _selectedPub = Pub.fromJson(response['pub']);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching pub: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Search pubs
  Future<void> searchPubs(String keyword) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.get('${AppConfig.pubsEndpoint}/search/$keyword');

      if (response['success'] == true) {
        final List<dynamic> pubsJson = response['pubs'] ?? [];
        _pubs = pubsJson.map((json) => Pub.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error searching pubs: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create pub (Admin only)
  // Create pub (Admin only)
  Future<bool> createPub(Map<String, dynamic> pubData) async {
    _setLoading(true);
    _error = null;

    try {
      print('Sending pub data to server: ${pubData.keys}');

      final response = await _apiService.post(AppConfig.pubsEndpoint, pubData);

      print('Server response: $response');

      if (response['success'] == true) {
        await fetchPubs();
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _error = e.toString();
      print('Error creating pub: $e');
      _setLoading(false);
      return false;
    }
  }

  // Update pub (Admin only)
  Future<bool> updatePub(String id, Map<String, dynamic> pubData) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.put('${AppConfig.pubsEndpoint}/$id', pubData);

      if (response['success'] == true) {
        await fetchPubs();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete pub (Admin only)
  Future<bool> deletePub(String id) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.delete('${AppConfig.pubsEndpoint}/$id');

      if (response['success'] == true) {
        await fetchPubs();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
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
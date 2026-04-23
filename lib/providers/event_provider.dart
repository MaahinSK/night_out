import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import '../config/app_config.dart';

class EventProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<EventModel> _events = [];
  List<EventModel> _featuredEvents = [];
  bool _isLoading = false;
  String? _error;

  List<EventModel> get events => _events;
  List<EventModel> get featuredEvents => _featuredEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEvents({bool featured = false}) async {
    _setLoading(true);
    _error = null;

    try {
      final endpoint = featured 
          ? '${AppConfig.eventsEndpoint}?featured=true' 
          : AppConfig.eventsEndpoint;
      
      final response = await _apiService.get(endpoint);

      if (response['success'] == true) {
        final List<dynamic> eventsJson = response['events'] ?? [];
        final List<EventModel> loadedEvents = eventsJson
            .map((json) => EventModel.fromJson(json))
            .toList();

        if (featured) {
          _featuredEvents = loadedEvents;
        } else {
          _events = loadedEvents;
        }
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching events: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createEvent(Map<String, dynamic> eventData) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.post(AppConfig.eventsEndpoint, eventData);

      if (response['success'] == true) {
        await fetchEvents();
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

  Future<bool> updateEvent(String id, Map<String, dynamic> eventData) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.put('${AppConfig.eventsEndpoint}/$id', eventData);

      if (response['success'] == true) {
        await fetchEvents();
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

  Future<bool> deleteEvent(String id) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.delete('${AppConfig.eventsEndpoint}/$id');

      if (response['success'] == true) {
        _events.removeWhere((e) => e.id == id);
        notifyListeners();
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

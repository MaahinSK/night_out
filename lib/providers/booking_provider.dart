import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../services/api_service.dart';
import '../config/app_config.dart';

class BookingProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Booking> _userBookings = [];
  List<Booking> _allBookings = [];
  bool _isLoading = false;
  String? _error;

  List<Booking> get userBookings => _userBookings;
  List<Booking> get allBookings => _allBookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Booking> get upcomingBookings {
    final now = DateTime.now();
    return _userBookings
        .where((b) => b.bookingDate.isAfter(now) && b.status == 'confirmed')
        .toList();
  }

  List<Booking> get pastBookings {
    final now = DateTime.now();
    return _userBookings
        .where((b) => b.bookingDate.isBefore(now) || b.status == 'completed')
        .toList();
  }

  List<Booking> get cancelledBookings {
    return _userBookings.where((b) => b.status == 'cancelled').toList();
  }

  // Get user bookings
  Future<void> fetchUserBookings() async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.get(AppConfig.userBookingsEndpoint);

      if (response['success'] == true) {
        final List<dynamic> bookingsJson = response['bookings'] ?? [];
        _userBookings = bookingsJson.map((json) => Booking.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching bookings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get all bookings (Admin only)
  Future<void> fetchAllBookings() async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.get(AppConfig.adminBookingsEndpoint);

      if (response['success'] == true) {
        final List<dynamic> bookingsJson = response['bookings'] ?? [];
        _allBookings = bookingsJson.map((json) => Booking.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching all bookings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create booking
  Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.post(AppConfig.bookingsEndpoint, bookingData);

      if (response['success'] == true) {
        await fetchUserBookings();
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

  // Cancel booking
  Future<bool> cancelBooking(String id) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.put(
        '${AppConfig.bookingsEndpoint}/$id/status',
        {'status': 'cancelled'},
      );

      if (response['success'] == true) {
        await fetchUserBookings();
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

  // Update booking status (Admin only)
  Future<bool> updateBookingStatus(String id, String status) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.put(
        '${AppConfig.bookingsEndpoint}/$id/status',
        {'status': status},
      );

      if (response['success'] == true) {
        await fetchAllBookings();
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
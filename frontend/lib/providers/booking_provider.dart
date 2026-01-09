import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();
  
  List<Booking> _bookings = [];
  List<Booking> _upcomingBookings = [];
  List<Booking> _pastBookings = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = false;
  String? _error;

  List<Booking> get bookings => _bookings;
  List<Booking> get upcomingBookings => _upcomingBookings;
  List<Booking> get pastBookings => _pastBookings;
  Map<String, dynamic> get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMyBookings({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookings = await _bookingService.getMyBookings(status: status);
      
      // Separate upcoming and past
      final now = DateTime.now();
      _upcomingBookings = _bookings.where((b) => b.isUpcoming).toList();
      _pastBookings = _bookings.where((b) => b.isPast).toList();
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDashboardData({bool isAdmin = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = isAdmin
          ? await _bookingService.getAdminDashboard()
          : await _bookingService.getUserDashboard();

      if (data.isNotEmpty) {
        final upcomingJson = data['upcoming_bookings'] ?? [];
        final pastJson = data['past_bookings'] ?? data['today_bookings'] ?? [];
        
        _upcomingBookings = (upcomingJson as List)
            .map((json) => Booking.fromJson(json))
            .toList();
        
        _pastBookings = (pastJson as List)
            .map((json) => Booking.fromJson(json))
            .toList();
        
        _statistics = data['statistics'] ?? {};
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBooking({
    required int adminId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String timezone,
    required String meetingPurpose,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _bookingService.createBooking(
        adminId: adminId,
        date: date,
        startTime: startTime,
        endTime: endTime,
        timezone: timezone,
        meetingPurpose: meetingPurpose,
        notes: notes,
      );

      if (result['success']) {
        await loadMyBookings();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelBooking(int bookingId) async {
    try {
      final success = await _bookingService.cancelBooking(bookingId);
      if (success) {
        await loadMyBookings();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rescheduleBooking({
    required int bookingId,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? meetingPurpose,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _bookingService.rescheduleBooking(
        bookingId: bookingId,
        date: date,
        startTime: startTime,
        endTime: endTime,
        meetingPurpose: meetingPurpose,
      );

      if (result['success']) {
        await loadMyBookings();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> getGoogleAuthUrl() async {
    _isLoading = true;
    notifyListeners();
    try {
      final url = await _bookingService.getGoogleAuthUrl();
      return url;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

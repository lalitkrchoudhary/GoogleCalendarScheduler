import '../models/booking.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class BookingService {
  final ApiService _apiService = ApiService();

  Future<List<Booking>> getMyBookings({String? status}) async {
    try {
      final queryParams = status != null ? {'status': status} : null;
      final response = await _apiService.get(
        ApiConfig.bookingsUrl,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        // Handle paginated response
        final data = response.data;
        final List bookingsJson = data is Map ? (data['results'] ?? []) : data;
        return bookingsJson.map((json) => Booking.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getUserDashboard() async {
    try {
      final response = await _apiService.get(ApiConfig.userDashboardUrl);
      
      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      print('Error fetching user dashboard: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getAdminDashboard() async {
    try {
      final response = await _apiService.get(ApiConfig.adminDashboardUrl);
      
      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      print('Error fetching admin dashboard: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> createBooking({
    required int adminId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String timezone,
    required String meetingPurpose,
    String? notes,
  }) async {
    try {
      print('Creating booking with adminId: $adminId, date: $date, startTime: $startTime');
      
      final response = await _apiService.post(
        ApiConfig.bookingsUrl,
        data: {
          'admin': adminId,
          'date': date.toIso8601String().split('T')[0],
          'start_time': startTime,
          'end_time': endTime,
          'timezone': timezone,
          'meeting_purpose': meetingPurpose,
          if (notes != null) 'notes': notes,
        },
      );

      print('Booking response status: ${response.statusCode}');
      print('Booking response data: ${response.data}');

      if (response.statusCode == 201) {
        return {
          'success': true,
          'booking': Booking.fromJson(response.data),
        };
      }

      return {
        'success': false,
        'error': response.data['detail'] ?? response.data.toString() ?? 'Failed to create booking'
      };
    } catch (e) {
      print('Error creating booking: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<bool> cancelBooking(int bookingId) async {
    try {
      final response = await _apiService.post(
        ApiConfig.cancelBookingUrl(bookingId),
        data: {},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error cancelling booking: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> rescheduleBooking({
    required int bookingId,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? meetingPurpose,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.rescheduleBookingUrl(bookingId),
        data: {
          'date': date.toIso8601String().split('T')[0],
          'start_time': startTime,
          'end_time': endTime,
          if (meetingPurpose != null) 'meeting_purpose': meetingPurpose,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'booking': Booking.fromJson(response.data['booking']),
        };
      }

      return {'success': false, 'error': 'Failed to reschedule'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  Future<String?> getGoogleAuthUrl() async {
    try {
      final response = await _apiService.get(ApiConfig.googleAuthUrl);
      if (response.statusCode == 200) {
        return response.data['auth_url'];
      }
      return null;
    } catch (e) {
      print('Error fetching Google auth URL: $e');
      return null;
    }
  }
}

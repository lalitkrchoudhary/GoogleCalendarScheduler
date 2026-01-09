import '../models/availability.dart';
import '../models/user.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class AvailabilityService {
  final ApiService _apiService = ApiService();

  Future<List<User>> getAdmins() async {
    try {
      final response = await _apiService.get(ApiConfig.adminsUrl);
      
      if (response.statusCode == 200) {
        // Handle paginated response
        final data = response.data;
        final List adminsJson = data is Map ? (data['results'] ?? []) : data;
        return adminsJson.map((json) => User.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching admins: $e');
      return [];
    }
  }

  Future<List<Availability>> getAvailabilities({
    int? adminId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (adminId != null) queryParams['admin'] = adminId;
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _apiService.get(
        ApiConfig.availabilityUrl,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        // Handle paginated response
        final data = response.data;
        final List availJson = data is Map ? (data['results'] ?? []) : data;
        return availJson.map((json) => Availability.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching availabilities: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getAvailableSlots({
    required int adminId,
    required DateTime date,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConfig.availableSlotsUrl,
        queryParameters: {
          'admin': adminId,
          'date': date.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      print('Error fetching available slots: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> createAvailability({
    required DateTime date,
    required String startTime,
    required String endTime,
    int slotDuration = 30,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.availabilityUrl,
        data: {
          'date': date.toIso8601String().split('T')[0],
          'start_time': startTime,
          'end_time': endTime,
          'slot_duration': slotDuration,
        },
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'availability': Availability.fromJson(response.data),
        };
      }

      return {
        'success': false,
        'error': response.data['detail'] ?? 'Failed to create availability'
      };
    } catch (e) {
      print('Error creating availability: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<bool> deleteAvailability(int id) async {
    try {
      final response = await _apiService.delete(
        '${ApiConfig.availabilityUrl}$id/',
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error deleting availability: $e');
      return false;
    }
  }
}

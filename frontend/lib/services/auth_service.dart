import '../models/user.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    String role = 'user',
    String timezone = 'UTC',
    String? phoneNumber,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.registerUrl,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'password_confirm': passwordConfirm,
          'role': role,
          'timezone': timezone,
          if (phoneNumber != null) 'phone_number': phoneNumber,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data;
        final tokens = data['tokens'];
        
        // Save tokens
        await _apiService.saveTokens(
          tokens['access'],
          tokens['refresh'],
        );

        return {
          'success': true,
          'user': User.fromJson(data['user']),
        };
      }

      return {'success': false, 'error': 'Registration failed'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.loginUrl,
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final tokens = data['tokens'];
        
        // Save tokens
        await _apiService.saveTokens(
          tokens['access'],
          tokens['refresh'],
        );

        return {
          'success': true,
          'user': User.fromJson(data['user']),
        };
      }

      return {'success': false, 'error': 'Login failed'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<void> logout() async {
    await _apiService.clearTokens();
  }

  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiService.get(ApiConfig.currentUserUrl);
      
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
    } catch (e) {
      print('Error getting current user: $e');
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiService.getAccessToken();
    return token != null;
  }
}

class ApiConfig {
  // API Base URL - Change this for production
  static const String baseUrl = 'http://localhost:8000/api';
  
  // Endpoints
  static const String authEndpoint = '/auth';
  static const String availabilityEndpoint = '/availability';
  static const String bookingsEndpoint = '/bookings';
  
  // Full URLs
  static String get registerUrl => '$baseUrl$authEndpoint/register/';
  static String get loginUrl => '$baseUrl$authEndpoint/login/';
  static String get refreshTokenUrl => '$baseUrl$authEndpoint/token/refresh/';
  static String get currentUserUrl => '$baseUrl$authEndpoint/me/';
  static String get adminsUrl => '$baseUrl$authEndpoint/admins/';
  
  static String get availabilityUrl => '$baseUrl$availabilityEndpoint/';
  static String get availableSlotsUrl => '$baseUrl$availabilityEndpoint/slots/';
  
  static String get bookingsUrl => '$baseUrl$bookingsEndpoint/';
  static String get userDashboardUrl => '$baseUrl$bookingsEndpoint/dashboard/user/';
  static String get adminDashboardUrl => '$baseUrl$bookingsEndpoint/dashboard/admin/';
  
  static String get googleAuthUrl => '$baseUrl$authEndpoint/google/url/';
  
  static String bookingDetailUrl(int id) => '$baseUrl$bookingsEndpoint/$id/';
  static String cancelBookingUrl(int id) => '$baseUrl$bookingsEndpoint/$id/cancel/';
  static String rescheduleBookingUrl(int id) => '$baseUrl$bookingsEndpoint/$id/reschedule/';
  
  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

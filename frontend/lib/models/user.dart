class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role; // 'user', 'admin', 'superadmin'
  final String timezone;
  final String? phoneNumber;
  final DateTime dateJoined;
  final bool isActive;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.timezone,
    this.phoneNumber,
    required this.dateJoined,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print('Parsing user from JSON: $json');
    final userId = json['id'];
    print('User ID from JSON: $userId (type: ${userId.runtimeType})');
    
    return User(
      id: json['id'] ?? 0, // Provide default value for null
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? 'user',
      timezone: json['timezone'] ?? 'UTC',
      phoneNumber: json['phone_number'],
      dateJoined: DateTime.parse(json['date_joined'] ?? DateTime.now().toIso8601String()),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'timezone': timezone,
      'phone_number': phoneNumber,
      'date_joined': dateJoined.toIso8601String(),
      'is_active': isActive,
    };
  }

  String get fullName => '$firstName $lastName'.trim().isEmpty 
      ? username 
      : '$firstName $lastName'.trim();

  bool get isAdmin => role == 'admin' || role == 'superadmin';
  bool get isSuperAdmin => role == 'superadmin';
  bool get isRegularUser => role == 'user';
}

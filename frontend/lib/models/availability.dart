import 'user.dart';

class Availability {
  final int id;
  final int adminId;
  final User? adminDetails;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int slotDuration; // in minutes
  final bool isActive;
  final int? totalSlots;
  final DateTime createdAt;
  final DateTime updatedAt;

  Availability({
    required this.id,
    required this.adminId,
    this.adminDetails,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.slotDuration,
    this.isActive = true,
    this.totalSlots,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      id: json['id'],
      adminId: json['admin'],
      adminDetails: json['admin_details'] != null 
          ? User.fromJson(json['admin_details']) 
          : null,
      date: DateTime.parse(json['date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      slotDuration: json['slot_duration'],
      isActive: json['is_active'] ?? true,
      totalSlots: json['total_slots'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin': adminId,
      'date': date.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'slot_duration': slotDuration,
      'is_active': isActive,
    };
  }
}

class TimeSlot {
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final int? bookingId;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.bookingId,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: json['start_time'],
      endTime: json['end_time'],
      isAvailable: json['is_available'],
      bookingId: json['booking_id'],
    );
  }
}

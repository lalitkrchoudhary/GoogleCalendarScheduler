import 'user.dart';

class Booking {
  final int id;
  final int userId;
  final User? userDetails;
  final int adminId;
  final User? adminDetails;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String timezone;
  final String meetingPurpose;
  final String? meetingLink;
  final String? calendarEventId;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.userId,
    this.userDetails,
    required this.adminId,
    this.adminDetails,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.timezone,
    required this.meetingPurpose,
    this.meetingLink,
    this.calendarEventId,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['user'],
      userDetails: json['user_details'] != null 
          ? User.fromJson(json['user_details']) 
          : null,
      adminId: json['admin'],
      adminDetails: json['admin_details'] != null 
          ? User.fromJson(json['admin_details']) 
          : null,
      date: DateTime.parse(json['date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      timezone: json['timezone'],
      meetingPurpose: json['meeting_purpose'],
      meetingLink: json['meeting_link'],
      calendarEventId: json['calendar_event_id'],
      status: json['status'],
      notes: json['notes'],
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
      'timezone': timezone,
      'meeting_purpose': meetingPurpose,
      'notes': notes,
    };
  }

  bool get isUpcoming {
    final now = DateTime.now();
    final bookingDateTime = DateTime(
      date.year, 
      date.month, 
      date.day,
    );
    return bookingDateTime.isAfter(now) || bookingDateTime.isAtSameMomentAs(now);
  }

  bool get isPast => !isUpcoming;
  bool get isConfirmed => status == 'confirmed';
  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';
}

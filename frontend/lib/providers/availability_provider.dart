import 'package:flutter/material.dart';
import '../models/availability.dart';
import '../models/user.dart';
import '../services/availability_service.dart';

class AvailabilityProvider with ChangeNotifier {
  final AvailabilityService _service = AvailabilityService();
  
  List<User> _admins = [];
  List<Availability> _availabilities = [];
  List<TimeSlot> _timeSlots = [];
  bool _isLoading = false;
  String? _error;

  List<User> get admins => _admins;
  List<Availability> get availabilities => _availabilities;
  List<TimeSlot> get timeSlots => _timeSlots;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAdmins() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _admins = await _service.getAdmins();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAvailabilities({
    int? adminId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _availabilities = await _service.getAvailabilities(
        adminId: adminId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAvailableSlots({
    required int adminId,
    required DateTime date,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _service.getAvailableSlots(
        adminId: adminId,
        date: date,
      );

      if (data.isNotEmpty && data['slots'] != null) {
        final slotsJson = data['slots'] as List;
        _timeSlots = slotsJson.map((json) => TimeSlot.fromJson(json)).toList();
      } else {
        _timeSlots = [];
      }
    } catch (e) {
      _error = e.toString();
      _timeSlots = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAvailability({
    required DateTime date,
    required String startTime,
    required String endTime,
    int slotDuration = 30,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.createAvailability(
        date: date,
        startTime: startTime,
        endTime: endTime,
        slotDuration: slotDuration,
      );

      if (result['success']) {
        await loadAvailabilities();
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

  Future<bool> deleteAvailability(int id) async {
    try {
      final success = await _service.deleteAvailability(id);
      if (success) {
        await loadAvailabilities();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

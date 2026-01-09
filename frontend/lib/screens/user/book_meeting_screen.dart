import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../providers/availability_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/user.dart';
import '../../models/availability.dart';

class BookMeetingScreen extends StatefulWidget {
  const BookMeetingScreen({super.key});

  @override
  State<BookMeetingScreen> createState() => _BookMeetingScreenState();
}

class _BookMeetingScreenState extends State<BookMeetingScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  User? _selectedAdmin;
  TimeSlot? _selectedSlot;
  final _purposeController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load admins
    Future.microtask(() {
      context.read<AvailabilityProvider>().loadAdmins();
    });
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Meeting'),
      ),
      body: Consumer<AvailabilityProvider>(
        builder: (context, availabilityProvider, child) {
          if (availabilityProvider.admins.isEmpty && availabilityProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step 1: Select Admin
                _buildSectionTitle('1. Select Admin'),
                const SizedBox(height: 12),
                _buildAdminSelector(availabilityProvider.admins),
                
                if (_selectedAdmin != null) ...[
                  const SizedBox(height: 24),
                  // Step 2: Select Date
                  _buildSectionTitle('2. Select Date'),
                  const SizedBox(height: 12),
                  _buildCalendar(),
                  
                  const SizedBox(height: 24),
                  // Step 3: Select Time Slot
                  _buildSectionTitle('3. Select Time Slot'),
                  const SizedBox(height: 12),
                  _buildTimeSlots(availabilityProvider),
                  
                  if (_selectedSlot != null) ...[
                    const SizedBox(height: 24),
                    // Step 4: Meeting Details
                    _buildSectionTitle('4. Meeting Details'),
                    const SizedBox(height: 12),
                    _buildMeetingForm(),
                    
                    const SizedBox(height: 24),
                    _buildBookButton(),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildAdminSelector(List<User> admins) {
    return Card(
      child: Column(
        children: admins.map((admin) {
          final isSelected = _selectedAdmin?.id == admin.id;
          return ListTile(
            selected: isSelected,
            leading: CircleAvatar(
              backgroundColor: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300],
              child: Text(
                admin.username[0].toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(admin.fullName),
            subtitle: Text(admin.email),
            trailing: isSelected
                ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                : null,
            onTap: () {
              setState(() {
                _selectedAdmin = admin;
                _selectedSlot = null;
              });
              // Load available slots for the selected date
              _loadSlotsForDate(_selectedDay);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 90)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          if (selectedDay.isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _selectedSlot = null;
            });
            _loadSlotsForDate(selectedDay);
          }
        },
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlots(AvailabilityProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final slots = provider.timeSlots;

    if (slots.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No available slots for this date',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((slot) {
        final isSelected = _selectedSlot?.startTime == slot.startTime;
        final isAvailable = slot.isAvailable;

        return ChoiceChip(
          label: Text('${slot.startTime} - ${slot.endTime}'),
          selected: isSelected,
          onSelected: isAvailable
              ? (selected) {
                  setState(() {
                    _selectedSlot = selected ? slot : null;
                  });
                }
              : null,
          selectedColor: Theme.of(context).primaryColor,
          labelStyle: TextStyle(
            color: isSelected
                ? Colors.white
                : isAvailable
                    ? Colors.black
                    : Colors.grey,
          ),
          backgroundColor: isAvailable ? null : Colors.grey[200],
          disabledColor: Colors.grey[200],
        );
      }).toList(),
    );
  }

  Widget _buildMeetingForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _purposeController,
              decoration: const InputDecoration(
                labelText: 'Meeting Purpose *',
                hintText: 'e.g., Project discussion',
              ),
              maxLength: 200,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes (Optional)',
                hintText: 'Any specific topics or questions',
              ),
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: bookingProvider.isLoading ? null : _bookMeeting,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: bookingProvider.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Book Meeting',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        );
      },
    );
  }

  void _loadSlotsForDate(DateTime date) {
    if (_selectedAdmin != null) {
      context.read<AvailabilityProvider>().loadAvailableSlots(
            adminId: _selectedAdmin!.id,
            date: date,
          );
    }
  }

  Future<void> _bookMeeting() async {
    if (_purposeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a meeting purpose'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Debug logging
    print('Selected admin: $_selectedAdmin');
    print('Selected admin ID: ${_selectedAdmin?.id}');
    print('Selected slot: $_selectedSlot');
    print('Selected day: $_selectedDay');

    if (_selectedAdmin == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an admin and time slot'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await context.read<BookingProvider>().createBooking(
          adminId: _selectedAdmin!.id,
          date: _selectedDay,
          startTime: _selectedSlot!.startTime,
          endTime: _selectedSlot!.endTime,
          timezone: 'UTC', // TODO: Get user's timezone
          meetingPurpose: _purposeController.text,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );

    if (mounted) {
      if (success) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your meeting has been booked successfully!'),
                const SizedBox(height: 16),
                Text('Date: ${DateFormat('MMM d, yyyy').format(_selectedDay)}'),
                Text('Time: ${_selectedSlot!.startTime} - ${_selectedSlot!.endTime}'),
                Text('With: ${_selectedAdmin!.fullName}'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back to dashboard
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<BookingProvider>().error ?? 'Failed to book meeting',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

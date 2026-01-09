
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking.dart';
import 'manage_availability_screen.dart';
import 'manage_bookings_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data when screen opens
    Future.microtask(() {
      if (mounted) {
        context.read<BookingProvider>().loadDashboardData(isAdmin: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BookingProvider>().loadDashboardData(isAdmin: true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<BookingProvider>().loadDashboardData(isAdmin: true);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return Text(
                    'Welcome, ${auth.user?.username ?? "Admin"}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  );
                },
              ),
              const SizedBox(height: 24),

              // Statistics Section
              Consumer<BookingProvider>(
                builder: (context, provider, child) {
                  final stats = provider.statistics;
                  final upcomingCount = provider.upcomingBookings.length;
                  
                  return Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Today',
                          value: (stats['today'] ?? 0).toString(),
                          icon: Icons.today,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Upcoming',
                          value: upcomingCount.toString(),
                          icon: Icons.calendar_month,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              
              Consumer<BookingProvider>(
                builder: (context, provider, child) {
                  final stats = provider.statistics;
                  return Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total',
                          value: (stats['total'] ?? 0).toString(),
                          icon: Icons.list_alt,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Pending',
                          value: (stats['pending'] ?? 0).toString(),
                          icon: Icons.pending_actions,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // Google Calendar Integration
              Card(
                child: ListTile(
                  leading: const Icon(Icons.link, color: Colors.blue),
                  title: const Text('Google Calendar Integration'),
                  subtitle: const Text('Connect to sync bookings and create Meet links'),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      // Get auth URL and launch it
                      try {
                        final authUrl = await Provider.of<BookingProvider>(context, listen: false)
                            .getGoogleAuthUrl();
                        if (authUrl != null && context.mounted) {
                          final Uri url = Uri.parse(authUrl);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to initiate connection: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      elevation: 0,
                      side: const BorderSide(color: Colors.blue),
                    ),
                    child: const Text('Connect'),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _QuickActionCard(
                    icon: Icons.edit_calendar,
                    title: 'Manage Availability',
                    color: Colors.blue,
                    onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageAvailabilityScreen(),
                        ),
                      );
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.calendar_month,
                    title: 'View Bookings',
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageBookingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Bookings List
              Text(
                "Today's Bookings",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Consumer<BookingProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  final upcomingBookings = provider.upcomingBookings;

                  if (upcomingBookings.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No upcoming bookings for today',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: upcomingBookings.take(5).map((booking) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              booking.userDetails?.username[0].toUpperCase() ?? 'U',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(booking.meetingPurpose),
                          subtitle: Text(
                            '${booking.startTime} - ${booking.endTime}\nWith: ${booking.userDetails?.fullName ?? 'User'}',
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Join Button
                              if (booking.meetingLink != null && booking.meetingLink!.isNotEmpty)
                                Tooltip(
                                  message: 'Join Google Meet',
                                  child: IconButton(
                                    icon: const Icon(Icons.video_call),
                                    color: Colors.blue,
                                    onPressed: () async {
                                      final Uri url = Uri.parse(booking.meetingLink!);
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url, mode: LaunchMode.externalApplication);
                                      }
                                    },
                                  ),
                                ),
                                
                              const SizedBox(width: 8),

                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: booking.status == 'confirmed'
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: booking.status == 'confirmed'
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                                child: Text(
                                  booking.status.toUpperCase(),
                                  style: TextStyle(
                                    color: booking.status == 'confirmed'
                                        ? Colors.green
                                        : Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

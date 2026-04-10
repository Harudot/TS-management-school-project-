import 'package:flutter/material.dart';
import 'package:ts_management/widgets/home_widgets/home_header.dart';
import 'package:ts_management/widgets/home_widgets/home_actions.dart';
import 'package:ts_management/widgets/home_widgets/home_notifications.dart';
import 'package:ts_management/screens/schedule_screen.dart';
import 'package:ts_management/screens/map_screen.dart';
import 'package:ts_management/widgets/common/oxalis_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _notifications = [
    NotificationItem(
      title: 'Class Cancelled',
      subtitle: 'Math 101 class is cancelled today',
      time: '10 mins ago',
      icon: Icons.notifications_outlined,
    ),
    NotificationItem(
      title: 'New Assignment',
      subtitle: 'Programming assignment due Friday',
      time: '1 hour ago',
      icon: Icons.assignment_outlined,
    ),
    NotificationItem(
      title: 'Grade Posted',
      subtitle: 'Your Physics midterm grade is available',
      time: '3 hours ago',
      icon: Icons.grade_outlined,
    ),
    NotificationItem(
      title: 'Room Changed',
      subtitle: 'Chemistry lab moved to Room B204',
      time: 'Yesterday',
      icon: Icons.room_outlined,
    ),
    NotificationItem(
      title: 'Exam Reminder',
      subtitle: 'Final exam scheduled for next Monday',
      time: '2 days ago',
      icon: Icons.event_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12071F),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──
            OxalisAppBar(subtitle: 'Student', notifications: _notifications),

            // ── Scrollable Body ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  children: [
                    const HomeHeader(studentName: 'John', classCount: 3),
                    const SizedBox(height: 24),
                    HomeActions(
                      onAction: (action) {
                        if (action == 'schedule') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ScheduleScreen(),
                            ),
                          );
                        } else if (action == 'navigate' ||
                            action == 'find_path') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MapScreen(),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    const HomeNotifications(notifications: _notifications),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

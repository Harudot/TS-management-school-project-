import 'package:flutter/material.dart';
import 'package:ts_management/widgets/home_widgets/home_header.dart';
import 'package:ts_management/widgets/home_widgets/home_actions.dart';
import 'package:ts_management/widgets/home_widgets/home_notifications.dart';
import 'package:ts_management/screens/schedule_screen.dart';
import 'package:ts_management/screens/map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // TODO: Replace with real data from backend
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12071F),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top App Bar ──
            _AppBar(
              title: 'Oxalis Hub',
              subtitle: 'Student',
              onMenuTap: () {},
              onNotifTap: () {},
            ),

            // ── Scrollable Body ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  children: [
                    // ── Part 1: Welcome Header ──
                    const HomeHeader(studentName: 'John', classCount: 3),

                    const SizedBox(height: 24),

                    // ── Part 2: Quick Actions ──
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

                    // ── Part 3: Notifications ──
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

// ─────────────────────────────────────────────
// Shared App Bar
// ─────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  const _AppBar({
    required this.title,
    required this.subtitle,
    this.onMenuTap,
    this.onNotifTap,
    this.showBack = false,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotifTap;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          // Left: menu or back
          if (showBack)
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white.withOpacity(0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Back',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: onMenuTap,
              child: Icon(
                Icons.menu_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 24,
              ),
            ),

          // Center: title
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Right: bell
          GestureDetector(
            onTap: onNotifTap,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1E0D3A).withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Colors.white.withOpacity(0.7),
                      size: 20,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF9B6BFF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

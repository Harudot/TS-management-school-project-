import 'package:flutter/material.dart';
import 'package:ts_management/screens/map_screen.dart';
import 'package:ts_management/widgets/schedule_widgets/schedule_card.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with real data from backend
    final schedules = [
      const ScheduleItem(
        subject: 'Computer Science',
        time: '9:00 AM',
        room: 'Room 101',
        building: 'Main Building',
        teacher: 'Dr. Smith',
      ),
      const ScheduleItem(
        subject: 'Mathematics',
        time: '11:00 AM',
        room: 'Room 201',
        building: 'Main Building',
        teacher: 'Prof. Johnson',
      ),
      const ScheduleItem(
        subject: 'Chemistry Lab',
        time: '2:00 PM',
        room: 'Lab 301',
        building: 'Science Building',
        teacher: 'Dr. Lee',
      ),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFF12071F),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──
            _ScheduleAppBar(),

            // ── Page Title ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Today's Schedule",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // ── Date ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Monday, December 9, 2024',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Schedule List ──
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: schedules.length,
                itemBuilder: (_, i) => ScheduleCard(
                  item: schedules[i],
                  onFindPath: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MapScreen()),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          // ── Menu ──
          Icon(
            Icons.menu_rounded,
            color: Colors.white.withOpacity(0.7),
            size: 24,
          ),

          // ── Center ──
          const Expanded(
            child: Column(
              children: [
                Text(
                  'Oxalis Hub',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Student',
                  style: TextStyle(color: Color(0x73FFFFFF), fontSize: 11),
                ),
              ],
            ),
          ),

          // ── Bell ──
          Container(
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
        ],
      ),
    );
  }
}

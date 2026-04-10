import 'package:flutter/material.dart';
import 'package:ts_management/widgets/map_widgets/map_view.dart';
import 'package:ts_management/widgets/map_widgets/map_room_list.dart';
import 'package:ts_management/widgets/common/oxalis_app_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();

  // TODO: Replace with real data from backend
  static const _rooms = [
    RoomItem(
      room: 'Room 101',
      building: 'Main Building',
      floor: 'Floor 1',
      teacher: 'Dr. Smith (Computer Science)',
    ),
    RoomItem(
      room: 'Room 201',
      building: 'Main Building',
      floor: 'Floor 2',
      teacher: 'Prof. Johnson (Mathematics)',
    ),
    RoomItem(
      room: 'Lab 301',
      building: 'Science Building',
      floor: 'Floor 3',
      teacher: 'Dr. Lee (Chemistry)',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12071F),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──
            const OxalisAppBar(subtitle: 'Student', showBack: true),

            // ── Scrollable Body ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Page Title ──
                    const Text(
                      'Campus Map',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Search Bar ──
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E0D3A).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.07),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search rooms, buildings...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Colors.white.withOpacity(0.3),
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Part 1: Map Visual ──
                    const MapView(),

                    const SizedBox(height: 24),

                    // ── Part 2: Room List ──
                    MapRoomList(
                      rooms: _rooms,
                      onRoomTap: (room) {
                        // TODO: Navigate to room detail or show route
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom Label ──
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'CAMPUS MAP',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

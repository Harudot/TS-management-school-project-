import 'package:flutter/material.dart';

class ScheduleItem {
  const ScheduleItem({
    required this.subject,
    required this.time,
    required this.room,
    required this.building,
    required this.teacher,
  });
  final String subject;
  final String time;
  final String room;
  final String building;
  final String teacher;
}

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({super.key, required this.item, required this.onFindPath});

  final ScheduleItem item;
  final VoidCallback onFindPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E0D3A).withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Subject + Time ──
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF7B4FD4).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: Color(0xFF9B6BFF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.subject,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    item.time,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Room ──
          _InfoRow(
            icon: Icons.location_on_outlined,
            text: '${item.room} · ${item.building}',
          ),
          const SizedBox(height: 4),
          // ── Teacher ──
          _InfoRow(icon: Icons.person_outline_rounded, text: item.teacher),

          const SizedBox(height: 14),

          // ── Find Path Button ──
          SizedBox(
            width: double.infinity,
            height: 40,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9B6BFF), Color(0xFF7340E8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: onFindPath,
                icon: const Icon(
                  Icons.navigation_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                label: const Text(
                  'Find Path to Class',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.35), size: 14),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12),
        ),
      ],
    );
  }
}

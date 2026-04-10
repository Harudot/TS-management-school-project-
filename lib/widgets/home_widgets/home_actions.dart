import 'package:flutter/material.dart';

class HomeActions extends StatelessWidget {
  const HomeActions({super.key, required this.onAction});

  final void Function(String action) onAction;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(
        icon: Icons.navigation_outlined,
        label: 'Зам хайх',
        key: 'find_path',
      ),
      _ActionItem(
        icon: Icons.calendar_month_outlined,
        label: 'Миний хуваарь',
        key: 'schedule',
      ),
      _ActionItem(
        icon: Icons.notifications_outlined,
        label: 'Мэдээлэл',
        key: 'notifications',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK ACTIONS',
          style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                item: actions[0],
                onTap: () => onAction(actions[0].key),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                item: actions[1],
                onTap: () => onAction(actions[1].key),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ActionCard(item: actions[2], onTap: () => onAction(actions[2].key)),
      ],
    );
  }
}

class _ActionItem {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.key,
  });
  final IconData icon;
  final String label;
  final String key;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.item, required this.onTap});
  final _ActionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E0D3A).withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF7B4FD4).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: const Color(0xFF9B6BFF), size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ts_management/core/theme/app_theme.dart';

/// Custom 5-slot bottom nav with center QR FAB.
/// Order: Home / Search / [Scan FAB] / Map / Profile.
/// Active item gets a rounded chip behind the icon and a lavender label.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, required this.activePath});

  final String activePath;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 78,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.surfaceVariant)),
        ),
        child: Row(
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              active: _isActive('/home'),
              onTap: () => context.go('/home'),
            ),
            _NavItem(
              icon: Icons.search_rounded,
              label: 'Search',
              active: _isActive('/search'),
              onTap: () => context.go('/search'),
            ),
            _ScanFab(onTap: () => context.go('/scan')),
            _NavItem(
              icon: Icons.map_rounded,
              label: 'Map',
              active: _isActive('/map'),
              onTap: () => context.go('/map'),
            ),
            _NavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              active: _isActive('/profile'),
              onTap: () => context.go('/profile'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isActive(String path) => activePath.startsWith(path);
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = active ? AppTheme.primary : AppTheme.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active ? AppTheme.navIndicator : Colors.transparent,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Icon(icon, size: 22, color: fg),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanFab extends StatelessWidget {
  const _ScanFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primary, Color(0xFF7C3AED)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x66A78BFA),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.qr_code_scanner_rounded,
                color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}

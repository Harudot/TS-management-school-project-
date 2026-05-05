import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardShell extends StatelessWidget {
  const DashboardShell({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    ('/home', Icons.home_outlined, Icons.home_rounded, 'Home'),
    ('/search', Icons.search_outlined, Icons.search_rounded, 'Search'),
    ('/scan', Icons.qr_code_scanner_outlined, Icons.qr_code_scanner_rounded, 'Scan'),
    ('/map', Icons.map_outlined, Icons.map_rounded, 'Map'),
    ('/profile', Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _tabs.indexWhere((t) => location.startsWith(t.$1));
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index < 0 ? 0 : index,
        onDestinationSelected: (i) => context.go(_tabs[i].$1),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(
              icon: Icon(t.$2),
              selectedIcon: Icon(t.$3),
              label: t.$4,
            ),
        ],
      ),
    );
  }
}

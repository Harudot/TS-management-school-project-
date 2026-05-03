import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ts_management/features/auth/auth_providers.dart';

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final loc = GoRouterState.of(context).matchedLocation;
    final items = [
      ('/admin/overview', Icons.dashboard_rounded, 'Overview'),
      ('/admin/buildings', Icons.apartment_rounded, 'Buildings'),
      ('/admin/people', Icons.people_rounded, 'People'),
      ('/admin/events', Icons.event_rounded, 'Events'),
      ('/admin/users', Icons.admin_panel_settings_rounded, 'Users'),
    ];
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 900,
            selectedIndex: items
                .indexWhere((i) => loc.startsWith(i.$1))
                .clamp(0, items.length - 1),
            onDestinationSelected: (i) => context.go(items[i].$1),
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Icon(Icons.admin_panel_settings_rounded,
                  color: scheme.primary, size: 32),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Sign out',
              onPressed: () => ref.read(authServiceProvider).signOut(),
            ),
            destinations: items
                .map((i) => NavigationRailDestination(
                      icon: Icon(i.$2),
                      label: Text(i.$3),
                    ))
                .toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ts_management/core/widgets/bottom_nav_bar.dart';

class DashboardShell extends StatelessWidget {
  const DashboardShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavBar(activePath: loc),
    );
  }
}

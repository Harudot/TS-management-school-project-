import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ts_management/admin/pages/admin_buildings_page.dart';
import 'package:ts_management/admin/pages/admin_events_page.dart';
import 'package:ts_management/admin/pages/admin_floors_page.dart';
import 'package:ts_management/admin/pages/admin_login_page.dart';
import 'package:ts_management/admin/pages/admin_nav_editor_page.dart';
import 'package:ts_management/admin/pages/admin_overview_page.dart';
import 'package:ts_management/admin/pages/admin_people_page.dart';
import 'package:ts_management/admin/pages/admin_rooms_page.dart';
import 'package:ts_management/admin/pages/admin_shell.dart';
import 'package:ts_management/admin/pages/admin_start_points_page.dart';
import 'package:ts_management/admin/pages/admin_users_page.dart';
import 'package:ts_management/core/firebase/firebase_init.dart';
import 'package:ts_management/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase();
  runApp(const ProviderScope(child: AdminApp()));
}

final adminRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/admin/login',
    redirect: (_, state) async {
      final user = FirebaseAuth.instance.currentUser;
      final loggingIn = state.matchedLocation == '/admin/login';
      if (user == null && !loggingIn) return '/admin/login';
      if (user != null && loggingIn) {
        final token = await user.getIdTokenResult();
        if (token.claims?['role'] == 'admin') return '/admin/overview';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/admin/login', builder: (_, __) => const AdminLoginPage()),
      ShellRoute(
        builder: (_, __, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/admin/overview', builder: (_, __) => const AdminOverviewPage()),
          GoRoute(path: '/admin/buildings', builder: (_, __) => const AdminBuildingsPage()),
          GoRoute(
            path: '/admin/buildings/:id/floors',
            builder: (_, s) =>
                AdminFloorsPage(buildingId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: '/admin/buildings/:id/rooms',
            builder: (_, s) =>
                AdminRoomsPage(buildingId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: '/admin/buildings/:id/nav',
            builder: (_, s) =>
                AdminNavEditorPage(buildingId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: '/admin/buildings/:id/start-points',
            builder: (_, s) =>
                AdminStartPointsPage(buildingId: s.pathParameters['id']!),
          ),
          GoRoute(path: '/admin/people', builder: (_, __) => const AdminPeoplePage()),
          GoRoute(path: '/admin/events', builder: (_, __) => const AdminEventsPage()),
          GoRoute(path: '/admin/users', builder: (_, __) => const AdminUsersPage()),
        ],
      ),
    ],
  );
});

class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(adminRouterProvider);
    return MaterialApp.router(
      title: 'Smart Campus Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}

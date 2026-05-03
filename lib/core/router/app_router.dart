import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ts_management/admin/pages/admin_buildings_page.dart';
import 'package:ts_management/admin/pages/admin_events_page.dart';
import 'package:ts_management/admin/pages/admin_floors_page.dart';
import 'package:ts_management/admin/pages/admin_nav_editor_page.dart';
import 'package:ts_management/admin/pages/admin_overview_page.dart';
import 'package:ts_management/admin/pages/admin_people_page.dart';
import 'package:ts_management/admin/pages/admin_rooms_page.dart';
import 'package:ts_management/admin/pages/admin_shell.dart';
import 'package:ts_management/admin/pages/admin_start_points_page.dart';
import 'package:ts_management/admin/pages/admin_users_page.dart';
import 'package:ts_management/features/auth/auth_providers.dart';
import 'package:ts_management/features/auth/login_page.dart';
import 'package:ts_management/features/auth/signup_page.dart';
import 'package:ts_management/features/auth/forgot_password_page.dart';
import 'package:ts_management/features/dashboard/dashboard_shell.dart';
import 'package:ts_management/features/dashboard/home_page.dart';
import 'package:ts_management/features/search/search_page.dart';
import 'package:ts_management/features/scan/scan_page.dart';
import 'package:ts_management/features/navigation/map_page.dart';
import 'package:ts_management/features/navigation/navigation_page.dart';
import 'package:ts_management/features/building/building_info_page.dart';
import 'package:ts_management/features/settings/settings_page.dart';
import 'package:ts_management/features/settings/profile_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authStream = ref.watch(authStateProvider.stream);
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authStream),
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      final loggedIn = user != null;
      final loggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot';
      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/home';
      if (state.matchedLocation.startsWith('/admin')) {
        final token = await user!.getIdTokenResult();
        if (token.claims?['role'] != 'admin') return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupPage()),
      GoRoute(path: '/forgot', builder: (_, __) => const ForgotPasswordPage()),
      ShellRoute(
        builder: (_, __, child) => DashboardShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomePage()),
          GoRoute(path: '/search', builder: (_, __) => const SearchPage()),
          GoRoute(path: '/scan', builder: (_, __) => const ScanPage()),
          GoRoute(path: '/map', builder: (_, __) => const MapPage()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
        ],
      ),
      GoRoute(
        path: '/building/:id',
        builder: (_, state) =>
            BuildingInfoPage(buildingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/navigate',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>;
          return NavigationPage(
            buildingId: extra['buildingId'] as String,
            startWaypointId: extra['startWaypointId'] as String,
            endWaypointId: extra['endWaypointId'] as String,
            destinationLabel: extra['destinationLabel'] as String,
          );
        },
      ),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      GoRoute(path: '/admin', redirect: (_, __) => '/admin/overview'),
      ShellRoute(
        builder: (_, __, child) => AdminShell(child: child),
        routes: [
          GoRoute(
              path: '/admin/overview',
              builder: (_, __) => const AdminOverviewPage()),
          GoRoute(
              path: '/admin/buildings',
              builder: (_, __) => const AdminBuildingsPage()),
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
          GoRoute(
              path: '/admin/people',
              builder: (_, __) => const AdminPeoplePage()),
          GoRoute(
              path: '/admin/events',
              builder: (_, __) => const AdminEventsPage()),
          GoRoute(
              path: '/admin/users',
              builder: (_, __) => const AdminUsersPage()),
        ],
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

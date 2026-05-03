import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final loggedIn = user != null;
      final loggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot';
      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/home';
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

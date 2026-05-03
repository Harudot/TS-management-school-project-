import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ts_management/features/auth/auth_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).asData?.value;
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 16),
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: scheme.primaryContainer,
              backgroundImage:
                  user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
              child: user?.photoUrl == null
                  ? Text(
                      user?.name.isNotEmpty == true
                          ? user!.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                          fontSize: 36,
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w800),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(user?.name ?? '—',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800)),
          ),
          Center(
            child: Text(user?.email ?? '',
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Followed buildings'),
                  subtitle: Text('${user?.followedBuildings.length ?? 0} buildings'),
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Settings'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings'),
                ),
                ListTile(
                  leading: const Icon(Icons.logout_rounded),
                  title: const Text('Sign out'),
                  textColor: scheme.error,
                  iconColor: scheme.error,
                  onTap: () => ref.read(authServiceProvider).signOut(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

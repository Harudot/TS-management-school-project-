import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ts_management/features/auth/auth_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).asData?.value;
    final isAdmin = ref.watch(isAdminProvider).asData?.value ?? false;
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
                if (isAdmin)
                  ListTile(
                    leading: Icon(Icons.admin_panel_settings_rounded,
                        color: scheme.primary),
                    title: const Text('Admin Dashboard'),
                    subtitle: const Text('Manage buildings, events, users'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.go('/admin/overview'),
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
          const SizedBox(height: 16),
          const _AuthDebugCard(),
        ],
      ),
    );
  }
}

class _AuthDebugCard extends ConsumerStatefulWidget {
  const _AuthDebugCard();
  @override
  ConsumerState<_AuthDebugCard> createState() => _AuthDebugCardState();
}

class _AuthDebugCardState extends ConsumerState<_AuthDebugCard> {
  String _output = 'Tap "Refresh token" to inspect.';

  Future<void> _refresh() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _output = 'Not signed in.');
      return;
    }
    final token = await user.getIdTokenResult(true);
    setState(() => _output = 'UID:    ${user.uid}\n'
        'Email:  ${user.email}\n'
        'Provider: ${user.providerData.map((p) => p.providerId).join(", ")}\n'
        'Claims: ${token.claims}');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('DEBUG: Auth state',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(_output, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh token'),
            ),
          ],
        ),
      ),
    );
  }
}

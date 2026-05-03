import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ts_management/core/theme/theme_controller.dart';
import 'package:ts_management/features/auth/auth_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section('Appearance'),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: mode,
                  onChanged: (v) =>
                      ref.read(themeControllerProvider.notifier).set(v!),
                  title: const Text('Use system theme'),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: mode,
                  onChanged: (v) =>
                      ref.read(themeControllerProvider.notifier).set(v!),
                  title: const Text('Light'),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: mode,
                  onChanged: (v) =>
                      ref.read(themeControllerProvider.notifier).set(v!),
                  title: const Text('Dark'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _Section('Account'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notification preferences'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Manage notifications by following buildings on the building page.')));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout_rounded),
                  title: const Text('Sign out'),
                  textColor: Theme.of(context).colorScheme.error,
                  iconColor: Theme.of(context).colorScheme.error,
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

class _Section extends StatelessWidget {
  const _Section(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        child: Text(text.toUpperCase(),
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 1.2,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      );
}

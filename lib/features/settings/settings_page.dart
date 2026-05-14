import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ts_management/core/i18n/locale_controller.dart';
import 'package:ts_management/core/i18n/strings.dart';
import 'package:ts_management/core/notifications/notification_prefs_controller.dart';
import 'package:ts_management/core/theme/theme_controller.dart';
import 'package:ts_management/features/auth/auth_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider);
    final locale = ref.watch(localeControllerProvider);
    final notif = ref.watch(notificationPrefsProvider);
    String t(String k) => Strings.of(context, k);

    String themeLabel() => switch (mode) {
          ThemeMode.light => t('light'),
          ThemeMode.dark => t('dark'),
          _ => t('system_default'),
        };

    String languageLabel() => switch (locale?.languageCode) {
          'en' => t('english'),
          'mn' => t('mongolian'),
          _ => t('system_default'),
        };

    return Scaffold(
      appBar: AppBar(title: Text(t('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionLabel(t('appearance')),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: mode,
                  onChanged: (v) =>
                      ref.read(themeControllerProvider.notifier).set(v!),
                  title: Text(t('system_default')),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: mode,
                  onChanged: (v) =>
                      ref.read(themeControllerProvider.notifier).set(v!),
                  title: Text(t('light')),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: mode,
                  onChanged: (v) =>
                      ref.read(themeControllerProvider.notifier).set(v!),
                  title: Text(t('dark')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionLabel(t('settings')),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _NavTile(
                  icon: Icons.notifications_outlined,
                  title: t('notifications'),
                  trailingText: notif.enabled ? t('on') : t('off'),
                  onTap: () => context.push('/settings/notifications'),
                ),
                const Divider(height: 1),
                _NavTile(
                  icon: Icons.language_rounded,
                  title: t('language'),
                  trailingText: languageLabel(),
                  onTap: () => context.push('/settings/language'),
                ),
                const Divider(height: 1),
                _NavTile(
                  icon: Icons.dark_mode_outlined,
                  title: t('appearance'),
                  trailingText: themeLabel(),
                  onTap: () {/* already on this page */},
                ),
                const Divider(height: 1),
                _NavTile(
                  icon: Icons.accessibility_new_rounded,
                  title: t('accessibility'),
                  onTap: () => context.push('/settings/accessibility'),
                ),
                const Divider(height: 1),
                _NavTile(
                  icon: Icons.lock_outline_rounded,
                  title: t('privacy'),
                  onTap: () => context.push('/settings/privacy'),
                ),
                const Divider(height: 1),
                _NavTile(
                  icon: Icons.help_outline_rounded,
                  title: t('help_feedback'),
                  onTap: () => context.push('/settings/help'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: Text(t('sign_out')),
              textColor: Theme.of(context).colorScheme.error,
              iconColor: Theme.of(context).colorScheme.error,
              onTap: () => ref.read(authServiceProvider).signOut(),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        child: Text(text.toUpperCase(),
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 1.2,
                fontSize: 11,
                fontWeight: FontWeight.w800)),
      );
}

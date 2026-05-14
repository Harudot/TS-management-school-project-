import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ts_management/core/i18n/strings.dart';
import 'package:ts_management/core/privacy/privacy_controller.dart';
import 'package:ts_management/features/settings/_settings_widgets.dart';

class PrivacyPage extends ConsumerWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(privacyControllerProvider);
    final ctrl = ref.read(privacyControllerProvider.notifier);
    String t(String k) => Strings.of(context, k);

    return Scaffold(
      appBar: AppBar(title: Text(t('privacy'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsSectionCard(
            child: Column(children: [
              SwitchListTile(
                value: s.shareLocation,
                onChanged: ctrl.setShareLocation,
                secondary: const Icon(Icons.location_on_rounded),
                title: Text(t('priv_share_location'),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(t('priv_share_location_desc')),
              ),
              const Divider(height: 1),
              SwitchListTile(
                value: s.shareUsageAnalytics,
                onChanged: ctrl.setShareUsageAnalytics,
                secondary: const Icon(Icons.analytics_rounded),
                title: Text(t('priv_analytics'),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(t('priv_analytics_desc')),
              ),
              const Divider(height: 1),
              SwitchListTile(
                value: s.crashReports,
                onChanged: ctrl.setCrashReports,
                secondary: const Icon(Icons.bug_report_rounded),
                title: Text(t('priv_crash'),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(t('priv_crash_desc')),
              ),
              const Divider(height: 1),
              SwitchListTile(
                value: s.showInDirectory,
                onChanged: ctrl.setShowInDirectory,
                secondary: const Icon(Icons.contact_page_rounded),
                title: Text(t('priv_directory'),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(t('priv_directory_desc')),
              ),
              const Divider(height: 1),
              SwitchListTile(
                value: s.allowSearchByName,
                onChanged: ctrl.setAllowSearchByName,
                secondary: const Icon(Icons.search_rounded),
                title: Text(t('priv_search_name'),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(t('priv_search_name_desc')),
              ),
              const Divider(height: 1),
              SwitchListTile(
                value: s.personalizedContent,
                onChanged: ctrl.setPersonalizedContent,
                secondary: const Icon(Icons.tune_rounded),
                title: Text(t('priv_personalized'),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(t('priv_personalized_desc')),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          SettingsSectionLabel(t('priv_data_section')),
          SettingsSectionCard(
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.cleaning_services_rounded),
                title: Text(t('priv_clear_cache'),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(t('priv_clear_cache_desc')),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(t('priv_clear_cache')),
                      content: Text(t('priv_clear_cache_desc')),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(t('cancel'))),
                        FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(t('done'))),
                      ],
                    ),
                  );
                  if (ok != true) return;
                  await ctrl.clearCachedPrefs();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t('done'))),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.download_rounded),
                title: Text(t('priv_request_export'),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Sent to admin')),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.delete_forever_rounded,
                    color: Theme.of(context).colorScheme.error),
                title: Text(t('priv_delete_account'),
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.error)),
                subtitle: Text(t('priv_delete_account_desc')),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(t('priv_delete_account')),
                      content: Text(t('priv_delete_account_desc')),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(t('done'))),
                      ],
                    ),
                  );
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

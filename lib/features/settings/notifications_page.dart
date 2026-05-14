import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ts_management/core/i18n/strings.dart';
import 'package:ts_management/core/notifications/notification_prefs_controller.dart';
import 'package:ts_management/features/settings/_settings_widgets.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsProvider);
    final ctrl = ref.read(notificationPrefsProvider.notifier);
    final master = prefs.enabled;

    String t(String k) => Strings.of(context, k);

    return Scaffold(
      appBar: AppBar(title: Text(t('notifications'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsSectionCard(
            child: SwitchListTile(
              value: master,
              onChanged: ctrl.setEnabled,
              title: Text(t('notif_master_title'),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(t('notif_master_subtitle')),
              secondary: Icon(master
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded),
            ),
          ),
          const SizedBox(height: 18),
          SettingsSectionLabel(t('notif_categories')),
          SettingsSectionCard(
            child: Column(children: [
              _CategoryRow(
                enabled: master,
                value: prefs.events,
                onChanged: ctrl.setEvents,
                icon: Icons.event_available_rounded,
                title: t('notif_events'),
                subtitle: t('notif_events_desc'),
              ),
              const Divider(height: 1),
              _CategoryRow(
                enabled: master,
                value: prefs.classReminders,
                onChanged: ctrl.setClassReminders,
                icon: Icons.school_rounded,
                title: t('notif_class'),
                subtitle: t('notif_class_desc'),
              ),
              const Divider(height: 1),
              _CategoryRow(
                enabled: master,
                value: prefs.followedBuildings,
                onChanged: ctrl.setFollowedBuildings,
                icon: Icons.apartment_rounded,
                title: t('notif_followed'),
                subtitle: t('notif_followed_desc'),
              ),
              const Divider(height: 1),
              _CategoryRow(
                enabled: master,
                value: prefs.systemAnnouncements,
                onChanged: ctrl.setSystemAnnouncements,
                icon: Icons.campaign_rounded,
                title: t('notif_system'),
                subtitle: t('notif_system_desc'),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          SettingsSectionLabel(t('notif_delivery')),
          SettingsSectionCard(
            child: Column(children: [
              _CategoryRow(
                enabled: master,
                value: prefs.sound,
                onChanged: ctrl.setSound,
                icon: Icons.volume_up_rounded,
                title: t('notif_sound'),
              ),
              const Divider(height: 1),
              _CategoryRow(
                enabled: master,
                value: prefs.vibration,
                onChanged: ctrl.setVibration,
                icon: Icons.vibration_rounded,
                title: t('notif_vibration'),
              ),
              const Divider(height: 1),
              _CategoryRow(
                enabled: master,
                value: prefs.quietHours,
                onChanged: ctrl.setQuietHours,
                icon: Icons.bedtime_rounded,
                title: t('notif_quiet_hours'),
                subtitle: t('notif_quiet_hours_desc'),
              ),
              if (prefs.quietHours) ...[
                const Divider(height: 1),
                _QuietWindow(
                  startHour: prefs.quietStart,
                  endHour: prefs.quietEnd,
                  enabled: master,
                  onChanged: (s, e) => ctrl.setQuietWindow(s, e),
                  label: t('notif_quiet_window'),
                ),
              ],
            ]),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.enabled,
    required this.value,
    required this.onChanged,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final bool enabled;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value && enabled,
      onChanged: enabled ? onChanged : null,
      secondary: Icon(icon),
      title: Text(title,
          style: TextStyle(
              color: enabled ? null : Theme.of(context).disabledColor,
              fontWeight: FontWeight.w600)),
      subtitle: subtitle == null ? null : Text(subtitle!),
    );
  }
}

class _QuietWindow extends StatelessWidget {
  const _QuietWindow({
    required this.startHour,
    required this.endHour,
    required this.enabled,
    required this.onChanged,
    required this.label,
  });
  final int startHour;
  final int endHour;
  final bool enabled;
  final void Function(int start, int end) onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    Future<void> pick(bool start) async {
      final init = TimeOfDay(hour: start ? startHour : endHour, minute: 0);
      final res = await showTimePicker(context: context, initialTime: init);
      if (res == null) return;
      onChanged(start ? res.hour : startHour, start ? endHour : res.hour);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.schedule_rounded),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          OutlinedButton(
            onPressed: enabled ? () => pick(true) : null,
            child: Text(_fmt(startHour)),
          ),
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text('→')),
          OutlinedButton(
            onPressed: enabled ? () => pick(false) : null,
            child: Text(_fmt(endHour)),
          ),
        ],
      ),
    );
  }

  String _fmt(int h) =>
      '${h.toString().padLeft(2, '0')}:00';
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ts_management/domain/services/notifications_service.dart';

class NotificationPrefs {
  const NotificationPrefs({
    this.enabled = true,
    this.events = true,
    this.classReminders = true,
    this.followedBuildings = true,
    this.systemAnnouncements = true,
    this.sound = true,
    this.vibration = true,
    this.quietHours = false,
    this.quietStart = 22,
    this.quietEnd = 7,
  });

  final bool enabled;
  final bool events;
  final bool classReminders;
  final bool followedBuildings;
  final bool systemAnnouncements;
  final bool sound;
  final bool vibration;
  final bool quietHours;
  final int quietStart;
  final int quietEnd;

  NotificationPrefs copyWith({
    bool? enabled,
    bool? events,
    bool? classReminders,
    bool? followedBuildings,
    bool? systemAnnouncements,
    bool? sound,
    bool? vibration,
    bool? quietHours,
    int? quietStart,
    int? quietEnd,
  }) =>
      NotificationPrefs(
        enabled: enabled ?? this.enabled,
        events: events ?? this.events,
        classReminders: classReminders ?? this.classReminders,
        followedBuildings: followedBuildings ?? this.followedBuildings,
        systemAnnouncements: systemAnnouncements ?? this.systemAnnouncements,
        sound: sound ?? this.sound,
        vibration: vibration ?? this.vibration,
        quietHours: quietHours ?? this.quietHours,
        quietStart: quietStart ?? this.quietStart,
        quietEnd: quietEnd ?? this.quietEnd,
      );
}

class NotificationPrefsController extends StateNotifier<NotificationPrefs> {
  NotificationPrefsController() : super(const NotificationPrefs()) {
    _load();
  }

  static const _kEnabled = 'notif_enabled';
  static const _kEvents = 'notif_events';
  static const _kClass = 'notif_class';
  static const _kFollowed = 'notif_followed';
  static const _kSystem = 'notif_system';
  static const _kSound = 'notif_sound';
  static const _kVibration = 'notif_vibration';
  static const _kQuiet = 'notif_quiet';
  static const _kQuietStart = 'notif_quiet_start';
  static const _kQuietEnd = 'notif_quiet_end';

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = NotificationPrefs(
      enabled: p.getBool(_kEnabled) ?? true,
      events: p.getBool(_kEvents) ?? true,
      classReminders: p.getBool(_kClass) ?? true,
      followedBuildings: p.getBool(_kFollowed) ?? true,
      systemAnnouncements: p.getBool(_kSystem) ?? true,
      sound: p.getBool(_kSound) ?? true,
      vibration: p.getBool(_kVibration) ?? true,
      quietHours: p.getBool(_kQuiet) ?? false,
      quietStart: p.getInt(_kQuietStart) ?? 22,
      quietEnd: p.getInt(_kQuietEnd) ?? 7,
    );
  }

  Future<void> setEnabled(bool v) async {
    state = state.copyWith(enabled: v);
    (await SharedPreferences.getInstance()).setBool(_kEnabled, v);
    // Best-effort: subscribe/unsubscribe from a global topic so the user
    // gets a master kill-switch even before per-building prefs apply.
    try {
      if (v) {
        await NotificationsService.instance.subscribeToBuilding('all');
      } else {
        await NotificationsService.instance.unsubscribeFromBuilding('all');
      }
    } catch (_) {/* ignore — topic management not always available */}
  }

  Future<void> setEvents(bool v) async {
    state = state.copyWith(events: v);
    (await SharedPreferences.getInstance()).setBool(_kEvents, v);
  }

  Future<void> setClassReminders(bool v) async {
    state = state.copyWith(classReminders: v);
    (await SharedPreferences.getInstance()).setBool(_kClass, v);
  }

  Future<void> setFollowedBuildings(bool v) async {
    state = state.copyWith(followedBuildings: v);
    (await SharedPreferences.getInstance()).setBool(_kFollowed, v);
  }

  Future<void> setSystemAnnouncements(bool v) async {
    state = state.copyWith(systemAnnouncements: v);
    (await SharedPreferences.getInstance()).setBool(_kSystem, v);
  }

  Future<void> setSound(bool v) async {
    state = state.copyWith(sound: v);
    (await SharedPreferences.getInstance()).setBool(_kSound, v);
  }

  Future<void> setVibration(bool v) async {
    state = state.copyWith(vibration: v);
    (await SharedPreferences.getInstance()).setBool(_kVibration, v);
  }

  Future<void> setQuietHours(bool v) async {
    state = state.copyWith(quietHours: v);
    (await SharedPreferences.getInstance()).setBool(_kQuiet, v);
  }

  Future<void> setQuietWindow(int startHour, int endHour) async {
    state = state.copyWith(quietStart: startHour, quietEnd: endHour);
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kQuietStart, startHour);
    await p.setInt(_kQuietEnd, endHour);
  }
}

final notificationPrefsProvider =
    StateNotifierProvider<NotificationPrefsController, NotificationPrefs>(
        (ref) => NotificationPrefsController());

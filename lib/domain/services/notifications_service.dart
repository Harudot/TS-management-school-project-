import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsService {
  NotificationsService._();
  static final instance = NotificationsService._();

  final _messaging = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'campus_events',
    'Campus events',
    description: 'Live notifications about campus events',
    importance: Importance.high,
  );

  Future<void> init() async {
    if (kIsWeb) {
      // On web, just ask permission and listen — local notifications plugin is mobile-only.
      try {
        await _messaging.requestPermission();
        FirebaseMessaging.onMessage.listen((m) {
          debugPrint('FCM (web): ${m.notification?.title}');
        });
      } catch (e) {
        debugPrint('FCM web init skipped: $e');
      }
      return;
    }

    await _local.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    await _messaging.requestPermission();
    FirebaseMessaging.onMessage.listen(_handleForeground);
  }

  Future<String?> token() => _messaging.getToken();

  Future<void> subscribeToBuilding(String buildingId) async {
    if (kIsWeb) return; // FCM topic subscription not supported on web
    await _messaging.subscribeToTopic('building_$buildingId');
  }

  Future<void> unsubscribeFromBuilding(String buildingId) async {
    if (kIsWeb) return;
    await _messaging.unsubscribeFromTopic('building_$buildingId');
  }

  void _handleForeground(RemoteMessage msg) {
    final n = msg.notification;
    if (n == null) return;
    _local.show(
      n.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
    debugPrint('FCM message: ${n.title}');
  }
}

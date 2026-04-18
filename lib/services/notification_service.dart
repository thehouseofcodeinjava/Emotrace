// Service: NotificationService | Author: Rajat Mahajan | Date: 11 Apr 2026
// Full impl: Piyush Puri | Date: 13 Apr 2026
// S6 fix: ensure exact alarm permission, improve scheduling robustness

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static const int _dailyReminderId = 1;
  static bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Initialize timezone database and set device local timezone.
    tz.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (_) {
      // Fall back to UTC
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Create the Android notification channel (required for Android 8+).
    const channel = AndroidNotificationChannel(
      'emotrace_daily',
      'Daily Reminder',
      description: 'Daily mood check-in reminder',
      importance: Importance.high,
    );
    await androidImpl?.createNotificationChannel(channel);

    // Request notification permission (required for Android 13+ / API 33+).
    await androidImpl?.requestNotificationsPermission();

    // Request exact alarm permission (required for Android 12+ / API 31+).
    // Without this, zonedSchedule with exactAlarm silently fails.
    await androidImpl?.requestExactAlarmsPermission();

    _initialized = true;
  }

  /// Schedule a daily repeating notification at [time] ('HH:mm' format).
  /// Cancels any existing schedule first.
  Future<void> scheduleDailyReminder(String time) async {
    if (!_initialized) await init();

    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 20;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    await _plugin.cancel(_dailyReminderId);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute,
    );
    // If today's time has already passed, schedule for tomorrow.
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _dailyReminderId,
      'Time to check in',
      'How are you feeling today?',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'emotrace_daily',
          'Daily Reminder',
          channelDescription: 'Daily mood check-in reminder',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(_dailyReminderId);
  }

  /// Check if notification permissions are granted.
  Future<bool> areNotificationsEnabled() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    return await androidImpl?.areNotificationsEnabled() ?? true;
  }
}

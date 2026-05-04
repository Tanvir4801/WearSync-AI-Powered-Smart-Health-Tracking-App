import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
  }

  Future<void> requestPermissions() async {
    await _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> scheduleWaterReminder(int intervalMinutes) async {
    await _plugin.periodicallyShow(
      1,
      'Time to hydrate!',
      'Drink a glass of water',
      RepeatInterval.values[_intervalToRepeatInterval(intervalMinutes)],
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_reminder',
          'Water Reminders',
          channelDescription: 'Reminders to drink water',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  int _intervalToRepeatInterval(int minutes) {
    if (minutes <= 30) return 0; // RepeatInterval.everyMinute
    if (minutes <= 60) return 1; // RepeatInterval.hourly
    return 2; // RepeatInterval.daily (for safety, use daily for intervals > 1hr)
  }

  Future<void> scheduleInactivityAlert() async {
    final tz.TZDateTime scheduledDate =
        tz.TZDateTime.now(tz.local).add(const Duration(minutes: 60));

    await _plugin.zonedSchedule(
      2,
      'Time for movement!',
      "You've been inactive. Time for a short walk!",
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'inactivity_alert',
          'Inactivity Alerts',
          channelDescription: 'Alerts when you\'ve been inactive',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> sendDailySummary({
    required int steps,
    required int calories,
  }) async {
    final tz.TZDateTime scheduledDate = _nextDaily9PM();

    await _plugin.zonedSchedule(
      3,
      'Daily Summary',
      'You took $steps steps today and burned $calories calories.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_summary',
          'Daily Summaries',
          channelDescription: 'Daily health summaries',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextDaily9PM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      21,
      0,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}

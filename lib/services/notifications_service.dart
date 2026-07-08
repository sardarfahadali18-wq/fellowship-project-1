import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Initialize notification service
  static Future<void> init() async {
    tz.initializeTimeZones();

    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    // Fixed: explicit named parameter prefix 'settings:'
    await _notificationsPlugin.initialize(settings: settings);

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  /// Instant test notification
  static Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medicine_reminders',
      'Medicine Reminders',
      channelDescription: 'Medication reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    // Fixed: added named parameter labels 'id:', 'title:', 'body:', 'notificationDetails:'
    await _notificationsPlugin.show(
      id: 0,
      title: '🔔 Test Notification',
      body: 'Your notification system is working correctly!',
      notificationDetails: const NotificationDetails(android: androidDetails),
    );
  }

  /// Schedule a daily medication reminder
  static Future<void> scheduleDailyReminder({
    required int id,
    required String patientName,
    required String medicineName,
    required int targetHour,
    required int targetMinute,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medicine_reminders',
      'Medicine Reminders',
      channelDescription: 'Medication reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      targetHour,
      targetMinute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Fixed: added named parameter labels 'id:', 'title:', 'body:', 'scheduledDate:', 'notificationDetails:'
    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: '💊 Medication Reminder',
      body: 'It is time for $patientName to take $medicineName.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
import 'package:autistock/models/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init({void Function(String?)? onNotificationTap}) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (onNotificationTap != null) {
          onNotificationTap(response.payload);
        }
      },
    );
    tz.initializeTimeZones();
  }

  Future<void> showRewardUnlockedNotification(String rewardName) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'reward_unlocked_channel',
        'Reward Unlocked Notifications',
        channelDescription: 'Notifications for when a new reward is unlocked.',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      rewardName.hashCode,
      '¡Recompensa Desbloqueada!',
      'Has desbloqueado una nueva recompensa: $rewardName',
      notificationDetails,
      payload: 'reward_unlocked_$rewardName',
    );
  }

  Future<void> cancelAllMoodReminders() async {
    final pendingRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (var request in pendingRequests) {
      if (request.payload == 'mood_reminder') {
        await flutterLocalNotificationsPlugin.cancel(request.id);
      }
    }
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(String activityId) async {
    await flutterLocalNotificationsPlugin.cancel(activityId.hashCode);
  }

  Future<void> scheduleActivityNotification(Activity activity) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'activity_channel',
        'Activity Notifications',
        channelDescription: 'Notifications for scheduled activities',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    final date = activity.date;
    final time = activity.startTime;

    final scheduleTime = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (scheduleTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      activity.id.hashCode,
      'Actividad Programada',
      'Es hora de: ${activity.name}',
      scheduleTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'activity_${activity.id}',
    );
  }

  Future<void> scheduleDailyMoodReminders(List<TimeOfDay> times) async {
    await cancelAllMoodReminders();
    for (int i = 0; i < times.length; i++) {
      final time = times[i];
      await flutterLocalNotificationsPlugin.zonedSchedule(
        i + 1,
        'Registro de Estado de Ánimo',
        'Es hora de registrar cómo te sientes. ¡Tu bienestar es importante!',
        _nextInstanceOfTime(time.hour, time.minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'mood_reminder_channel',
            'Recordatorios de Estado de Ánimo',
            channelDescription:
                'Recordatorios diarios para registrar el estado de ánimo.',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'mood_reminder',
      );
    }
  }

  Future<void> scheduleDailyNotification(
      {required int hour, required int minute}) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Registro Diario',
      'No olvides registrar tu estado de ánimo y tus actividades de hoy.',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
            'daily_notification_channel', 'Daily Notifications',
            channelDescription: 'Daily reminders to log mood and activities.',
            importance: Importance.max,
            priority: Priority.high),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}

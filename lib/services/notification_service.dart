import 'package:autistock/models/activity.dart';
import 'package:autistock/models/reward.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

export 'notification_service_stub.dart'
    if (dart.library.io) 'notification_service_mobile.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init({void Function(String?)? onNotificationTap}) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsIOS,
      linux: initializationSettingsLinux,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (onNotificationTap != null) {
          onNotificationTap(response.payload);
        }
      },
    );
    if (!kIsWeb) {
      tz.initializeTimeZones();
    }
  }

  Future<void> scheduleActivityNotification(Activity activity) async {
    if (kIsWeb) return; // No ejecutar en la web
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
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'activity_${activity.id}',
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

  Future<void> scheduleDailyNotification(
      {required int hour, required int minute}) async {
    if (kIsWeb) return; // No ejecutar en la web
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
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAllMoodReminders() async {
    if (kIsWeb) return; // No ejecutar en la web
    final pendingRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (var request in pendingRequests) {
      await flutterLocalNotificationsPlugin.cancel(request.id);
    }
  }

  Future<void> scheduleDailyMoodReminders(List<TimeOfDay> times) async {
    if (kIsWeb) return; // No ejecutar en la web
    await cancelAllMoodReminders();
    for (int i = 0; i < times.length; i++) {
      final time = times[i];
      await flutterLocalNotificationsPlugin.zonedSchedule(
        i + 1, // Unique ID for each notification (start from 1 to avoid conflict with daily notification)
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
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'mood_reminder',
      );
    }
  }

  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return; // No ejecutar en la web
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(String activityId) async {
    if (kIsWeb) return; // No ejecutar en la web
    await flutterLocalNotificationsPlugin.cancel(activityId.hashCode);
  }

  Future<void> showRewardUnlockedNotification(Reward reward) async {
    if (kIsWeb) return; // No ejecutar en la web
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'reward_channel', // ID del canal
      'Notificaciones de Recompensas', // Nombre del canal
      channelDescription: 'Notificaciones para recompensas desbloqueadas',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      reward.id.hashCode, // Usar un ID único para la notificación
      '¡Recompensa Desbloqueada!',
      'Has conseguido: ${reward.name}',
      platformChannelSpecifics,
    );
  }
}

import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() => _notificationService;

  NotificationService._internal();

  Future<void> init() async {
    print('NotificationService initialized for web');
  }

  Future<void> scheduleDailyNotification({
    required int hour,
    required int minute,
    BuildContext? context,
  }) async {
    print(
      'Notification scheduled for ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} (web version)',
    );

    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Recordatorio programado para las ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.blue[600],
        ),
      );
    }
  }

  Future<void> cancelAllNotifications() async {
    print('All notifications cancelled (web version)');
  }
}

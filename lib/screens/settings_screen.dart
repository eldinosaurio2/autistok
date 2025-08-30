import 'package:autistock/services/data_service.dart';
import 'package:autistock/services/notification_service.dart';
import 'package:autistock/services/theme_notifier.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late DataService _dataService;
  NotificationService? _notificationService;
  bool _globalNotificationsEnabled = true;
  bool _moodNotificationsEnabled = false;
  bool _activityNotificationsEnabled = false;
  bool _rewardNotificationsEnabled = false;
  List<TimeOfDay> _notificationTimes = [];

  @override
  void initState() {
    super.initState();
    _dataService = Provider.of<DataService>(context, listen: false);
    if (!kIsWeb) {
      _notificationService =
          Provider.of<NotificationService>(context, listen: false);
    }
    _loadSettings();
  }

  void _loadSettings() async {
    if (!kIsWeb) {
      _globalNotificationsEnabled =
          await _dataService.loadGlobalNotificationSetting();
      _moodNotificationsEnabled =
          await _dataService.loadNotificationSettings('mood');
      _activityNotificationsEnabled =
          await _dataService.loadNotificationSettings('activity');
      _rewardNotificationsEnabled =
          await _dataService.loadNotificationSettings('reward');
      final times = await _dataService.loadNotificationTimes();
      if (mounted) {
        setState(() {
          _notificationTimes = times
              .map((timeString) => TimeOfDay(
                    hour: int.parse(timeString.split(':')[0]),
                    minute: int.parse(timeString.split(':')[1]),
                  ))
              .toList();
        });
      }
    }
  }

  void _updateGlobalNotificationSettings(bool enabled) {
    if (kIsWeb) return;
    setState(() {
      _globalNotificationsEnabled = enabled;
    });
    _dataService.saveGlobalNotificationSetting(enabled);
    if (!enabled) {
      _notificationService?.cancelAllNotifications();
    }
  }

  void _updateMoodNotificationSettings(bool enabled) {
    if (kIsWeb) return;
    setState(() {
      _moodNotificationsEnabled = enabled;
    });
    _dataService.saveNotificationSettings('mood', enabled);
    if (enabled) {
      _notificationService?.scheduleDailyMoodReminders(_notificationTimes);
    } else {
      _notificationService?.cancelAllMoodReminders();
    }
  }

  void _updateActivityNotificationSettings(bool enabled) {
    if (kIsWeb) return;
    setState(() {
      _activityNotificationsEnabled = enabled;
    });
    _dataService.saveNotificationSettings('activity', enabled);
  }

  void _updateRewardNotificationSettings(bool enabled) {
    if (kIsWeb) return;
    setState(() {
      _rewardNotificationsEnabled = enabled;
    });
    _dataService.saveNotificationSettings('reward', enabled);
  }

  void _addNotificationTime() async {
    if (kIsWeb) return;
    final newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (newTime != null) {
      setState(() {
        _notificationTimes.add(newTime);
      });
      _saveAndRescheduleNotifications();
    }
  }

  void _removeNotificationTime(int index) {
    if (kIsWeb) return;
    setState(() {
      _notificationTimes.removeAt(index);
    });
    _saveAndRescheduleNotifications();
  }

  void _saveAndRescheduleNotifications() {
    if (kIsWeb) return;
    final timeStrings = _notificationTimes
        .map((time) => '${time.hour}:${time.minute}')
        .toList();
    _dataService.saveNotificationTimes(timeStrings);
    if (_moodNotificationsEnabled) {
      _notificationService?.scheduleDailyMoodReminders(_notificationTimes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!kIsWeb) ...[
              // <--- ESTA LÍNEA OCULTA LAS NOTIFICACIONES EN LA WEB
              const Text(
                'Notificaciones',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SwitchListTile(
                title: const Text('Activar notificaciones'),
                value: _globalNotificationsEnabled,
                onChanged: _updateGlobalNotificationSettings,
              ),
              if (_globalNotificationsEnabled) ...[
                SwitchListTile(
                  title: const Text('Recordatorios de estado de ánimo'),
                  value: _moodNotificationsEnabled,
                  onChanged: _updateMoodNotificationSettings,
                ),
                if (_moodNotificationsEnabled)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Horarios de notificación de ánimo',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        ..._notificationTimes.asMap().entries.map((entry) {
                          final index = entry.key;
                          final time = entry.value;
                          return ListTile(
                            title: Text(time.format(context)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeNotificationTime(index),
                            ),
                          );
                        }),
                        ElevatedButton(
                          onPressed: _addNotificationTime,
                          child: const Text('Añadir horario'),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                SwitchListTile(
                  title: const Text('Recordatorios de actividades'),
                  subtitle: const Text(
                      'Recibir alertas para las actividades planificadas.'),
                  value: _activityNotificationsEnabled,
                  onChanged: _updateActivityNotificationSettings,
                ),
                SwitchListTile(
                  title: const Text('Notificaciones de recompensas'),
                  subtitle: const Text(
                      'Recibir una alerta al desbloquear recompensas.'),
                  value: _rewardNotificationsEnabled,
                  onChanged: _updateRewardNotificationSettings,
                ),
              ],
              const Divider(height: 40),
            ], // <--- FIN DEL BLOQUE OCULTO
            const Text(
              'Apariencia',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text('Modo oscuro'),
              value: themeNotifier.themeMode == ThemeMode.dark,
              onChanged: (value) {
                themeNotifier.toggleTheme();
              },
            ),
            const SizedBox(height: 10),
            Text(
                'Tamaño del texto: ${themeNotifier.textScaleFactor.toStringAsFixed(1)}x'),
            Slider(
              value: themeNotifier.textScaleFactor,
              min: 0.8,
              max: 2.0,
              divisions: 12,
              label: themeNotifier.textScaleFactor.toStringAsFixed(1),
              onChanged: (value) {
                themeNotifier.setTextScaleFactor(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}

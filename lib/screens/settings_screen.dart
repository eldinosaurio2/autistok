import 'package:autistock/services/data_service.dart';
import 'package:autistock/services/notification_service.dart';
import 'package:autistock/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late DataService _dataService;
  late NotificationService _notificationService;
  bool _notificationsEnabled = false;
  List<TimeOfDay> _notificationTimes = [];

  @override
  void initState() {
    super.initState();
    _dataService = Provider.of<DataService>(context, listen: false);
    _notificationService =
        Provider.of<NotificationService>(context, listen: false);
    _loadSettings();
  }

  void _loadSettings() async {
    _notificationsEnabled = await _dataService.loadNotificationSettings();
    final times = await _dataService.loadNotificationTimes();
    setState(() {
      _notificationTimes = times
          .map((timeString) => TimeOfDay(
                hour: int.parse(timeString.split(':')[0]),
                minute: int.parse(timeString.split(':')[1]),
              ))
          .toList();
    });
  }

  void _updateNotificationSettings(bool enabled) {
    setState(() {
      _notificationsEnabled = enabled;
    });
    _dataService.saveNotificationSettings(enabled);
    if (enabled) {
      _notificationService.scheduleDailyMoodReminders(_notificationTimes);
    } else {
      _notificationService.cancelAllMoodReminders();
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && !_notificationTimes.contains(picked)) {
      setState(() {
        _notificationTimes.add(picked);
      });
      _saveAndRescheduleNotifications();
    }
  }

  void _removeTime(TimeOfDay time) {
    setState(() {
      _notificationTimes.remove(time);
    });
    _saveAndRescheduleNotifications();
  }

  void _saveAndRescheduleNotifications() {
    final timeStrings = _notificationTimes
        .map((time) => '${time.hour}:${time.minute}')
        .toList();
    _dataService.saveNotificationTimes(timeStrings);
    if (_notificationsEnabled) {
      _notificationService.scheduleDailyMoodReminders(_notificationTimes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _buildAppearanceSettings(context),
              _buildTextSizeSettings(context),
              _buildNotificationSettings(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppearanceSettings(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: const Icon(Icons.palette),
        title: const Text('Modo Oscuro'),
        trailing: Switch(
          value: themeNotifier.isDarkMode,
          onChanged: (value) {
            themeNotifier.toggleTheme();
          },
        ),
      ),
    );
  }

  Widget _buildTextSizeSettings(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tamaño del Texto',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    final newScaleFactor =
                        (themeNotifier.textScaleFactor - 0.1).clamp(0.8, 2.0);
                    themeNotifier.setTextScaleFactor(newScaleFactor);
                  },
                ),
                Text(
                  '${(themeNotifier.textScaleFactor * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final newScaleFactor =
                        (themeNotifier.textScaleFactor + 0.1).clamp(0.8, 2.0);
                    themeNotifier.setTextScaleFactor(newScaleFactor);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Activar Notificaciones de Ánimo'),
            value: _notificationsEnabled,
            onChanged: _updateNotificationSettings,
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Recordatorios',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _notificationTimes.length,
            itemBuilder: (context, index) {
              final time = _notificationTimes[index];
              return ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(time.format(context)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeTime(time),
                ),
                enabled: _notificationsEnabled,
              );
            },
          ),
          TextButton(
            onPressed: () => _selectTime(context),
            child: const Text('Añadir Recordatorio'),
          ),
        ],
      ),
    );
  }
}

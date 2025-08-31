import 'package:autistock/models/activity.dart';
import 'package:autistock/services/data_service.dart';
import 'package:autistock/services/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ActivityPlannerScreen extends StatefulWidget {
  final DateTime selectedDay;

  const ActivityPlannerScreen({super.key, required this.selectedDay});

  @override
  ActivityPlannerScreenState createState() => ActivityPlannerScreenState();
}

class ActivityPlannerScreenState extends State<ActivityPlannerScreen> {
  List<Activity> _activities = [];
  late DataService _dataService;
  NotificationService? _notificationService;

  @override
  void initState() {
    super.initState();
    _dataService = Provider.of<DataService>(context, listen: false);
    if (!kIsWeb) {
      _notificationService =
          Provider.of<NotificationService>(context, listen: false);
    }
    _loadActivities();
  }

  void _loadActivities() async {
    final activities =
        await _dataService.getActivitiesForDay(widget.selectedDay);
    if (mounted) {
      setState(() {
        _activities = activities;
      });
    }
  }

  void _saveActivities() {
    _dataService.saveActivitiesForDay(widget.selectedDay, _activities);
  }

  void _addActivity(Activity activity) async {
    setState(() {
      _activities.add(activity);
    });
    _saveActivities();
    final globalNotificationsEnabled =
        await _dataService.loadGlobalNotificationSetting();
    final activityNotificationsEnabled =
        await _dataService.loadNotificationSettings('activity');
    if (globalNotificationsEnabled && activityNotificationsEnabled) {
      _notificationService?.scheduleActivityNotification(activity);
    }
  }

  void _removeActivity(int index) async {
    final activity = _activities[index];
    setState(() {
      _activities.removeAt(index);
    });
    _saveActivities();
    _notificationService?.cancelNotification(activity.id);
  }

  void _editActivity(int index, Activity activity) async {
    setState(() {
      _activities[index] = activity;
    });
    _saveActivities();
    final globalNotificationsEnabled =
        await _dataService.loadGlobalNotificationSetting();
    final activityNotificationsEnabled =
        await _dataService.loadNotificationSettings('activity');
    if (globalNotificationsEnabled && activityNotificationsEnabled) {
      _notificationService?.scheduleActivityNotification(activity);
    }
  }

  void _updateActivityStatus(int index, ActivityStatus status) {
    setState(() {
      _activities[index].status = status;
    });
    _saveActivities();
  }

  void _showActivityDialog({Activity? activity, int? index}) async {
    final newActivity = await showDialog<Activity>(
      context: context,
      builder: (context) =>
          _ActivityDialog(activity: activity, selectedDay: widget.selectedDay),
    );

    if (newActivity != null) {
      if (mounted) {
        if (index != null) {
          _editActivity(index, newActivity);
        } else {
          _addActivity(newActivity);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planificador de Actividades'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              DateFormat.yMMMd('es').format(widget.selectedDay),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Usa el botón (+) para añadir una actividad. Para cada actividad, puedes:',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 8),
                Text(
                  '• Pulsar el símbolo de verificación (✓) para marcar el estado de la actividad: completada exitosamente, completada con dificultad, o no completada\n'
                  '• Editar o eliminar la actividad usando los iconos correspondientes',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                final activity = _activities[index];
                return ActivityCard(
                  activity: activity,
                  onEdit: () =>
                      _showActivityDialog(activity: activity, index: index),
                  onDelete: () => _removeActivity(index),
                  onStatusChanged: (status) =>
                      _updateActivityStatus(index, status),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showActivityDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ActivityDialog extends StatefulWidget {
  final Activity? activity;
  final DateTime selectedDay;

  const _ActivityDialog({this.activity, required this.selectedDay});

  @override
  __ActivityDialogState createState() => __ActivityDialogState();
}

class __ActivityDialogState extends State<_ActivityDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late double _energy;
  late String _id;
  late ActivityStatus _status;

  @override
  void initState() {
    super.initState();
    _name = widget.activity?.name ?? '';
    _startTime = widget.activity?.startTime ?? TimeOfDay.now();
    _endTime = widget.activity?.endTime ??
        TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
    _energy = widget.activity?.energy ?? 0.0;
    _id = widget.activity?.id ?? const Uuid().v4();
    _status = widget.activity?.status ?? ActivityStatus.planned;
  }

  void _pickStartTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (pickedTime != null) {
      setState(() {
        _startTime = pickedTime;
      });
    }
  }

  void _pickEndTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (pickedTime != null) {
      setState(() {
        _endTime = pickedTime;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final activity = Activity(
        id: _id,
        name: _name,
        date: widget.selectedDay,
        startTime: _startTime,
        endTime: _endTime,
        energy: _energy,
        status: _status,
      );
      Navigator.of(context).pop(activity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.activity == null ? 'Añadir Actividad' : 'Editar Actividad'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Actividad'),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingrese un nombre' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                        'Inicio: ${MaterialLocalizations.of(context).formatTimeOfDay(_startTime)}'),
                  ),
                  TextButton(
                    onPressed: _pickStartTime,
                    child: const Text('Seleccionar'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                        'Fin: ${MaterialLocalizations.of(context).formatTimeOfDay(_endTime)}'),
                  ),
                  TextButton(
                    onPressed: _pickEndTime,
                    child: const Text('Seleccionar'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Nivel de Energía: ${_energy.toStringAsFixed(1)}'),
              Slider(
                value: _energy,
                min: -5,
                max: 5,
                divisions: 10,
                label: _energy.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _energy = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<ActivityStatus> onStatusChanged;

  const ActivityCard(
      {super.key,
      required this.activity,
      required this.onEdit,
      required this.onDelete,
      required this.onStatusChanged});

  Color _getEnergyColor(double energy) {
    if (energy > 0) {
      return Colors.green.shade200;
    } else if (energy < 0) {
      return Colors.red.shade200;
    } else {
      return Colors.orange.shade200;
    }
  }

  Color _getStatusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.completed:
        return Colors.green.shade100;
      case ActivityStatus.completedWithDifficulty:
        return Colors.yellow.shade100;
      case ActivityStatus.notCompleted:
        return Colors.red.shade100;
      case ActivityStatus.planned:
      default:
        return _getEnergyColor(activity.energy);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final startTime = localizations.formatTimeOfDay(activity.startTime);
    final endTime = localizations.formatTimeOfDay(activity.endTime);

    return Card(
      color: _getStatusColor(activity.status),
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(activity.name),
        subtitle: Text('De $startTime a $endTime'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
            PopupMenuButton<ActivityStatus>(
              icon: const Icon(Icons.check_circle_outline),
              onSelected: onStatusChanged,
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<ActivityStatus>>[
                const PopupMenuItem<ActivityStatus>(
                  value: ActivityStatus.completed,
                  child: Text('Completada'),
                ),
                const PopupMenuItem<ActivityStatus>(
                  value: ActivityStatus.completedWithDifficulty,
                  child: Text('Completada con dificultad'),
                ),
                const PopupMenuItem<ActivityStatus>(
                  value: ActivityStatus.notCompleted,
                  child: Text('No completada'),
                ),
                const PopupMenuItem<ActivityStatus>(
                  value: ActivityStatus.planned,
                  child: Text('Planeada'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

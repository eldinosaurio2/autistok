import 'package:autistock/models/activity.dart';
import 'package:autistock/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<Activity> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final activities = await dataService.loadActivities();
    if (mounted) {
      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    }
  }

  void _addActivity() async {
    final newActivity = await showDialog<Activity>(
      context: context,
      builder: (context) => const ActivityDialog(),
    );
    if (newActivity != null) {
      setState(() {
        _activities.add(newActivity);
      });
      _saveActivities();
    }
  }

  void _editActivity(int index) async {
    final updatedActivity = await showDialog<Activity>(
      context: context,
      builder: (context) => ActivityDialog(activity: _activities[index]),
    );
    if (updatedActivity != null) {
      setState(() {
        _activities[index] = updatedActivity;
      });
      _saveActivities();
    }
  }

  void _removeActivity(int index) {
    setState(() {
      _activities.removeAt(index);
    });
    _saveActivities();
  }

  Future<void> _saveActivities() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    await dataService.saveActivities(_activities);
  }

  Color _getEnergyColor(double energy) {
    if (energy >= 4) {
      return Colors.green.shade200;
    } else if (energy < 0) {
      return Colors.red.shade200;
    } else {
      return Colors.orange.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Próximas Actividades'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activities.isEmpty
              ? const Center(child: Text('No hay actividades planificadas.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _activities.length,
                  itemBuilder: (context, index) {
                    final activity = _activities[index];
                    final formattedDate =
                        DateFormat.yMMMd('es').format(activity.date);
                    return Card(
                      color: _getEnergyColor(activity.energy),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(activity.name),
                        subtitle: Text(
                            'Fecha: $formattedDate - Energía: ${activity.energy.toStringAsFixed(1)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editActivity(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeActivity(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addActivity,
        tooltip: 'Añadir Actividad',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ActivityDialog extends StatefulWidget {
  final Activity? activity;

  const ActivityDialog({super.key, this.activity});

  @override
  State<ActivityDialog> createState() => _ActivityDialogState();
}

class _ActivityDialogState extends State<ActivityDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late double _energy;

  @override
  void initState() {
    super.initState();
    _name = widget.activity?.name ?? '';
    _startTime = widget.activity?.startTime ?? TimeOfDay.now();
    _endTime = widget.activity?.endTime ??
        TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
    _energy = widget.activity?.energy ?? 5.0;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final activity = Activity(
        id: widget.activity?.id ?? DateTime.now().toIso8601String(),
        name: _name,
        date: widget.activity?.date ?? DateTime.now(),
        startTime: _startTime,
        endTime: _endTime,
        energy: _energy,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _name,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, introduzca un nombre';
                }
                return null;
              },
              onSaved: (value) {
                _name = value!;
              },
            ),
            // Time pickers and other fields would go here
          ],
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

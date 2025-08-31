import 'package:autistock/models/activity.dart';
import 'package:autistock/screens/activity_planner_screen.dart';
import 'package:autistock/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Activity>> _activitiesByDay = {};

  @override
  void initState() {
    super.initState();
    _loadActivitiesByDay();
  }

  Future<void> _loadActivitiesByDay() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final activities = await dataService.getAllActivities();
    final Map<DateTime, List<Activity>> activitiesByDay = {};
    for (var activity in activities) {
      final day = DateTime.utc(
          activity.date.year, activity.date.month, activity.date.day);
      if (activitiesByDay[day] == null) {
        activitiesByDay[day] = [];
      }
      activitiesByDay[day]!.add(activity);
    }
    setState(() {
      _activitiesByDay = activitiesByDay;
    });
  }

  List<Activity> _getEventsForDay(DateTime day) {
    final dayUtc = DateTime.utc(day.year, day.month, day.day);
    return _activitiesByDay[dayUtc] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Actividades'),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: _getEventsForDay,
              calendarBuilders: CalendarBuilders(
                prioritizedBuilder: (context, day, focusedDay) {
                  final events = _getEventsForDay(day);
                  if (events.isNotEmpty) {
                    final isSelected = isSameDay(_selectedDay, day);
                    final isToday = isSameDay(day, DateTime.now());

                    Color dayColor = Colors.lightBlueAccent.withOpacity(0.5);

                    if (events
                        .any((e) => e.status == ActivityStatus.notCompleted)) {
                      dayColor = Colors.red.shade200;
                    } else if (events.any((e) =>
                        e.status == ActivityStatus.completedWithDifficulty)) {
                      dayColor = Colors.yellow.shade200;
                    } else if (events
                        .every((e) => e.status == ActivityStatus.completed)) {
                      dayColor = Colors.green.shade200;
                    }

                    BoxDecoration decoration;
                    TextStyle textStyle = const TextStyle();

                    if (isSelected) {
                      decoration = const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      );
                      textStyle = const TextStyle(color: Colors.white);
                    } else if (isToday) {
                      decoration = BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2),
                        color: dayColor,
                        shape: BoxShape.circle,
                      );
                    } else {
                      decoration = BoxDecoration(
                        color: dayColor,
                        shape: BoxShape.circle,
                      );
                    }

                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: decoration,
                      child: Text(
                        '${day.day}',
                        style: textStyle,
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 8.0),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  Text(
                    'Los días se colorean según el estado de las actividades: Verde (completadas), Amarillo (con dificultad), Rojo (no completadas), Azul (planeadas).',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'El color del borde indica tu nivel de energía para ese día: Verde (energía alta), Naranja (energía neutral), Rojo (energía baja).',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              child: const Text('Añadir/Ver Actividades'),
              onPressed: () async {
                if (_selectedDay != null) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ActivityPlannerScreen(selectedDay: _selectedDay!),
                    ),
                  );
                  _loadActivitiesByDay();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, selecciona un día primero.'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

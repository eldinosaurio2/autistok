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
  List<DateTime> _daysWithActivities = [];

  @override
  void initState() {
    super.initState();
    _loadDaysWithActivities();
  }

  Future<void> _loadDaysWithActivities() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final dates = await dataService.getDatesWithActivities();
    setState(() {
      _daysWithActivities = dates;
    });
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _daysWithActivities.where((date) => isSameDay(date, day)).toList();
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
                  if (_getEventsForDay(day).isNotEmpty) {
                    final isSelected = isSameDay(_selectedDay, day);
                    final isToday = isSameDay(day, DateTime.now());

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
                        color: Colors.lightBlueAccent.withOpacity(0.5),
                        shape: BoxShape.circle,
                      );
                    } else {
                      decoration = BoxDecoration(
                        color: Colors.lightBlueAccent.withOpacity(0.5),
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
            ElevatedButton(
              child: const Text('Añadir Actividad'),
              onPressed: () async {
                if (_selectedDay != null) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ActivityPlannerScreen(selectedDay: _selectedDay!),
                    ),
                  );
                  _loadDaysWithActivities();
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

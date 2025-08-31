import 'package:flutter/material.dart';

enum ActivityStatus {
  planned,
  completed,
  completedWithDifficulty,
  notCompleted,
}

class Activity {
  String id;
  String name;
  DateTime date;
  TimeOfDay startTime;
  TimeOfDay endTime;
  double energy;
  ActivityStatus status;

  Activity({
    required this.id,
    required this.name,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.energy,
    this.status = ActivityStatus.planned,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
      'energy': energy,
      'status': status.toString(),
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    final startTimeParts = json['startTime'].split(':');
    final endTimeParts = json['endTime'].split(':');
    return Activity(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      startTime: TimeOfDay(
          hour: int.parse(startTimeParts[0]),
          minute: int.parse(startTimeParts[1])),
      endTime: TimeOfDay(
          hour: int.parse(endTimeParts[0]), minute: int.parse(endTimeParts[1])),
      energy: json['energy'],
      status: ActivityStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ActivityStatus.planned,
      ),
    );
  }
}

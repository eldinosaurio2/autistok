class MoodEntry {
  final DateTime date;
  final String mood;
  final List<String> activities;
  final String? note;
  final String timeOfDay;

  MoodEntry({
    required this.date,
    required this.mood,
    required this.activities,
    this.note,
    required this.timeOfDay,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      date: DateTime.parse(json['date']),
      mood: json['mood'],
      activities: List<String>.from(json['activities'] ?? []),
      note: json['note'],
      timeOfDay:
          json['timeOfDay'] ?? _getTimeOfDay(DateTime.parse(json['date'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'mood': mood,
      'activities': activities,
      'note': note,
      'timeOfDay': timeOfDay,
    };
  }

  static String _getTimeOfDay(DateTime date) {
    if (date.hour >= 5 && date.hour < 12) {
      return 'Morning';
    } else if (date.hour >= 12 && date.hour < 18) {
      return 'Afternoon';
    } else {
      return 'Night';
    }
  }
}

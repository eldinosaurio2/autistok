class MoodEntry {
  final DateTime date;
  final String mood;
  final List<String> activities;
  final String? notes;
  final int moodScore;

  MoodEntry({
    required this.date,
    required this.mood,
    required this.activities,
    this.notes,
    required this.moodScore,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      date: DateTime.parse(json['date']),
      mood: json['mood'],
      activities: List<String>.from(json['activities'] ?? []),
      notes: json['note'],
      moodScore: json['moodScore'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'mood': mood,
      'activities': activities,
      'note': notes,
      'moodScore': moodScore,
    };
  }
}

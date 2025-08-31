class EnergyEntry {
  final DateTime date;
  final double energyLevel;

  EnergyEntry({required this.date, required this.energyLevel});

  factory EnergyEntry.fromJson(Map<String, dynamic> json) {
    return EnergyEntry(
      date: DateTime.parse(json['date']),
      energyLevel: json['energyLevel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'energyLevel': energyLevel,
    };
  }
}

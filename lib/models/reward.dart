import 'package:autistock/models/mood_entry.dart';

class Reward {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  bool unlocked;
  final bool Function(List<MoodEntry> entries) unlockCondition;

  Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.unlockCondition,
    this.unlocked = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconPath': iconPath,
      'unlocked': unlocked,
    };
  }

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconPath: json['iconPath'],
      unlocked: json['unlocked'],
      unlockCondition: (entries) => false, // Not stored in JSON
    );
  }
}

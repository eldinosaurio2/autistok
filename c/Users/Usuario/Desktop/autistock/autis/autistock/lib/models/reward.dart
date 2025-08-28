class Reward {
  final String id;
  final String title;
  final String description;
  final String icon;
  bool unlocked;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.unlocked = false,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      unlocked: json['unlocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'unlocked': unlocked,
    };
  }
}

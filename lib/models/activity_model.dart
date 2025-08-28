class Activity {
  final String name;
  Activity({required this.name});

  Map<String, dynamic> toJson() => {'name': name};
  factory Activity.fromJson(Map<String, dynamic> json) =>
      Activity(name: json['name']);
}

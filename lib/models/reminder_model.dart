class ReminderModel {
  final String id;
  final String title;
  final String description;
  final DateTime schedule;
  final String type;

  const ReminderModel({
    this.id = '',
    required this.title,
    required this.description,
    required this.schedule,
    required this.type,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      schedule: DateTime.parse(json['schedule'] as String),
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'schedule': schedule.toIso8601String(),
      'type': type,
    };
  }
}

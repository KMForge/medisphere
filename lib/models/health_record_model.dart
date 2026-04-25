class HealthRecordModel {
  final String id;
  final String memberId;
  final DateTime date;
  final String bloodPressure;
  final int heartRate;
  final double weight;
  final double temperature;

  const HealthRecordModel({
    this.id = '',
    required this.memberId,
    required this.date,
    required this.bloodPressure,
    required this.heartRate,
    required this.weight,
    required this.temperature,
  });

  factory HealthRecordModel.fromJson(Map<String, dynamic> json) {
    return HealthRecordModel(
      id: json['id'] as String? ?? '',
      memberId: json['member_id'] as String,
      date: DateTime.parse(json['date'] as String),
      bloodPressure: json['blood_pressure'] as String,
      heartRate: json['heart_rate'] as int,
      weight: (json['weight'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'date': date.toIso8601String(),
      'blood_pressure': bloodPressure,
      'heart_rate': heartRate,
      'weight': weight,
      'temperature': temperature,
    };
  }
}

enum AppointmentStatus { scheduled, confirmed, completed, cancelled }

class AppointmentModel {
  final String id;
  final String memberId;
  final String userId;
  final String patientName;
  final DateTime dateTime;
  final String service;
  final String notes;
  final AppointmentStatus status;

  const AppointmentModel({
    this.id = '',
    required this.memberId,
    this.userId = '',
    this.patientName = '',
    required this.dateTime,
    required this.service,
    required this.notes,
    this.status = AppointmentStatus.scheduled,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String? ?? '',
      memberId: json['member_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      patientName: json['patient_name'] as String? ?? '',
      dateTime: DateTime.parse(json['date_time'] as String),
      service: json['service'] as String,
      notes: json['notes'] as String? ?? '',
      status: AppointmentStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => AppointmentStatus.scheduled,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'date_time': dateTime.toIso8601String(),
      'service': service,
      'notes': notes,
      'status': status.name,
    };
  }
}

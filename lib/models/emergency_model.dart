class EmergencyRequest {
  final String userId;
  final String userName;
  final String contactNumber;
  final String emergencyType;
  final DateTime timestamp;
  final String? location;
  final EmergencyStatus status;

  const EmergencyRequest({
    required this.userId,
    required this.userName,
    required this.contactNumber,
    required this.emergencyType,
    required this.timestamp,
    this.location,
    this.status = EmergencyStatus.pending,
  });

  EmergencyRequest copyWith({
    String? userId,
    String? userName,
    String? contactNumber,
    String? emergencyType,
    DateTime? timestamp,
    String? location,
    EmergencyStatus? status,
  }) {
    return EmergencyRequest(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      contactNumber: contactNumber ?? this.contactNumber,
      emergencyType: emergencyType ?? this.emergencyType,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': userName,
      'contact': contactNumber,
      'emergency_type': emergencyType,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
      'status': status.name,
    };
  }

  factory EmergencyRequest.fromJson(Map<String, dynamic> json) {
    return EmergencyRequest(
      userId: json['user_id'] as String,
      userName: (json['name'] ?? json['user_name'] ?? '') as String,
      contactNumber:
          (json['contact'] ?? json['contact_number'] ?? '') as String,
      emergencyType: json['emergency_type'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      location: json['location'] as String?,
      status: EmergencyStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => EmergencyStatus.pending,
      ),
    );
  }
}

enum EmergencyStatus { pending, inProgress, resolved }

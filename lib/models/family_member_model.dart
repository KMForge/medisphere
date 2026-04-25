import 'package:uuid/uuid.dart';

class FamilyMemberModel {
  final String memberId;
  final String name;
  final String relationship;
  final DateTime dateOfBirth;
  final String gender;
  final String? bloodType;
  final String? conditions;
  final bool isPrimaryAccount;
  final DateTime createdAt;

  FamilyMemberModel({
    String? memberId,
    required this.name,
    required this.relationship,
    required this.dateOfBirth,
    required this.gender,
    this.bloodType,
    this.conditions,
    this.isPrimaryAccount = false,
    DateTime? createdAt,
  }) : memberId = memberId ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  int get age {
    final now = DateTime.now();
    int years = now.year - dateOfBirth.year;
    final hasHadBirthdayThisYear =
        (now.month > dateOfBirth.month) ||
        (now.month == dateOfBirth.month && now.day >= dateOfBirth.day);
    if (!hasHadBirthdayThisYear) years -= 1;
    return years;
  }

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      memberId: (json['id'] ?? json['member_id']) as String,
      name: json['name'] as String,
      relationship: json['relationship'] as String,
      dateOfBirth: DateTime.parse(json['date_of_birth'] as String),
      gender: json['gender'] as String,
      bloodType: json['blood_type'] as String?,
      conditions: json['conditions'] as String?,
      isPrimaryAccount: json['is_primary_account'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relationship': relationship,
      'date_of_birth':
          '${dateOfBirth.year}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}',
      'gender': gender,
      'blood_type': bloodType,
      'conditions': conditions,
      'is_primary_account': isPrimaryAccount,
    };
  }

  FamilyMemberModel copyWith({
    String? name,
    String? relationship,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodType,
    String? conditions,
    bool? isPrimaryAccount,
  }) {
    return FamilyMemberModel(
      memberId: memberId,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      conditions: conditions ?? this.conditions,
      isPrimaryAccount: isPrimaryAccount ?? this.isPrimaryAccount,
      createdAt: createdAt,
    );
  }
}

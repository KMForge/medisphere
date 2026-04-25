class UserModel {
  final String id;
  final String fullName;
  final String username;
  final String email;
  final String role;
  final String avatarUrl;
  final int? age;
  final String? phone;

  const UserModel({
    this.id = '',
    required this.fullName,
    required this.username,
    required this.email,
    this.role = 'Barangay Health Admin',
    this.avatarUrl = '',
    this.age,
    this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'Barangay Health Admin',
      avatarUrl: json['avatar_url'] as String? ?? '',
      age: json['age'] as int?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'username': username,
      'email': email,
      'role': role,
      'avatar_url': avatarUrl,
      'age': age,
      'phone': phone,
    };
  }

  UserModel copyWith({
    String? fullName,
    String? username,
    String? email,
    String? role,
    String? avatarUrl,
    int? age,
    String? phone,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      age: age ?? this.age,
      phone: phone ?? this.phone,
    );
  }
}

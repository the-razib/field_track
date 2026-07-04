import 'package:field_track/features/auth/domain/entities/user.dart';

/// Data model for User — handles JSON serialization.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? json['fullName'] as String? ?? json['name'] as String? ?? '',
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      if (role != null) 'role': role,
    };
  }
}

import 'package:equatable/equatable.dart';

/// Domain entity representing an authenticated user.
class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? role;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.role,
  });

  /// Get initials for avatar display (e.g., "JD" for "John Doe").
  String get initials {
    final name = displayName;
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  /// Get user's display name, falling back to email prefix if full name is empty.
  String get displayName {
    if (fullName.trim().isNotEmpty) {
      return fullName;
    }
    if (email.contains('@')) {
      final localPart = email.split('@').first;
      if (localPart.isNotEmpty) {
        return localPart[0].toUpperCase() + localPart.substring(1);
      }
      return localPart;
    }
    return email.isNotEmpty ? email : 'User';
  }

  @override
  List<Object?> get props => [id, email, fullName, role];
}

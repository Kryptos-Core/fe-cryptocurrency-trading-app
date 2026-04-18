import 'package:crypto_trading_app/features/user/domain/entities/user.dart';

/// User data model for JSON serialization/deserialization
/// Implements toJson and fromJson methods for API communication
class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final bool isActive;
  final String status;
  final String role;
  final String? avatarUrl;
  final bool twoFaEnabled;
  final bool identityVerified;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    this.status = 'ACTIVE',
    this.role = 'TRADER',
    this.avatarUrl,
    this.twoFaEnabled = false,
    this.identityVerified = false,
    this.emailVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert UserModel to User entity
  User toEntity() {
    return User(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      isActive: isActive,
      status: status,
      role: role,
      avatarUrl: avatarUrl,
      twoFaEnabled: twoFaEnabled,
      identityVerified: identityVerified,
      emailVerified: emailVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create UserModel from JSON
  /// Handles both snake_case (from register/login) and camelCase (from other endpoints) formats
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final u = User.fromJson(json);
    return UserModel(
      id: u.id,
      email: u.email,
      firstName: u.firstName,
      lastName: u.lastName,
      isActive: u.isActive,
      status: u.status,
      role: u.role,
      avatarUrl: u.avatarUrl,
      twoFaEnabled: u.twoFaEnabled,
      identityVerified: u.identityVerified,
      emailVerified: u.emailVerified,
      createdAt: u.createdAt,
      updatedAt: u.updatedAt,
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'isActive': isActive,
      'status': status,
      'role': role,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'twoFaEnabled': twoFaEnabled,
      'identityVerified': identityVerified,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

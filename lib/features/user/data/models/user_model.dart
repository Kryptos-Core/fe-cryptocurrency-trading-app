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
    // Handle both camelCase and snake_case field names from backend
    final id = (json['id'] ?? json['user_id'] ?? '').toString();
    final email = json['email'] as String? ?? '';
    final firstName = (json['firstName'] ?? json['first_name'] ?? '') as String;
    final lastName = (json['lastName'] ?? json['last_name'] ?? '') as String;
    final statusStr = json['status'] as String? ?? '';
    final isActive = json['isActive'] as bool? ??
                     (statusStr == 'ACTIVE' ? true : false);
    final status = statusStr.isNotEmpty
        ? statusStr
        : (isActive ? 'ACTIVE' : 'BANNED');
    final role = json['role'] as String? ?? 'TRADER';
    final avatarUrl = json['avatar_url'] as String? ?? json['avatarUrl'] as String?;
    final twoFaEnabledRaw = json['two_fa_enabled'] ?? json['twoFaEnabled'] ?? 0;
    final twoFaEnabled = twoFaEnabledRaw == true || twoFaEnabledRaw == 1 || twoFaEnabledRaw == '1';
    final idvRaw = json['identity_verified'] ?? json['identityVerified'] ?? 0;
    final identityVerified =
        idvRaw == true || idvRaw == 1 || idvRaw == '1';
    final evRaw = json['email_verified'] ?? json['emailVerified'] ?? 0;
    final emailVerified =
        evRaw == true || evRaw == 1 || evRaw == '1';

    // Parse createdAt - handle both ISO 8601 string and snake_case key
    final createdAtStr = json['createdAt'] as String? ?? json['created_at'] as String?;
    final createdAt = createdAtStr != null 
        ? DateTime.parse(createdAtStr) 
        : DateTime.now();
    
    // Parse updatedAt - handle both ISO 8601 string and snake_case key
    final updatedAtStr = json['updatedAt'] as String? ?? json['updated_at'] as String?;
    final updatedAt = updatedAtStr != null 
        ? DateTime.parse(updatedAtStr) 
        : DateTime.now();
    
    return UserModel(
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

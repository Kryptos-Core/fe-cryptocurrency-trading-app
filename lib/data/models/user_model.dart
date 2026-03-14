import 'package:crypto_trading_app/domain/entities/user.dart';

/// User data model for JSON serialization/deserialization
/// Implements toJson and fromJson methods for API communication
class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final bool isActive;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    this.role = 'TRADER',
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
      role: role,
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
    final isActive = json['isActive'] as bool? ?? 
                     (json['status'] == 'ACTIVE' ? true : false);
    final role = json['role'] as String? ?? 'TRADER';
    
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
      role: role,
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
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

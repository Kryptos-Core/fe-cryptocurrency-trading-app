import 'package:crypto_trading_app/features/auth/domain/entities/dev_user_pick.dart';

/// JSON model for `DevUserPick` (response of `GET /auth/sandbox-users`).
class DevUserPickModel {
  final String userId;
  final String email;
  final String? firstName;
  final String? lastName;
  final String role;
  final String status;
  final String? avatarUrl;
  final DateTime createdAt;

  const DevUserPickModel({
    required this.userId,
    required this.email,
    this.firstName,
    this.lastName,
    required this.role,
    required this.status,
    this.avatarUrl,
    required this.createdAt,
  });

  factory DevUserPickModel.fromJson(Map<String, dynamic> json) {
    return DevUserPickModel(
      userId: json['userId'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      role: json['role'] as String,
      status: json['status'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  DevUserPick toEntity() => DevUserPick(
        userId: userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: role,
        status: status,
        avatarUrl: avatarUrl,
        createdAt: createdAt,
      );
}

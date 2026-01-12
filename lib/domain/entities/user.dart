import 'package:equatable/equatable.dart';

/// User Entity - Domain Layer
/// Following Single Responsibility Principle (SRP)
/// Pure business object without any framework dependencies
class User extends Equatable {
  final int userId;
  final String email;
  final UserStatus status;
  final bool has2FA;
  final DateTime createdAt;

  const User({
    required this.userId,
    required this.email,
    required this.status,
    this.has2FA = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [userId, email, status, has2FA, createdAt];

  User copyWith({
    int? userId,
    String? email,
    UserStatus? status,
    bool? has2FA,
    DateTime? createdAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      status: status ?? this.status,
      has2FA: has2FA ?? this.has2FA,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum UserStatus {
  active,
  banned,
  pending,
}

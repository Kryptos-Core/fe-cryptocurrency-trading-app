/// User entity representing a user in the system
/// Following Clean Architecture - Domain Layer
/// Matches backend User entity structure
class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final bool isActive;

  /// Raw status string from backend: 'ACTIVE' | 'BANNED' | 'PENDING'
  final String status;
  final String role;
  final String? avatarUrl;
  final bool twoFaEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    String? status,
    this.role = 'TRADER',
    this.avatarUrl,
    this.twoFaEnabled = false,
    required this.createdAt,
    required this.updatedAt,
  }) : status = status ?? (isActive ? 'ACTIVE' : 'BANNED');

  /// Full name của user
  /// Returns email if both first and last names are empty
  String get fullName {
    final first = firstName.trim();
    final last = lastName.trim();
    
    if (first.isEmpty && last.isEmpty) {
      return email;
    } else if (first.isEmpty) {
      return last;
    } else if (last.isEmpty) {
      return first;
    } else {
      return '$first $last';
    }
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    bool? isActive,
    String? status,
    String? role,
    String? avatarUrl,
    bool? twoFaEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      twoFaEnabled: twoFaEnabled ?? this.twoFaEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, role: $role, isActive: $isActive, twoFaEnabled: $twoFaEnabled)';
  }
}

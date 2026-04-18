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
  /// Đã xác minh định danh (CCCD/Passport) — khớp BE users.identity_verified.
  final bool identityVerified;

  /// Đã xác minh inbox qua OTP (2FA hoặc luồng email liên hệ ví) — khớp BE users.email_verified.
  final bool emailVerified;
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
    this.identityVerified = false,
    this.emailVerified = false,
    required this.createdAt,
    required this.updatedAt,
  }) : status = status ?? (isActive ? 'ACTIVE' : 'BANNED');

  /// Parse API / register-login JSON (camelCase + snake_case).
  factory User.fromJson(Map<String, dynamic> json) {
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
    final twoFaEnabled =
        twoFaEnabledRaw == true || twoFaEnabledRaw == 1 || twoFaEnabledRaw == '1';
    final idvRaw = json['identity_verified'] ?? json['identityVerified'] ?? 0;
    final identityVerified = idvRaw == true || idvRaw == 1 || idvRaw == '1';
    final evRaw = json['email_verified'] ?? json['emailVerified'] ?? 0;
    final emailVerified = evRaw == true || evRaw == 1 || evRaw == '1';

    final createdAtStr =
        json['createdAt'] as String? ?? json['created_at'] as String?;
    final createdAt = createdAtStr != null
        ? DateTime.parse(createdAtStr)
        : DateTime.now();

    final updatedAtStr =
        json['updatedAt'] as String? ?? json['updated_at'] as String?;
    final updatedAt = updatedAtStr != null
        ? DateTime.parse(updatedAtStr)
        : DateTime.now();

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
    bool? identityVerified,
    bool? emailVerified,
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
      identityVerified: identityVerified ?? this.identityVerified,
      emailVerified: emailVerified ?? this.emailVerified,
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

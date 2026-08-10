/// Lightweight projection of an ACTIVE user used by the sandbox login picker.
/// Field names are camelCase to match the JSON we receive from `/auth/sandbox-users`.
class DevUserPick {
  final String userId;
  final String email;
  final String? firstName;
  final String? lastName;
  final String role;
  final String status;
  final String? avatarUrl;
  final DateTime createdAt;

  const DevUserPick({
    required this.userId,
    required this.email,
    this.firstName,
    this.lastName,
    required this.role,
    required this.status,
    this.avatarUrl,
    required this.createdAt,
  });

  /// Best-effort display name — falls back to email when both names are absent.
  String get displayName {
    final first = (firstName ?? '').trim();
    final last = (lastName ?? '').trim();
    if (first.isEmpty && last.isEmpty) return email;
    return [first, last].where((p) => p.isNotEmpty).join(' ');
  }
}

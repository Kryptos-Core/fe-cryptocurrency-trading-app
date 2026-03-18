import 'package:crypto_trading_app/core/constants/api_constants.dart';

/// Resolves an avatar URL to an absolute URL.
///
/// Backend may store relative paths like `/uploads/avatars/uuid.jpg`.
/// This helper prepends [ApiConstants.serverOrigin] so [NetworkImage] can load
/// them correctly regardless of the deployment environment.
String? resolveAvatarUrl(String? rawUrl) {
  if (rawUrl == null || rawUrl.isEmpty) return null;
  if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
    return rawUrl;
  }
  // Relative path — prepend server origin (host:port without /api/v1 path)
  final origin = ApiConstants.serverOrigin;
  final path = rawUrl.startsWith('/') ? rawUrl : '/$rawUrl';
  return '$origin$path';
}

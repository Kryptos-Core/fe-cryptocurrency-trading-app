import 'package:shared_preferences/shared_preferences.dart';

/// Token Service for managing JWT tokens
/// Stores and retrieves access token and refresh token
class TokenService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  final SharedPreferences sharedPreferences;

  TokenService({required this.sharedPreferences});

  /// Save access token
  Future<bool> saveAccessToken(String token) async {
    return await sharedPreferences.setString(_accessTokenKey, token);
  }

  /// Save refresh token
  Future<bool> saveRefreshToken(String token) async {
    return await sharedPreferences.setString(_refreshTokenKey, token);
  }

  /// Save both tokens
  /// refreshToken can be null if backend doesn't provide it
  Future<bool> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    final accessSaved = await saveAccessToken(accessToken);
    // Only save refresh token if it's provided
    final refreshSaved = refreshToken != null 
        ? await saveRefreshToken(refreshToken)
        : true;
    return accessSaved && refreshSaved;
  }

  /// Get access token
  String? getAccessToken() {
    return sharedPreferences.getString(_accessTokenKey);
  }

  /// Get refresh token
  String? getRefreshToken() {
    return sharedPreferences.getString(_refreshTokenKey);
  }

  /// Check if user is authenticated (has access token)
  bool isAuthenticated() {
    final token = getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all tokens (logout)
  Future<bool> clearTokens() async {
    final accessRemoved = await sharedPreferences.remove(_accessTokenKey);
    final refreshRemoved = await sharedPreferences.remove(_refreshTokenKey);
    return accessRemoved && refreshRemoved;
  }

  /// Clear only access token
  Future<bool> clearAccessToken() async {
    return await sharedPreferences.remove(_accessTokenKey);
  }
}

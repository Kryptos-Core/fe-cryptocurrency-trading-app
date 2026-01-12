import 'package:crypto_trading_app/data/models/user_model.dart';

/// Auth response model for login endpoint
/// Contains access token, optional refresh token and user info
class AuthResponseModel {
  final String accessToken;
  final String? refreshToken;
  final UserModel user;

  const AuthResponseModel({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  /// Create AuthResponseModel from JSON
  /// Handles cases where refreshToken may not be present
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  /// Convert AuthResponseModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }
}

import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/enums/user_role.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/data/repositories/auth_repository_impl.dart';
import 'package:crypto_trading_app/domain/entities/user.dart';

/// AuthProvider — single source of truth for authentication state.
///
/// Responsibilities:
/// - Hold current [User] and decoded [UserRole] + [permissions] from JWT claims
/// - Provide role/permission predicates used by the UI to show/hide features
/// - Drive login / logout lifecycle (save / clear tokens, update state)
/// - Expose [handleForbidden] so [DioClient] can notify the UI on 403 errors
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final TokenService _tokenService;

  User? _currentUser;
  UserRole _role = UserRole.trader;
  List<String> _permissions = [];
  bool _isAuthenticated = false;

  /// True for one broadcast cycle when a 403 is received from the server.
  /// Consuming widgets (e.g. [MainScreen]) show a SnackBar and reset this.
  bool lastRequestForbidden = false;

  AuthProvider({
    required AuthRepository authRepository,
    required TokenService tokenService,
  })  : _authRepository = authRepository,
        _tokenService = tokenService;

  // ── Getters ────────────────────────────────────────────────────────────────

  User? get currentUser => _currentUser;
  UserRole get role => _role;
  List<String> get permissions => _permissions;
  bool get isAuthenticated => _isAuthenticated;

  bool get isAdmin => _role == UserRole.admin;
  bool get isSupportAgent => _role == UserRole.supportAgent;
  bool get isRiskOfficer => _role == UserRole.riskOfficer;
  bool get canSyncExchange => isAdmin && hasPermission('exchange:sync');

  /// True for roles that can view the user list (admin, support, risk officer).
  bool get canViewUserList => isAdmin || isSupportAgent || isRiskOfficer;

  bool hasPermission(String permission) => _permissions.contains(permission);

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Restore authentication state from a previously stored JWT.
  /// Call once during app startup (inside the Provider `create` callback).
  void restoreSession() {
    final token = _tokenService.getAccessToken();
    if (token == null || token.isEmpty) return;

    final claims = _decodeJwt(token);
    if (claims.isEmpty) return;

    _role = UserRole.fromString(claims['role'] as String?);
    _permissions = _parsePermissions(claims['permissions']);
    _isAuthenticated = true;
    notifyListeners();
  }

  /// Authenticate the user. Saves tokens, decodes JWT claims, updates providers.
  Future<Either<Failure, void>> login({
    required String email,
    required String password,
  }) async {
    final result =
        await _authRepository.login(email: email, password: password);

    return result.fold(
      Left.new,
      (authResponse) async {
        await _tokenService.saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );

        _currentUser = authResponse.user;

        // JWT claims are authoritative for role/permissions (snapshot at issue time).
        final claims = _decodeJwt(authResponse.accessToken);
        _role = UserRole.fromString(
          claims['role'] as String? ?? authResponse.user.role,
        );
        _permissions = _parsePermissions(claims['permissions']);
        _isAuthenticated = true;
        notifyListeners();

        return const Right(null);
      },
    );
  }

  /// Clear all auth state and stored tokens.
  Future<void> logout() async {
    await _tokenService.clearTokens();
    _currentUser = null;
    _role = UserRole.trader;
    _permissions = [];
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Called by [DioClient] when a 403 Forbidden response is received.
  /// Triggers a transient notification used by the UI to show a SnackBar.
  void handleForbidden() {
    lastRequestForbidden = true;
    notifyListeners();
    // Auto-reset so the flag doesn't persist across rebuilds.
    Future.delayed(const Duration(seconds: 3), () {
      lastRequestForbidden = false;
      notifyListeners();
    });
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Base64url-decode the JWT payload section without verifying the signature.
  /// Used only for reading claims on the client side; the server validates the
  /// signature on every request.
  Map<String, dynamic> _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};
      final padded = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(padded));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  List<String> _parsePermissions(dynamic raw) {
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }
}

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
  bool _identityVerified = false;
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
  bool get isMarketMaker => _role == UserRole.marketMaker;
  bool get isFinanceManager => _role == UserRole.financeManager;

  /// Đã xác minh định danh (CCCD/Passport) — từ JWT; đăng nhập lại sau khi admin cập nhật DB.
  bool get isIdentityVerified => _identityVerified;

  /// Tổng quan + monitoring (dashboard) — admin, risk, finance, support.
  bool get canViewOpsDashboard =>
      isAdmin || isRiskOfficer || isFinanceManager || isSupportAgent;

  bool get canAccessMarketMakerHub =>
      isMarketMaker || hasPermission('market_maker:dashboard');
  bool get canSyncExchange => isAdmin && hasPermission('exchange:sync');

  /// True for roles that can create/edit/delete currencies (ADMIN or currencies:manage permission).
  bool get canManageCurrencies =>
      isAdmin || hasPermission('currencies:manage');

  /// True for roles that can view the user list (admin, support, risk officer).
  bool get canViewUserList => isAdmin || isSupportAgent || isRiskOfficer;

  /// True for roles that can review security change requests (admin, risk officer).
  bool get canReviewSecurityRequests =>
      hasPermission('users:security_review') || isAdmin || isRiskOfficer;

  /// True for roles that can manually adjust user wallet balances (admin, risk officer).
  bool get canManageWallets =>
      hasPermission('wallets:manage') || isAdmin || isRiskOfficer;

  /// True for roles that can manage payment gateway configurations (admin, finance manager).
  bool get canManagePaymentConfigs =>
      hasPermission('payment_configs:manage') || isAdmin || isFinanceManager;

  bool hasPermission(String permission) => _permissions.contains(permission);

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Restore authentication state from a previously stored JWT.
  /// Call once during app startup (inside the Provider `create` callback).
  ///
  /// Role/permissions are decoded synchronously from the JWT claims so the UI
  /// can render immediately. The full user profile is then fetched in the
  /// background so the drawer header and avatar populate without blocking.
  void restoreSession() {
    final token = _tokenService.getAccessToken();
    if (token == null || token.isEmpty) return;

    final claims = _decodeJwt(token);
    if (claims.isEmpty) return;

    _role = UserRole.fromString(claims['role'] as String?);
    _permissions = _parsePermissions(claims['permissions']);
    _identityVerified = _parseIdentityVerified(claims);
    _isAuthenticated = true;
    notifyListeners();

    // Background-fetch the full user profile (drawer name, avatar, etc.)
    _refreshCurrentUser(token);
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _refreshCurrentUser(String token) async {
    final result = await _authRepository.getCurrentUser(token);
    result.fold(
      (_) {}, // silent: token is valid but profile fetch failed — not critical
      (user) {
        _currentUser = user;
        _identityVerified = user.identityVerified;
        notifyListeners();
      },
    );
  }

  /// Authenticate the user. Saves tokens, decodes JWT claims, updates providers.
  Future<Either<Failure, void>> login({
    required String email,
    required String password,
  }) async {
    final result =
        await _authRepository.login(email: email, password: password);
    return result.fold(Left.new, (r) async => _applyAuthResponse(r));
  }

  /// Đăng nhập hoặc đăng ký bằng ví (MetaMask / TronLink).
  /// BE tự tạo tài khoản nếu chưa tồn tại và liên kết ví luôn.
  Future<Either<Failure, void>> loginWithWallet({
    required String chain,
    required String address,
    required String signature,
  }) async {
    final result = await _authRepository.loginWithWallet(
      chain: chain,
      address: address,
      signature: signature,
    );
    return result.fold(Left.new, (r) async => _applyAuthResponse(r));
  }

  /// Hoàn tất đăng nhập sau flow public WalletConnect (POST /auth/wallet/wc/verify).
  Future<Either<Failure, void>> completeWalletConnectAuthLogin({
    required String sessionId,
    required String chain,
    required String address,
    required String signature,
  }) async {
    final result = await _authRepository.verifyWalletWcAuth(
      sessionId: sessionId,
      chain: chain,
      address: address,
      signature: signature,
    );
    return result.fold(Left.new, (r) async => _applyAuthResponse(r));
  }

  /// Clear all auth state and stored tokens.
  Future<void> logout() async {
    await _tokenService.clearTokens();
    _currentUser = null;
    _role = UserRole.trader;
    _permissions = [];
    _identityVerified = false;
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Cập nhật currentUser sau khi sửa hồ sơ hoặc avatar (đồng bộ drawer và UI).
  void updateCurrentUser(User user) {
    _currentUser = user;
    _identityVerified = user.identityVerified;
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

  /// Lưu token, decode JWT claims, cập nhật state sau login/register thành công.
  Future<Right<Failure, void>> _applyAuthResponse(AuthResponse authResponse) async {
    await _tokenService.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );
    _currentUser = authResponse.user;
    final claims = _decodeJwt(authResponse.accessToken);
    _role = UserRole.fromString(
      claims['role'] as String? ?? authResponse.user.role,
    );
    _permissions = _parsePermissions(claims['permissions']);
    _identityVerified = _parseIdentityVerified(claims);
    _isAuthenticated = true;
    notifyListeners();
    return const Right(null);
  }

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

  bool _parseIdentityVerified(Map<String, dynamic> claims) {
    final v = claims['identityVerified'] ?? claims['identity_verified'];
    if (v == true || v == 1 || v == '1' || v == 'true') return true;
    final role = (claims['role'] as String?)?.toUpperCase();
    if (role == 'VERIFIED_USER') return true;
    return false;
  }
}

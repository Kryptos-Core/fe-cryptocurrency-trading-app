import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/enums/user_role.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/core/utils/wallet_placeholder_email.dart';
import 'package:crypto_trading_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:crypto_trading_app/features/user/domain/entities/user.dart';
import 'package:http/http.dart' as http;

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

  /// Raw `role` claim từ JWT (hoặc user.role sau login) — để hiển thị khi [_role] là [UserRole.unrecognized].
  String? _roleClaimRaw;
  List<String> _permissions = [];
  bool _identityVerified = false;
  bool _emailVerifiedFromJwt = false;
  bool _isAuthenticated = false;

  /// Email verification required — defaults to true (secure by default).
  /// Loaded from BE when the user is ADMIN via [refreshAuthSecurityFlags].
  bool _emailVerificationRequired = true;

  /// Treasury main-wallet TOTP required — defaults to true (secure by default).
  /// Even when set to false, the backend hard-enforces TOTP on production on-chain mode.
  /// Loaded from BE alongside [refreshAuthSecurityFlags].
  bool _treasuryWalletTotpRequired = true;
  final http.Client _httpClient;

  /// True for one broadcast cycle when a 403 is received from the server.
  /// Consuming widgets (e.g. [MainScreen]) show a SnackBar and reset this.
  bool lastRequestForbidden = false;

  AuthProvider({
    required AuthRepository authRepository,
    required TokenService tokenService,
    http.Client? httpClient,
  })  : _authRepository = authRepository,
        _tokenService = tokenService,
        _httpClient = httpClient ?? http.Client();

  // ── Getters ────────────────────────────────────────────────────────────────

  User? get currentUser => _currentUser;
  UserRole get role => _role;
  String? get roleClaimRaw => _roleClaimRaw;

  /// Nhãn role cho UI (drawer): humanize mã mới khi chưa có enum.
  String get roleDisplayLabel =>
      UserRole.formatDisplayLabel(_role, rawRoleClaim: _roleClaimRaw);
  List<String> get permissions => _permissions;
  bool get isAuthenticated => _isAuthenticated;

  bool get isAdmin => _role == UserRole.admin;
  bool get isSupportAgent => _role == UserRole.supportAgent;
  bool get isRiskOfficer => _role == UserRole.riskOfficer;
  bool get isMarketMaker => _role == UserRole.marketMaker;
  bool get isFinanceManager => _role == UserRole.financeManager;

  /// Đã xác minh định danh (CCCD/Passport) — từ JWT; đăng nhập lại sau khi admin cập nhật DB.
  bool get isIdentityVerified => _identityVerified;

  /// Đã xác minh inbox qua OTP (JWT hoặc user từ API). Khách (chưa đăng nhập) luôn false.
  bool get isEmailVerified =>
      _currentUser?.emailVerified ?? _emailVerifiedFromJwt;

  /// Email thật (không phải placeholder `@*.wallet` từ đăng nhập ví) — cần để nhận OTP qua mail.
  bool get hasRealEmailForOtp {
    final u = _currentUser;
    if (u == null) return false;
    return !isWalletPlaceholderEmail(u.email);
  }

  /// Tổng quan + monitoring (dashboard) — admin, risk, finance, support.
  bool get canViewOpsDashboard =>
      isAdmin || isRiskOfficer || isFinanceManager || isSupportAgent;

  bool get canAccessMarketMakerHub =>
      isMarketMaker || hasPermission('market_maker:dashboard');
  bool get canSyncExchange => isAdmin && hasPermission('exchange:sync');

  /// True for roles that can create/edit/delete currencies (ADMIN or currencies:manage permission).
  bool get canManageCurrencies => isAdmin || hasPermission('currencies:manage');

  /// True for roles that can view the user list (admin, support, risk officer).
  bool get canViewUserList => isAdmin || isSupportAgent || isRiskOfficer;

  /// True for roles that can review security change requests (admin, risk officer).
  bool get canReviewSecurityRequests =>
      hasPermission('users:security_review') || isAdmin || isRiskOfficer;

  /// True for roles that can adjust user balances, managed deposit wallets, and related ops
  /// (admin, risk officer, finance manager — aligned with backend `WALLETS_MANAGE`).
  bool get canManageWallets =>
      hasPermission('wallets:manage') ||
      isAdmin ||
      isRiskOfficer ||
      isFinanceManager;

  /// True for roles that can manage payment gateway configurations (admin, finance manager).
  bool get canManagePaymentConfigs =>
      hasPermission('payment_configs:manage') || isAdmin || isFinanceManager;

  bool get canManageTreasuryE2EConfigs =>
      hasPermission('treasury_e2e_configs:manage') || isAdmin || isFinanceManager;

  // ── Runtime Settings ────────────────────────────────────────────────────────

  /// TECH: manage TECH runtime settings (RPC URLs, blockchain infra)
  bool get canEditSystemConfigTech =>
      hasPermission('system_config:edit_tech') || isAdmin;

  /// FINANCE: manage FINANCE runtime settings (withdraw limits, rate fallbacks, MM defaults)
  bool get canEditSystemConfigFinance =>
      hasPermission('system_config:edit_finance') || isAdmin || isFinanceManager;

  /// OPS: manage OPS runtime settings (matching engine, Go aggregator, outbox, rollout)
  bool get canEditSystemConfigOps =>
      hasPermission('system_config:edit_ops') || isAdmin;

  /// CORE: manage CORE runtime settings (symbols, market sources, wallet config)
  bool get canEditSystemConfigCore =>
      hasPermission('system_config:edit_core') || isAdmin;

  /// AUTH_SECURITY: manage AUTH_SECURITY runtime settings (email verification toggle)
  bool get canEditSystemConfigAuthSecurity =>
      hasPermission('system_config:edit_auth_security') || isAdmin;

  /// Whether email verification (OTP gating) is currently required.
  /// False means admin has disabled it and all OTP flows are bypassed.
  bool get emailVerificationRequired => _emailVerificationRequired;

  /// Whether TOTP gating is currently required for treasury main-wallet
  /// operations (import / reveal private key). False means admin has disabled
  /// it (sandbox only — backend still enforces on production on-chain mode).
  bool get treasuryWalletTotpRequired => _treasuryWalletTotpRequired;

  /// True when BOTH email-OTP and treasury-TOTP gating are off — i.e. the
  /// user can perform every sensitive operation without a one-time code.
  bool get canBypassAllSensitiveOps =>
      !_emailVerificationRequired && !_treasuryWalletTotpRequired;

  /// Fetch the latest auth/security runtime flags from BE in one round-trip.
  /// Safe to call on every screen for any authenticated user.
  Future<void> refreshAuthSecurityFlags() async {
    try {
      final token = _tokenService.getAccessToken();
      if (token == null) return;
      final resp = await _httpClient.get(
        Uri.parse('${ApiConstants.baseUrl}/auth/auth-security-flags'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        final data = (decoded is Map && decoded['success'] == true)
            ? decoded['data']
            : decoded;
        if (data is Map) {
          var changed = false;
          if (data.containsKey('emailVerificationRequired')) {
            final newEmailFlag = data['emailVerificationRequired'] == true;
            if (newEmailFlag != _emailVerificationRequired) {
              _emailVerificationRequired = newEmailFlag;
              changed = true;
            }
          }
          if (data.containsKey('treasuryWalletTotpRequired')) {
            final newTotpFlag = data['treasuryWalletTotpRequired'] == true;
            if (newTotpFlag != _treasuryWalletTotpRequired) {
              _treasuryWalletTotpRequired = newTotpFlag;
              changed = true;
            }
          }
          if (changed) notifyListeners();
        }
      }
    } catch (_) {
      // Non-critical: keep the in-memory value
    }
  }

  /// Back-compat wrapper for callers still using the older name.
  /// Equivalent to [refreshAuthSecurityFlags].
  Future<void> refreshEmailVerificationRequired() =>
      refreshAuthSecurityFlags();

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

    _roleClaimRaw = _normalizeRoleRaw(claims['role'] as String?);
    _role = UserRole.fromString(_roleClaimRaw);
    _permissions = _parsePermissions(claims['permissions']);
    _identityVerified = _parseIdentityVerified(claims);
    _emailVerifiedFromJwt = _parseEmailVerified(claims);
    _isAuthenticated = true;
    notifyListeners();

    // Background-fetch the full user profile (drawer name, avatar, etc.)
    _refreshCurrentUser(token);

    // Also fetch the email verification required flag (for OTP gating in UI).
    refreshEmailVerificationRequired();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _refreshCurrentUser(String token) async {
    final result = await _authRepository.getCurrentUser(token);
    result.fold(
      (_) {}, // silent: token is valid but profile fetch failed — not critical
      (user) {
        _currentUser = user;
        _identityVerified = user.identityVerified;
        _emailVerifiedFromJwt = user.emailVerified;
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

  /// Register user profile and return created user information.
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) {
    return _authRepository.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
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
    _roleClaimRaw = null;
    _permissions = [];
    _identityVerified = false;
    _emailVerifiedFromJwt = false;
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Cập nhật currentUser sau khi sửa hồ sơ hoặc avatar (đồng bộ drawer và UI).
  void updateCurrentUser(User user) {
    _currentUser = user;
    _identityVerified = user.identityVerified;
    _emailVerifiedFromJwt = user.emailVerified;
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
  Future<Right<Failure, void>> _applyAuthResponse(
      AuthResponse authResponse) async {
    await _tokenService.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );
    _currentUser = authResponse.user;
    final claims = _decodeJwt(authResponse.accessToken);
    final claimRole = claims['role'] as String?;
    _roleClaimRaw = _normalizeRoleRaw(claimRole) ??
        _normalizeRoleRaw(authResponse.user.role);
    _role = UserRole.fromString(claimRole ?? authResponse.user.role);
    _permissions = _parsePermissions(claims['permissions']);
    _identityVerified = _parseIdentityVerified(claims);
    _emailVerifiedFromJwt = _parseEmailVerified(claims);
    _isAuthenticated = true;
    notifyListeners();
    return const Right(null);
  }

  String? _normalizeRoleRaw(String? value) {
    final t = value?.trim();
    if (t == null || t.isEmpty) return null;
    return t;
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

  bool _parseEmailVerified(Map<String, dynamic> claims) {
    final v = claims['emailVerified'] ?? claims['email_verified'];
    if (v == true || v == 1 || v == '1' || v == 'true') return true;
    return false;
  }
}


import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/data/datasources/treasury_remote_datasource.dart';
import 'package:crypto_trading_app/data/models/treasury_model.dart';
import 'package:crypto_trading_app/data/repositories/auth_repository_impl.dart';

class TreasuryMainWalletProvider extends ChangeNotifier {
  final TreasuryRemoteDataSource _dataSource;
  final AuthRepository _authRepo;
  final TokenService _tokenService;

  TreasuryMainWalletProvider({
    required TreasuryRemoteDataSource dataSource,
    required AuthRepository authRepo,
    required TokenService tokenService,
  })  : _dataSource = dataSource,
        _authRepo = authRepo,
        _tokenService = tokenService;

  List<TreasuryMainWalletModel> _mainWallets = [];
  List<TreasuryMainWalletModel> _pendingWallets = [];

  List<TreasuryMainWalletModel> get mainWallets => _mainWallets;
  List<TreasuryMainWalletModel> get pendingWallets => _pendingWallets;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _error;
  String? get error => _error;

  String _currentChain = 'TRON_NILE';
  String get currentChain => _currentChain;

  void setChain(String chain) {
    if (_currentChain == chain) return;
    _currentChain = chain;
    loadMainWallets();
  }

  Future<void> loadMainWallets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _dataSource.listMainWallets(_currentChain);
      _mainWallets = list;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingWallets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _dataSource.listPendingMainWallets();
      _pendingWallets = list;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Checks the OTP with the server (does not consume the code). Call before showing sensitive fields.
  Future<bool> verifyMfaOtp(String otpCode) async {
    _error = null;
    notifyListeners();
    final token = _tokenService.getAccessToken() ?? '';
    final res = await _authRepo.validate2faOtp(
      token: token,
      otpCode: otpCode.trim(),
    );
    return res.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
        return false;
      },
      (_) => true,
    );
  }

  /// Sends the MFA OTP to the user's email before importing a main wallet
  Future<bool> sendMfaOtp() async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      // Since send2faOtp might need a token, we might not need to pass it explicitly 
      // if Dio interceptor adds it natively, but let's assume authRepo handles it.
      // Actually authRepo in other places might just use remoteDataSource
      final token = _tokenService.getAccessToken() ?? '';
      final res = await _authRepo.send2faOtp(token);
      return res.fold(
        (failure) {
          _error = failure.message;
          return false;
        },
        (_) => true,
      );
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> importMainWallet({
    required String label,
    required String privateKey,
    required String mfaCode,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _dataSource.importMainWallet(
        chain: _currentChain,
        label: label,
        privateKey: privateKey,
        mfaCode: mfaCode,
      );
      // Wait to reload pending since it's created as pending
      await loadPendingWallets();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> approveWallet(String id) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _dataSource.approveMainWallet(id);
      await Future.wait([loadPendingWallets(), loadMainWallets()]);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> rejectWallet(String id) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _dataSource.rejectMainWallet(id);
      await loadPendingWallets();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> setDefaultWallet(String id) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _dataSource.setDefaultMainWallet(id);
      await loadMainWallets();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

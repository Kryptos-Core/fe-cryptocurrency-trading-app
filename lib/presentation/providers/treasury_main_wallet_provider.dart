import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/enums/user_role.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/core/utils/treasury_main_wallets_ui_policy.dart';
import 'package:crypto_trading_app/presentation/constants/treasury_chains.dart';
import 'package:crypto_trading_app/data/datasources/treasury_remote_datasource.dart';
import 'package:crypto_trading_app/data/models/treasury_model.dart';
import 'package:crypto_trading_app/data/repositories/auth_repository_impl.dart';
import 'package:crypto_trading_app/presentation/providers/onchain_chain_picker_provider.dart';

class TreasuryMainWalletProvider extends ChangeNotifier {
  final TreasuryRemoteDataSource _dataSource;
  final AuthRepository _authRepo;
  final TokenService _tokenService;
  final OnchainChainPickerProvider? _chainPicker;
  final UserRole Function() _roleResolver;

  TreasuryMainWalletProvider({
    required TreasuryRemoteDataSource dataSource,
    required AuthRepository authRepo,
    required TokenService tokenService,
    OnchainChainPickerProvider? chainPicker,
    required UserRole Function() roleResolver,
  })  : _dataSource = dataSource,
        _authRepo = authRepo,
        _tokenService = tokenService,
        _chainPicker = chainPicker,
        _roleResolver = roleResolver;

  bool get _includePendingWallets =>
      treasuryMainWalletsShowsPendingTab(_roleResolver());

  List<String> _allowedMainWalletChains() =>
      _chainPicker?.treasuryMainWalletChains ?? treasuryMainWalletChainsForCurrentEnv();

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

  /// Set when [importMainWallet] fails; e.g. `INVALID_MFA_CODE` from API.
  String? _importFailureCode;
  String? get importFailureCode => _importFailureCode;

  String _currentChain = treasuryDefaultMainWalletChainForCurrentEnv();
  String get currentChain => _currentChain;

  void setChain(String chain) {
    if (!_allowedMainWalletChains().contains(chain)) return;
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
    if (!_includePendingWallets) {
      _pendingWallets = [];
      return;
    }
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

  /// Reloads both active (current chain) and pending lists — use after create / approve / reject / set default / manual refresh.
  Future<void> refreshAllWallets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final main = await _dataSource.listMainWallets(_currentChain);
      _mainWallets = main;
      if (_includePendingWallets) {
        final pending = await _dataSource.listPendingMainWallets();
        _pendingWallets = pending;
      } else {
        _pendingWallets = [];
      }
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
    _importFailureCode = null;
    notifyListeners();

    try {
      await _dataSource.importMainWallet(
        chain: _currentChain,
        label: label,
        privateKey: privateKey,
        mfaCode: mfaCode,
      );
      await refreshAllWallets();
      return true;
    } on ServerException catch (e) {
      _importFailureCode = e.code;
      _error = e.message;
      return false;
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
      await refreshAllWallets();
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
      await refreshAllWallets();
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
      await refreshAllWallets();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Returns decrypted private key after server verifies [mfaCode], or null on failure ([error] set).
  Future<String?> revealMainWalletPrivateKey({
    required String mainWalletId,
    required String mfaCode,
  }) async {
    _isSubmitting = true;
    _error = null;
    _importFailureCode = null;
    notifyListeners();

    try {
      final pk = await _dataSource.revealMainWalletPrivateKey(
        mainWalletId: mainWalletId,
        mfaCode: mfaCode.trim(),
      );
      return pk;
    } on ServerException catch (e) {
      _importFailureCode = e.code;
      _error = e.message;
      return null;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateMainWalletLabel(String mainWalletId, String? label) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _dataSource.updateMainWallet(
        mainWalletId: mainWalletId,
        label: label,
      );
      await refreshAllWallets();
      return true;
    } on ServerException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> requestMainWalletDeletion(String mainWalletId) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _dataSource.requestMainWalletDeletion(mainWalletId);
      await refreshAllWallets();
      return true;
    } on ServerException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> approveMainWalletDeletion(String mainWalletId) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _dataSource.approveMainWalletDeletion(mainWalletId);
      await refreshAllWallets();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> rejectMainWalletDeletion(String mainWalletId) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _dataSource.rejectMainWalletDeletion(mainWalletId);
      await refreshAllWallets();
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

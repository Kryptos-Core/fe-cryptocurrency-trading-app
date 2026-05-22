import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:crypto_trading_app/core/services/secure_storage_service.dart';
import '../../domain/entities/binance_credentials.dart';
import '../../data/datasources/binance_trading_remote_datasource.dart';
import '../../data/repositories/binance_trading_repository_impl.dart';

enum CredentialsStatus { idle, loading, saving, testing, error }

class BinanceCredentialsProvider extends ChangeNotifier {
  final DioClient _dioClient;
  final SecureStorageService _secureStorage;

  List<BinanceCredentials> _credentials = [];
  BinanceCredentials? _activeCredential;
  CredentialsStatus _status = CredentialsStatus.idle;
  String? _error;
  bool? _lastTestResult;
  String? _lastTestError;

  BinanceCredentialsProvider({
    required DioClient dioClient,
    required SecureStorageService secureStorage,
  })  : _dioClient = dioClient,
        _secureStorage = secureStorage;

  List<BinanceCredentials> get credentials => _credentials;
  BinanceCredentials? get activeCredential => _activeCredential;
  CredentialsStatus get status => _status;
  String? get error => _error;
  bool? get lastTestResult => _lastTestResult;
  String? get lastTestError => _lastTestError;
  bool get isLoading => _status == CredentialsStatus.loading;
  bool get isSaving => _status == CredentialsStatus.saving;
  bool get isTesting => _status == CredentialsStatus.testing;

  BinanceTradingRemoteDataSource get _dataSource =>
      BinanceTradingRemoteDataSource(dioClient: _dioClient);

  BinanceTradingRepositoryImpl get _repo =>
      BinanceTradingRepositoryImpl(remoteDataSource: _dataSource);

  Future<void> loadCredentials() async {
    _status = CredentialsStatus.loading;
    _error = null;
    notifyListeners();

    final result = await _repo.listCredentials();
    result.fold(
      (failure) {
        _status = CredentialsStatus.error;
        _error = failure.message;
      },
      (list) {
        _credentials = list.where((c) => c.isActive).toList();
        _status = CredentialsStatus.idle;
        _error = null;
      },
    );
    notifyListeners();
  }

  Future<({bool success, String? credentialId, String? error})> saveCredentials({
    required String apiKey,
    required String apiSecret,
    required String label,
    required List<String> permissions,
    required bool testnet,
  }) async {
    _status = CredentialsStatus.saving;
    _error = null;
    notifyListeners();

    final result = await _repo.saveCredentials(
      apiKey: apiKey,
      apiSecret: apiSecret,
      label: label,
      permissions: permissions,
      testnet: testnet,
    );

    return result.fold(
      (failure) {
        _status = CredentialsStatus.error;
        _error = failure.message;
        notifyListeners();
        return (success: false, credentialId: null, error: _error);
      },
      (saved) async {
        await _secureStorage.saveBinanceCredentials(
          credentialId: saved.id,
          apiKey: apiKey,
          apiSecret: apiSecret,
        );
        await loadCredentials();
        return (success: true, credentialId: saved.id, error: null);
      },
    );
  }

  Future<({bool success, String? error})> testConnection(String credentialId) async {
    _status = CredentialsStatus.testing;
    _lastTestResult = null;
    _lastTestError = null;
    notifyListeners();

    final result = await _repo.testConnection(credentialId);
    return result.fold(
      (failure) {
        _status = CredentialsStatus.idle;
        _lastTestResult = false;
        _lastTestError = failure.message;
        _error = _lastTestError;
        notifyListeners();
        return (success: false, error: _lastTestError);
      },
      (testResult) {
        _status = CredentialsStatus.idle;
        _lastTestResult = testResult.success;
        _lastTestError = testResult.error;
        if (!testResult.success) {
          _error = testResult.error;
        }
        notifyListeners();
        return (success: testResult.success, error: testResult.error);
      },
    );
  }

  Future<void> deleteCredential(String credentialId) async {
    _status = CredentialsStatus.loading;
    notifyListeners();

    final result = await _repo.deleteCredential(credentialId);
    result.fold(
      (failure) {
        _status = CredentialsStatus.error;
        _error = failure.message;
      },
      (_) async {
        await _secureStorage.deleteBinanceCredentials(credentialId);
        await loadCredentials();
        if (_activeCredential?.id == credentialId) {
          _activeCredential = null;
        }
        return;
      },
    );
    notifyListeners();
  }

  void setActiveCredential(BinanceCredentials? credential) {
    _activeCredential = credential;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String? validateApiKey(String? value) {
    if (value == null || value.isEmpty) return 'API Key is required';
    if (value.length != 64) return 'API Key must be 64 alphanumeric characters';
    if (!RegExp(r'^[A-Za-z0-9]{64}$').hasMatch(value)) {
      return 'API Key must contain only letters and numbers';
    }
    return null;
  }

  String? validateApiSecret(String? value) {
    if (value == null || value.isEmpty) return 'API Secret is required';
    if (value.length != 64) return 'API Secret must be 64 alphanumeric characters';
    if (!RegExp(r'^[A-Za-z0-9]{64}$').hasMatch(value)) {
      return 'API Secret must contain only letters and numbers';
    }
    return null;
  }
}

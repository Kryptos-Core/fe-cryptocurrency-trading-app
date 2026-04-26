import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/utils/stale_query_policy.dart';
import 'package:crypto_trading_app/features/admin/payment_config/data/datasources/treasury_e2e_config_remote_datasource.dart';
import 'package:crypto_trading_app/features/admin/payment_config/data/models/treasury_e2e_config_model.dart';

class TreasuryE2EConfigProvider extends ChangeNotifier {
  TreasuryE2EConfigProvider({required TreasuryE2EConfigRemoteDataSource dataSource})
      : _dataSource = dataSource;

  final TreasuryE2EConfigRemoteDataSource _dataSource;

  List<TreasuryE2EConfigModel> _configs = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  DateTime? _fetchedAt;
  Map<String, dynamic>? _formOptions;
  Map<String, dynamic>? _lastValidation;
  Map<String, dynamic>? _lastConnectionTest;

  List<TreasuryE2EConfigModel> get configs => _configs;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  Map<String, dynamic>? get formOptions => _formOptions;
  Map<String, dynamic>? get lastValidation => _lastValidation;
  Map<String, dynamic>? get lastConnectionTest => _lastConnectionTest;

  Future<void> loadConfigs({bool force = false}) async {
    if (!force && isStaleQueryFresh(_fetchedAt) && _error == null) {
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _configs = await _dataSource.listConfigs();
      _fetchedAt = DateTime.now();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> loadFormOptions({String? environment, String? chain, String? traderUserId, String? traderSearch, bool force = false}) async {
    if (_formOptions != null && !force) return;
    try {
      _formOptions = await _dataSource.getFormOptions(environment: environment, chain: chain, traderUserId: traderUserId, traderSearch: traderSearch);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> validateDraft(Map<String, dynamic> payload) async {
    _error = null;
    _lastValidation = null;
    notifyListeners();
    try {
      _lastValidation = await _dataSource.validateDraft(payload);
      notifyListeners();
      return _lastValidation;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }


  Future<Map<String, dynamic>?> testConnection(Map<String, dynamic> payload) async {
    _error = null;
    _lastConnectionTest = null;
    notifyListeners();
    try {
      _lastConnectionTest = await _dataSource.testConnection(payload);
      notifyListeners();
      return _lastConnectionTest;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<TreasuryE2EConfigModel?> fetchDetail(String id) async {
    _error = null;
    try {
      return await _dataSource.getConfigDetail(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> createConfig(Map<String, dynamic> payload) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      final created = await _dataSource.createConfig(payload);
      _configs = [created, ..._configs];
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateConfig(String id, Map<String, dynamic> payload) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      final updated = await _dataSource.updateConfig(id, payload);
      _configs = _configs.map((c) => c.configId == id ? updated : c).toList();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> activateConfig(String id) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      final updated = await _dataSource.activateConfig(id);
      _configs = _configs.map((c) {
        if (c.environment == updated.environment) {
          return c.configId == updated.configId
              ? updated
              : TreasuryE2EConfigModel(
                  configId: c.configId,
                  environment: c.environment,
                  displayName: c.displayName,
                  apiBaseUrl: c.apiBaseUrl,
                  chain: c.chain,
                  linkedWalletId: c.linkedWalletId,
                  withdrawAmountAuto: c.withdrawAmountAuto,
                  withdrawAmountManual: c.withdrawAmountManual,
                  depositTxHash: c.depositTxHash,
                  depositAmount: c.depositAmount,
                  allowSkip: c.allowSkip,
                  healthFailOnCritical: c.healthFailOnCritical,
                  staleManualMinutes: c.staleManualMinutes,
                  staleConfirmingMinutes: c.staleConfirmingMinutes,
                  failedWithdrawals24h: c.failedWithdrawals24h,
                  reconcilePairLimit: c.reconcilePairLimit,
                  reconciliationThreshold: c.reconciliationThreshold,
                  configVersion: c.configVersion,
                  status: 'INACTIVE',
                  createdBy: c.createdBy,
                  updatedBy: c.updatedBy,
                  createdAt: c.createdAt,
                  updatedAt: c.updatedAt,
                  activatedAt: c.activatedAt,
                  archivedAt: c.archivedAt,
                  hasTraderBearerToken: c.hasTraderBearerToken,
                  hasRiskBearerToken: c.hasRiskBearerToken,
                  traderBearerTokenMasked: c.traderBearerTokenMasked,
                  riskBearerTokenMasked: c.riskBearerTokenMasked,
                );
        }
        return c;
      }).toList();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deactivateConfig(String id) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      final updated = await _dataSource.deactivateConfig(id);
      _configs = _configs.map((c) => c.configId == id ? updated : c).toList();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> archiveConfig(String id) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      await _dataSource.archiveConfig(id);
      _configs = _configs.map((c) {
        if (c.configId != id) return c;
        return TreasuryE2EConfigModel(
          configId: c.configId,
          environment: c.environment,
          displayName: c.displayName,
          apiBaseUrl: c.apiBaseUrl,
          chain: c.chain,
          linkedWalletId: c.linkedWalletId,
          withdrawAmountAuto: c.withdrawAmountAuto,
          withdrawAmountManual: c.withdrawAmountManual,
          depositTxHash: c.depositTxHash,
          depositAmount: c.depositAmount,
          allowSkip: c.allowSkip,
          healthFailOnCritical: c.healthFailOnCritical,
          staleManualMinutes: c.staleManualMinutes,
          staleConfirmingMinutes: c.staleConfirmingMinutes,
          failedWithdrawals24h: c.failedWithdrawals24h,
          reconcilePairLimit: c.reconcilePairLimit,
          reconciliationThreshold: c.reconciliationThreshold,
          configVersion: c.configVersion,
          status: 'ARCHIVED',
          createdBy: c.createdBy,
          updatedBy: c.updatedBy,
          createdAt: c.createdAt,
          updatedAt: c.updatedAt,
          activatedAt: c.activatedAt,
          archivedAt: c.archivedAt,
          hasTraderBearerToken: c.hasTraderBearerToken,
          hasRiskBearerToken: c.hasRiskBearerToken,
          traderBearerTokenMasked: c.traderBearerTokenMasked,
          riskBearerTokenMasked: c.riskBearerTokenMasked,
        );
      }).toList();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}

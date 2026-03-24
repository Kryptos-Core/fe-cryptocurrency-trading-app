import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/data/datasources/fiat_withdrawals_remote_datasource.dart';

class FiatWithdrawalsProvider extends ChangeNotifier {
  FiatWithdrawalsProvider({required this.dataSource});

  final FiatWithdrawalsRemoteDataSource dataSource;

  bool isLoading = false;
  String? errorMessage;

  List<Map<String, dynamic>> banks = [];
  List<Map<String, dynamic>> myBankAccounts = [];
  List<Map<String, dynamic>> myRequests = [];

  void _setErr(String? e) {
    errorMessage = e;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  Future<void> loadBanks() async {
    try {
      banks = await dataSource.getBanks();
      notifyListeners();
    } catch (e) {
      _setErr(e.toString());
    }
  }

  Future<void> refreshMyData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      myBankAccounts = await dataSource.getMyBankAccounts();
      myRequests = await dataSource.getMyRequests(limit: 50);
      clearError();
    } catch (e) {
      _setErr(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitBank({
    required String bankCode,
    required String accountNumber,
    required String accountHolderName,
  }) async {
    try {
      errorMessage = null;
      await dataSource.createBankAccount(
        bankCode: bankCode,
        accountNumber: accountNumber,
        accountHolderName: accountHolderName,
      );
      await refreshMyData();
      return true;
    } catch (e) {
      _setErr(e.toString());
      return false;
    }
  }

  Future<String?> resolveAccountHolderName({
    required String bankCode,
    required String accountNumber,
  }) async {
    try {
      final data = await dataSource.resolveBankAccountHolder(
        bankCode: bankCode,
        accountNumber: accountNumber,
      );
      final name = data['accountHolderName']?.toString().trim();
      if (name == null || name.isEmpty) return null;
      return name;
    } catch (_) {
      return null;
    }
  }

  Future<bool> submitWithdrawal({
    required String bankAccountId,
    required String amount,
    required String idempotencyKey,
  }) async {
    try {
      errorMessage = null;
      await dataSource.createWithdrawalRequest(
        bankAccountId: bankAccountId,
        amount: amount,
        idempotencyKey: idempotencyKey,
      );
      await refreshMyData();
      return true;
    } catch (e) {
      _setErr(e.toString());
      return false;
    }
  }

  // —— Admin ——
  List<Map<String, dynamic>> adminBanks = [];
  List<Map<String, dynamic>> adminRequests = [];
  int adminBankTotal = 0;
  int adminRequestTotal = 0;
  bool adminLoading = false;

  Future<void> loadAdminBanks({String? status, int page = 1}) async {
    adminLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final m = await dataSource.adminListBankAccounts(status: status, page: page, limit: 50);
      final list = m['data'];
      adminBanks = list is List ? list.whereType<Map<String, dynamic>>().toList() : [];
      adminBankTotal = (m['total'] is int) ? m['total'] as int : int.tryParse('${m['total']}') ?? 0;
      _setErr(null);
    } catch (e) {
      _setErr(e.toString());
    } finally {
      adminLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAdminRequests({String? status, int page = 1}) async {
    adminLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final m = await dataSource.adminListRequests(status: status, page: page, limit: 50);
      final list = m['data'];
      adminRequests = list is List ? list.whereType<Map<String, dynamic>>().toList() : [];
      adminRequestTotal =
          (m['total'] is int) ? m['total'] as int : int.tryParse('${m['total']}') ?? 0;
      _setErr(null);
    } catch (e) {
      _setErr(e.toString());
    } finally {
      adminLoading = false;
      notifyListeners();
    }
  }

  Future<bool> adminVerifyBank(String id) async {
    try {
      await dataSource.adminVerifyBankAccount(id);
      await loadAdminBanks(status: 'PENDING');
      return true;
    } catch (e) {
      _setErr(e.toString());
      return false;
    }
  }

  Future<bool> adminRejectBank(String id, {String? reason}) async {
    try {
      await dataSource.adminRejectBankAccount(id, reason: reason);
      await loadAdminBanks(status: 'PENDING');
      return true;
    } catch (e) {
      _setErr(e.toString());
      return false;
    }
  }

  Future<bool> adminCompleteWithdrawal(String id, String transferRef) async {
    try {
      await dataSource.adminCompleteRequest(id, transferReference: transferRef);
      await loadAdminRequests(status: 'PENDING_REVIEW');
      return true;
    } catch (e) {
      _setErr(e.toString());
      return false;
    }
  }

  Future<bool> adminRejectWithdrawal(String id, {String? reason}) async {
    try {
      await dataSource.adminRejectRequest(id, reason: reason);
      await loadAdminRequests(status: 'PENDING_REVIEW');
      return true;
    } catch (e) {
      _setErr(e.toString());
      return false;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/domain/entities/deposit.dart';
import 'package:crypto_trading_app/domain/repositories/deposit_repository.dart';

class DepositCheckoutSession {
  final String checkoutUrl;
  final int? orderCode;
  final String? depositId;

  const DepositCheckoutSession({
    required this.checkoutUrl,
    this.orderCode,
    this.depositId,
  });
}

class DepositsProvider extends ChangeNotifier {
  final DepositRepository repository;

  DepositsProvider({required this.repository});

  List<Deposit> _deposits = [];
  bool _isLoading = false;
  String? _error;
  bool _isCreatingLink = false;

  List<Deposit> get deposits => _deposits;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isCreatingLink => _isCreatingLink;

  Future<void> fetchMyDeposits() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _deposits = await repository.getMyDeposits();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DepositCheckoutSession?> createDepositLink(int amount) async {
    try {
      _isCreatingLink = true;
      _error = null;
      notifyListeners();

      final result = await repository.createDepositLink(amount);
      if (result.containsKey('checkoutUrl') &&
          result['checkoutUrl'] != null &&
          (result['checkoutUrl'] as String).isNotEmpty) {
        final rawOrderCode = result['orderCode'];
        final orderCode = rawOrderCode is int
            ? rawOrderCode
            : int.tryParse(rawOrderCode?.toString() ?? '');

        return DepositCheckoutSession(
          checkoutUrl: result['checkoutUrl'] as String,
          orderCode: orderCode,
          depositId: result['depositId']?.toString(),
        );
      }
      return null;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isCreatingLink = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> syncDepositStatus(int orderCode) async {
    try {
      _error = null;
      return await repository.syncDepositStatus(orderCode);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {'updated': false};
    }
  }
}

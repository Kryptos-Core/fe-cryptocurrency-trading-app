import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/domain/entities/deposit.dart';
import 'package:crypto_trading_app/domain/repositories/deposit_repository.dart';

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

  Future<String?> createDepositLink(double amount) async {
    try {
      _isCreatingLink = true;
      _error = null;
      notifyListeners();

      final result = await repository.createDepositLink(amount);
      if (result.containsKey('checkoutUrl')) {
        return result['checkoutUrl'] as String;
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
}

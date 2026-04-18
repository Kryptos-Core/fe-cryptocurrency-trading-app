import 'package:crypto_trading_app/features/deposits/domain/entities/deposit.dart';

abstract class DepositRepository {
  Future<List<Deposit>> getMyDeposits();
  Future<Map<String, dynamic>> getCheckoutMeta();
  Future<Map<String, dynamic>> createDepositLink(int amount);
  Future<Map<String, dynamic>> syncDepositStatus(int orderCode);
}

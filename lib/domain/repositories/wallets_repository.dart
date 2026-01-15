import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/wallet.dart';

/// Wallets Repository Interface
/// Following Dependency Inversion Principle (DIP)
abstract class WalletsRepository {
  /// Get user wallets with optional filters
  Future<Either<Failure, List<Wallet>>> getWallets({
    int? currencyId,
    bool includeZero = false,
  });

  /// Get wallet by currency ID
  Future<Either<Failure, Wallet>> getWalletByCurrency(int currencyId);

  /// Get wallet balance by wallet ID
  Future<Either<Failure, Wallet>> getWalletBalance(int walletId);

  /// Get wallet ledger (transaction history)
  Future<Either<Failure, List<WalletLedger>>> getWalletLedger({
    required int walletId,
    String? refType,
    String? direction,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 10,
  });
}

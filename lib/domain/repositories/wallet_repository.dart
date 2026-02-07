import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/wallet_balance.dart';
import 'package:crypto_trading_app/domain/entities/wallet_transaction.dart';

/// Repository interface for wallet operations
///
/// This interface defines the contract for all wallet-related operations.
/// Implementation is provided by data layer repositories.
///
/// Following clean architecture principles:
/// - Domain layer defines the interface
/// - Data layer provides the implementation
/// - Presentation layer uses the interface through dependency injection
abstract class WalletRepository {
  /// Get wallet balance for a specific currency
  ///
  /// Parameters:
  ///   - currencyId: The currency ID (1=BTC, 2=ETH, etc.)
  ///
  /// Returns:
  ///   - Either<Failure, WalletBalance>
  ///     - Right: WalletBalance if successful
  ///     - Left: Failure if operation fails (network, auth, validation)
  ///
  /// Example:
  /// ```dart
  /// final result = await walletRepository.getBalance(1); // BTC
  /// result.fold(
  ///   (failure) => print('Failed to fetch balance: $failure'),
  ///   (balance) => print('Available: ${balance.available}'),
  /// );
  /// ```
  Future<Either<Failure, WalletBalance>> getBalance(int currencyId);

  /// Get transaction history (ledger) for a currency
  ///
  /// Returns list of WalletTransactionResponse built from ledger entries.
  Future<Either<Failure, List<WalletTransactionResponse>>> getTransactionHistory(
    int currencyId,
  );

  /// Execute a wallet transaction (CREDIT, DEBIT, FREEZE, UNFREEZE, TRANSFER)
  ///
  /// Parameters:
  ///   - request: WalletTransactionRequest containing:
  ///     - currencyId: Currency to operate on
  ///     - amount: Amount in decimal string (max 18 decimals)
  ///     - action: CREDIT, DEBIT, FREEZE, UNFREEZE, or TRANSFER
  ///     - refType: Reference type (DEPOSIT, WITHDRAW, ORDER, TRADE, ADJUST, TRANSFER)
  ///     - refId: Reference ID (deposit ID, order ID, etc.)
  ///     - targetUserId: Required only for TRANSFER action
  ///
  /// Returns:
  ///   - Either<Failure, WalletTransactionResponse>
  ///     - Right: Transaction response with new balance if successful
  ///     - Left: Failure if operation fails
  ///
  /// Example - Deposit (CREDIT):
  /// ```dart
  /// final request = WalletTransactionRequest(
  ///   currencyId: 1,
  ///   amount: '10.5',
  ///   action: WalletTransactionAction.credit,
  ///   refType: WalletReferenceType.deposit,
  ///   refId: 123, // Deposit ID
  /// );
  /// final result = await walletRepository.executeTransaction(request);
  /// ```
  ///
  /// Example - Freeze (for placing order):
  /// ```dart
  /// final request = WalletTransactionRequest(
  ///   currencyId: 2, // USDT
  ///   amount: '500000',
  ///   action: WalletTransactionAction.freeze,
  ///   refType: WalletReferenceType.order,
  ///   refId: 789, // Order ID
  /// );
  /// final result = await walletRepository.executeTransaction(request);
  /// ```
  ///
  /// Example - Transfer:
  /// ```dart
  /// final request = WalletTransactionRequest(
  ///   currencyId: 1,
  ///   amount: '5.5',
  ///   action: WalletTransactionAction.transfer,
  ///   refType: WalletReferenceType.transfer,
  ///   refId: 456,
  ///   targetUserId: 2, // User ID of recipient
  /// );
  /// final result = await walletRepository.executeTransaction(request);
  /// ```
  Future<Either<Failure, WalletTransactionResponse>> executeTransaction(
    WalletTransactionRequest request,
  );

  /// Cache balance in local storage for offline access
  ///
  /// Parameters:
  ///   - balance: WalletBalance to cache
  ///   - currencyId: Currency ID for the cached balance
  Future<void> cacheBalance(WalletBalance balance, int currencyId);

  /// Retrieve cached balance from local storage
  ///
  /// Parameters:
  ///   - currencyId: Currency ID to retrieve cache for
  ///
  /// Returns:
  ///   - WalletBalance if found in cache, null otherwise
  Future<WalletBalance?> getCachedBalance(int currencyId);

  /// Clear cached balance
  ///
  /// Parameters:
  ///   - currencyId: Currency ID to clear cache for
  Future<void> clearCachedBalance(int currencyId);

  /// Clear all cached balances
  Future<void> clearAllCachedBalances();
}

import 'package:dartz/dartz.dart' hide Order;
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/order.dart';
import 'package:crypto_trading_app/domain/repositories/orders_repository.dart';
import 'package:crypto_trading_app/domain/repositories/markets_repository.dart';
import 'package:crypto_trading_app/domain/repositories/wallet_repository.dart';

/// Facade Pattern
///
/// Simplified entry for trading flows (Markets, Orders, Wallet).
/// Callers use [placeMarketOrder] without wiring repositories themselves.
class TradingFacade {
  final OrdersRepository _ordersRepository;
  final MarketsRepository _marketsRepository;
  final WalletRepository _walletRepository; // ignore: unused_field — reserved for balance checks

  TradingFacade(
    this._ordersRepository,
    this._marketsRepository,
    this._walletRepository,
  );

  /// Places a market order after validating simple conditions.
  /// Returns Either<Failure, Order> to be consistent with underlying repositories.
  Future<Either<Failure, Order>> placeMarketOrder({
    required String marketId,
    required String side, // 'buy' or 'sell'
    required double amount,
  }) async {
    // 1. Get market details to ensure it exists
    // We use getMarkets filter as a simple check
    final marketsResult = await _marketsRepository.getMarkets(search: marketId, limit: 1);
    
    return marketsResult.fold(
      (failure) => Left(failure), // Forward failure
      (markets) async {
         if (markets.markets.isEmpty) {
             return const Left(ServerFailure(message: 'Market not found'));
         }
         
         // 2. (Optional) We could check wallet balance here using _walletRepository
         // but for this Facade example we assume balance is sufficient or backend handles it.

         // 3. Place the order
         final request = CreateOrderRequest(
             pairId: marketId,
             side: side.toUpperCase(),
             type: 'MARKET',
             amount: amount.toString(),
             // Generate a simple idempotency key
             idempotencyKey: DateTime.now().millisecondsSinceEpoch.toString(),
         );
         
         return _ordersRepository.createOrder(request);
      }
    );
  }
}

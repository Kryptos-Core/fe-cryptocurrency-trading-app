import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import '../entities/binance_credentials.dart';
import '../entities/binance_trading_entities.dart';

abstract class BinanceTradingRepository {
  Future<Either<Failure, ({String id, String accountId, String accountType})>> saveCredentials({
    required String apiKey,
    required String apiSecret,
    String? label,
    List<String>? permissions,
    bool? testnet,
  });

  Future<Either<Failure, List<BinanceCredentials>>> listCredentials();

  Future<Either<Failure, void>> deleteCredential(String credentialId);

  Future<Either<Failure, ({bool success, String? accountId, String? accountType, String? error})>> testConnection(
    String credentialId,
  );

  Future<Either<Failure, List<BinanceSpotBalance>>> getSpotBalances(String credentialId);

  Future<Either<Failure, BinanceSpotOrderResult>> placeSpotOrder({
    required String credentialId,
    required String symbol,
    required String side,
    required String type,
    required String quantity,
    String? price,
    String? timeInForce,
    String? stopPrice,
  });

  Future<Either<Failure, void>> cancelSpotOrder({
    required String credentialId,
    required String symbol,
    required String orderId,
  });

  Future<Either<Failure, List<BinanceSpotOrder>>> getOpenOrders(String credentialId, {String? symbol});

  Future<Either<Failure, List<BinanceSpotOrder>>> getOrderHistory(String credentialId, {String? symbol, int? limit});

  Future<Either<Failure, List<BinanceFuturesBalance>>> getFuturesBalances(String credentialId);

  Future<Either<Failure, List<BinanceFuturesPosition>>> getFuturesPositions(String credentialId);
}

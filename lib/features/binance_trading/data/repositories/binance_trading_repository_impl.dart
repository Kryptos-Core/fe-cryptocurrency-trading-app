import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import '../../domain/entities/binance_credentials.dart';
import '../../domain/entities/binance_trading_entities.dart';
import '../../domain/repositories/binance_trading_repository.dart';
import '../datasources/binance_trading_remote_datasource.dart';

class BinanceTradingRepositoryImpl implements BinanceTradingRepository {
  final BinanceTradingRemoteDataSource _remoteDataSource;

  BinanceTradingRepositoryImpl({required BinanceTradingRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, ({String id, String accountId, String accountType})>> saveCredentials({
    required String apiKey,
    required String apiSecret,
    String? label,
    List<String>? permissions,
    bool? testnet,
  }) async {
    try {
      final result = await _remoteDataSource.saveCredentials(
        apiKey: apiKey,
        apiSecret: apiSecret,
        label: label,
        permissions: permissions,
        testnet: testnet,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BinanceCredentials>>> listCredentials() async {
    try {
      final result = await _remoteDataSource.listCredentials();
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCredential(String credentialId) async {
    try {
      await _remoteDataSource.deleteCredential(credentialId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ({bool success, String? accountId, String? accountType, String? error})>> testConnection(
    String credentialId,
  ) async {
    try {
      final result = await _remoteDataSource.testConnection(credentialId);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BinanceSpotBalance>>> getSpotBalances(String credentialId) async {
    try {
      final result = await _remoteDataSource.getSpotBalances(credentialId);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BinanceSpotOrderResult>> placeSpotOrder({
    required String credentialId,
    required String symbol,
    required String side,
    required String type,
    required String quantity,
    String? price,
    String? timeInForce,
    String? stopPrice,
  }) async {
    try {
      final result = await _remoteDataSource.placeSpotOrder(
        credentialId: credentialId,
        symbol: symbol,
        side: side,
        type: type,
        quantity: quantity,
        price: price,
        timeInForce: timeInForce,
        stopPrice: stopPrice,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelSpotOrder({
    required String credentialId,
    required String symbol,
    required String orderId,
  }) async {
    try {
      await _remoteDataSource.cancelSpotOrder(
        credentialId: credentialId,
        symbol: symbol,
        orderId: orderId,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BinanceSpotOrder>>> getOpenOrders(String credentialId, {String? symbol}) async {
    try {
      final result = await _remoteDataSource.getOpenOrders(credentialId, symbol: symbol);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BinanceSpotOrder>>> getOrderHistory(String credentialId, {String? symbol, int? limit}) async {
    try {
      final result = await _remoteDataSource.getOrderHistory(credentialId, symbol: symbol, limit: limit);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BinanceFuturesBalance>>> getFuturesBalances(String credentialId) async {
    try {
      final result = await _remoteDataSource.getFuturesBalances(credentialId);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BinanceFuturesPosition>>> getFuturesPositions(String credentialId) async {
    try {
      final result = await _remoteDataSource.getFuturesPositions(credentialId);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Failure _mapDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
    if (statusCode == 401) {
      return const AuthenticationFailure(message: 'Unauthorized — please login again', code: 'UNAUTHORIZED');
    }
    if (statusCode == 403) {
      return const AuthorizationFailure(message: 'Access denied', code: 'FORBIDDEN');
    }
    if (statusCode == 404) {
      return const NotFoundFailure(message: 'Resource not found', code: 'NOT_FOUND');
    }
    if (statusCode == 422 || statusCode == 400) {
      return ValidationFailure(message: message.toString(), code: 'VALIDATION_ERROR');
    }
    return ServerFailure(message: message.toString(), code: 'SERVER_ERROR');
  }
}

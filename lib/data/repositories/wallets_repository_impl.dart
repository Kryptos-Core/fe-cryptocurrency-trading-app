import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/data/datasources/wallets_remote_datasource.dart';
import 'package:crypto_trading_app/domain/entities/wallet.dart';
import 'package:crypto_trading_app/domain/repositories/wallets_repository.dart';

/// Wallets Repository Implementation
class WalletsRepositoryImpl implements WalletsRepository {
  final WalletsRemoteDataSource remoteDataSource;

  WalletsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Wallet>>> getWallets({
    int? currencyId,
    bool includeZero = false,
  }) async {
    try {
      final walletModels = await remoteDataSource.getWallets(
        currencyId: currencyId,
        includeZero: includeZero,
      );
      
      final wallets = walletModels.map((model) => model.toEntity()).toList();
      return Right(wallets);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Wallet>> getWalletByCurrency(int currencyId) async {
    try {
      final walletModel = await remoteDataSource.getWalletByCurrency(currencyId);
      return Right(walletModel.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Wallet>> getWalletBalance(int walletId) async {
    try {
      final walletModel = await remoteDataSource.getWalletBalance(walletId);
      return Right(walletModel.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WalletLedger>>> getWalletLedger({
    required int walletId,
    String? refType,
    String? direction,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final ledgerModels = await remoteDataSource.getWalletLedger(
        walletId: walletId,
        refType: refType,
        direction: direction,
        startDate: startDate,
        endDate: endDate,
        page: page,
        limit: limit,
      );
      
      final ledger = ledgerModels.map((model) => model.toEntity()).toList();
      return Right(ledger);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

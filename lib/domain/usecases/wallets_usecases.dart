import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/core/usecases/usecase.dart';
import 'package:crypto_trading_app/domain/entities/wallet.dart';
import 'package:crypto_trading_app/domain/repositories/wallets_repository.dart';
import 'package:equatable/equatable.dart';

/// Get User Wallets Use Case
class GetWalletsUseCase implements UseCase<List<Wallet>, GetWalletsParams> {
  final WalletsRepository repository;

  GetWalletsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<Wallet>>> call(GetWalletsParams params) async {
    return await repository.getWallets(
      currencyId: params.currencyId,
      includeZero: params.includeZero,
    );
  }
}

class GetWalletsParams extends Equatable {
  final int? currencyId;
  final bool includeZero;

  const GetWalletsParams({
    this.currencyId,
    this.includeZero = false,
  });

  @override
  List<Object?> get props => [currencyId, includeZero];
}

/// Get Wallet By Currency Use Case
class GetWalletByCurrencyUseCase implements UseCase<Wallet, int> {
  final WalletsRepository repository;

  GetWalletByCurrencyUseCase({required this.repository});

  @override
  Future<Either<Failure, Wallet>> call(int currencyId) async {
    return await repository.getWalletByCurrency(currencyId);
  }
}

/// Get Wallet Balance Use Case
class GetWalletBalanceUseCase implements UseCase<Wallet, int> {
  final WalletsRepository repository;

  GetWalletBalanceUseCase({required this.repository});

  @override
  Future<Either<Failure, Wallet>> call(int walletId) async {
    return await repository.getWalletBalance(walletId);
  }
}

/// Get Wallet Ledger Use Case
class GetWalletLedgerUseCase implements UseCase<List<WalletLedger>, GetWalletLedgerParams> {
  final WalletsRepository repository;

  GetWalletLedgerUseCase({required this.repository});

  @override
  Future<Either<Failure, List<WalletLedger>>> call(GetWalletLedgerParams params) async {
    return await repository.getWalletLedger(
      walletId: params.walletId,
      refType: params.refType,
      direction: params.direction,
      startDate: params.startDate,
      endDate: params.endDate,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetWalletLedgerParams extends Equatable {
  final int walletId;
  final String? refType;
  final String? direction;
  final String? startDate;
  final String? endDate;
  final int page;
  final int limit;

  const GetWalletLedgerParams({
    required this.walletId,
    this.refType,
    this.direction,
    this.startDate,
    this.endDate,
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [walletId, refType, direction, startDate, endDate, page, limit];
}

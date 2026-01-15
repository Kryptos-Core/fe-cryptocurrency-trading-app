import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/core/usecases/usecase.dart';
import 'package:crypto_trading_app/domain/entities/currency.dart';
import 'package:crypto_trading_app/domain/repositories/currencies_repository.dart';
import 'package:equatable/equatable.dart';

/// Get All Currencies Use Case
class GetCurrenciesUseCase implements UseCase<List<Currency>, GetCurrenciesParams> {
  final CurrenciesRepository repository;

  GetCurrenciesUseCase({required this.repository});

  @override
  Future<Either<Failure, List<Currency>>> call(GetCurrenciesParams params) async {
    return await repository.getCurrencies(
      isActive: params.isActive,
      isTradable: params.isTradable,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetCurrenciesParams extends Equatable {
  final bool? isActive;
  final bool? isTradable;
  final int page;
  final int limit;

  const GetCurrenciesParams({
    this.isActive,
    this.isTradable,
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [isActive, isTradable, page, limit];
}

/// Get Currency By ID Use Case
class GetCurrencyByIdUseCase implements UseCase<Currency, int> {
  final CurrenciesRepository repository;

  GetCurrencyByIdUseCase({required this.repository});

  @override
  Future<Either<Failure, Currency>> call(int currencyId) async {
    return await repository.getCurrencyById(currencyId);
  }
}

/// Get Currency By Symbol Use Case
class GetCurrencyBySymbolUseCase implements UseCase<Currency, String> {
  final CurrenciesRepository repository;

  GetCurrencyBySymbolUseCase({required this.repository});

  @override
  Future<Either<Failure, Currency>> call(String symbol) async {
    return await repository.getCurrencyBySymbol(symbol);
  }
}

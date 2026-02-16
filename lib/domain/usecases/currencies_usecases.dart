import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/core/usecases/usecase.dart';
import 'package:crypto_trading_app/domain/entities/currency.dart';
import 'package:crypto_trading_app/domain/repositories/currencies_repository.dart';
import 'package:crypto_trading_app/data/models/create_currency_dto.dart';
import 'package:crypto_trading_app/data/models/update_currency_dto.dart';
import 'package:equatable/equatable.dart';

/// Get All Currencies Use Case
/// Following Single Responsibility Principle (SRP)
class GetCurrenciesUseCase
    implements UseCase<PaginatedCurrenciesResult, GetCurrenciesParams> {
  final CurrenciesRepository repository;

  GetCurrenciesUseCase({required this.repository});

  @override
  Future<Either<Failure, PaginatedCurrenciesResult>> call(
    GetCurrenciesParams params,
  ) async {
    return await repository.getCurrencies(
      page: params.page,
      limit: params.limit,
      includeInactive: params.includeInactive,
    );
  }
}

class GetCurrenciesParams extends Equatable {
  final int page;
  final int limit;
  final bool includeInactive;

  const GetCurrenciesParams({
    this.page = 1,
    this.limit = 10,
    this.includeInactive = false,
  });

  @override
  List<Object?> get props => [page, limit, includeInactive];
}

/// Get Active Currencies Use Case
/// Following Single Responsibility Principle (SRP)
class GetActiveCurrenciesUseCase
    implements UseCase<List<Currency>, NoParams> {
  final CurrenciesRepository repository;

  GetActiveCurrenciesUseCase({required this.repository});

  @override
  Future<Either<Failure, List<Currency>>> call(NoParams params) async {
    return await repository.getActiveCurrencies();
  }
}

/// Get Tradable Currencies Use Case
/// Following Single Responsibility Principle (SRP)
class GetTradableCurrenciesUseCase
    implements UseCase<List<Currency>, NoParams> {
  final CurrenciesRepository repository;

  GetTradableCurrenciesUseCase({required this.repository});

  @override
  Future<Either<Failure, List<Currency>>> call(NoParams params) async {
    return await repository.getTradableCurrencies();
  }
}

/// Get Currency By ID Use Case
/// Following Single Responsibility Principle (SRP)
class GetCurrencyByIdUseCase implements UseCase<Currency, String> {
  final CurrenciesRepository repository;

  GetCurrencyByIdUseCase({required this.repository});

  @override
  Future<Either<Failure, Currency>> call(String currencyId) async {
    return await repository.getCurrencyById(currencyId);
  }
}

/// Get Currency By Symbol Use Case
/// Following Single Responsibility Principle (SRP)
class GetCurrencyBySymbolUseCase implements UseCase<Currency, String> {
  final CurrenciesRepository repository;

  GetCurrencyBySymbolUseCase({required this.repository});

  @override
  Future<Either<Failure, Currency>> call(String symbol) async {
    return await repository.getCurrencyBySymbol(symbol);
  }
}

/// Create Currency Use Case
/// Following Single Responsibility Principle (SRP)
class CreateCurrencyUseCase
    implements UseCase<Currency, CreateCurrencyParams> {
  final CurrenciesRepository repository;

  CreateCurrencyUseCase({required this.repository});

  @override
  Future<Either<Failure, Currency>> call(CreateCurrencyParams params) async {
    return await repository.createCurrency(params.dto);
  }
}

class CreateCurrencyParams extends Equatable {
  final CreateCurrencyDto dto;

  const CreateCurrencyParams({required this.dto});

  @override
  List<Object?> get props => [dto];
}

/// Update Currency Use Case
/// Following Single Responsibility Principle (SRP)
class UpdateCurrencyUseCase
    implements UseCase<Currency, UpdateCurrencyParams> {
  final CurrenciesRepository repository;

  UpdateCurrencyUseCase({required this.repository});

  @override
  Future<Either<Failure, Currency>> call(UpdateCurrencyParams params) async {
    return await repository.updateCurrency(params.currencyId, params.dto);
  }
}

class UpdateCurrencyParams extends Equatable {
  final String currencyId;
  final UpdateCurrencyDto dto;

  const UpdateCurrencyParams({
    required this.currencyId,
    required this.dto,
  });

  @override
  List<Object?> get props => [currencyId, dto];
}

/// Delete Currency Use Case
/// Following Single Responsibility Principle (SRP)
class DeleteCurrencyUseCase implements UseCase<void, String> {
  final CurrenciesRepository repository;

  DeleteCurrencyUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(String currencyId) async {
    return await repository.deleteCurrency(currencyId);
  }
}

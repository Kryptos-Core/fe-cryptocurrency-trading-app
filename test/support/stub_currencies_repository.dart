import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/data/models/create_currency_dto.dart';
import 'package:crypto_trading_app/data/models/update_currency_dto.dart';
import 'package:crypto_trading_app/domain/entities/currency.dart';
import 'package:crypto_trading_app/domain/repositories/currencies_repository.dart';

/// [CurrenciesRepository] with empty lists — enough for markets list screen init.
class StubCurrenciesRepository implements CurrenciesRepository {
  static const _f = ServerFailure(message: 'stub');

  @override
  Future<Either<Failure, PaginatedCurrenciesResult>> getCurrencies({
    int page = 1,
    int limit = 10,
    bool includeInactive = false,
    String? search,
    bool? isTradable,
    bool? isActive,
  }) async {
    return const Right(
      PaginatedCurrenciesResult(
        currencies: [],
        total: 0,
        page: 1,
        limit: 10,
      ),
    );
  }

  @override
  Future<Either<Failure, List<Currency>>> getActiveCurrencies() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Currency>>> getTradableCurrencies() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Currency>> getCurrencyById(String currencyId) async {
    return const Left(_f);
  }

  @override
  Future<Either<Failure, Currency>> getCurrencyBySymbol(String symbol) async {
    return const Left(_f);
  }

  @override
  Future<Either<Failure, Currency>> createCurrency(CreateCurrencyDto dto) async {
    return const Left(_f);
  }

  @override
  Future<Either<Failure, Currency>> updateCurrency(
    String currencyId,
    UpdateCurrencyDto dto,
  ) async {
    return const Left(_f);
  }

  @override
  Future<Either<Failure, void>> deleteCurrency(String currencyId) async {
    return const Left(_f);
  }
}

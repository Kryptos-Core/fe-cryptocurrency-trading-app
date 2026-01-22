/// Currencies API Usage Examples
/// 
/// This file demonstrates how to use the Currencies API implementation
/// following Clean Architecture, SOLID principles, and Design Patterns.
/// 
/// DO NOT import this file in production code - it's for reference only.

/*
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/domain/usecases/currencies_usecases.dart';
import 'package:crypto_trading_app/data/models/create_currency_dto.dart';
import 'package:crypto_trading_app/data/models/update_currency_dto.dart';
import 'package:crypto_trading_app/core/utils/currency_validator.dart';
import 'package:crypto_trading_app/core/services/currency_cache_service.dart';

/// Example 1: Get Active Currencies (Cached - Fast)
/// Use this for dropdowns, wallet creation, etc.
Future<void> exampleGetActiveCurrencies() async {
  final useCase = sl<GetActiveCurrenciesUseCase>();
  
  final result = await useCase(NoParams());
  
  result.fold(
    (failure) {
      // Handle error
      print('Error: ${failure.message}');
    },
    (currencies) {
      // Use currencies
      for (final currency in currencies) {
        print('${currency.symbol} - ${currency.name}');
      }
    },
  );
}

/// Example 2: Get Tradable Currencies (Cached - Fast)
/// Use this for trading interface, market pairs, etc.
Future<void> exampleGetTradableCurrencies() async {
  final useCase = sl<GetTradableCurrenciesUseCase>();
  
  final result = await useCase(NoParams());
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (currencies) {
      // Filter only tradable currencies
      final tradable = currencies.where((c) => c.isTradable).toList();
      print('Found ${tradable.length} tradable currencies');
    },
  );
}

/// Example 3: Get All Currencies with Pagination
/// Use this for admin panel, currency management
Future<void> exampleGetCurrenciesWithPagination() async {
  final useCase = sl<GetCurrenciesUseCase>();
  
  final params = GetCurrenciesParams(
    page: 1,
    limit: 10,
    includeInactive: false, // Set to true to include inactive currencies
  );
  
  final result = await useCase(params);
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (paginatedResult) {
      print('Total: ${paginatedResult.total}');
      print('Page: ${paginatedResult.page}');
      print('Limit: ${paginatedResult.limit}');
      print('Currencies: ${paginatedResult.currencies.length}');
    },
  );
}

/// Example 4: Get Currency by ID
Future<void> exampleGetCurrencyById() async {
  final useCase = sl<GetCurrencyByIdUseCase>();
  
  final result = await useCase(1); // Currency ID
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (currency) {
      print('Currency: ${currency.symbol}');
      print('Name: ${currency.name}');
      print('Precision: ${currency.precisionScale}');
      print('Min Withdraw: ${currency.minWithdraw}');
    },
  );
}

/// Example 5: Get Currency by Symbol
Future<void> exampleGetCurrencyBySymbol() async {
  final useCase = sl<GetCurrencyBySymbolUseCase>();
  
  final result = await useCase('BTC');
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (currency) {
      print('Found: ${currency.symbol} - ${currency.name}');
    },
  );
}

/// Example 6: Validate Withdrawal Amount
Future<void> exampleValidateWithdrawal() async {
  // First, get currency
  final getCurrencyUseCase = sl<GetCurrencyBySymbolUseCase>();
  final currencyResult = await getCurrencyUseCase('BTC');
  
  currencyResult.fold(
    (failure) => print('Error getting currency: ${failure.message}'),
    (currency) {
      // Validate withdrawal amount
      const withdrawalAmount = '0.0005';
      final validation = CurrencyValidator.validateWithdrawalAmount(
        currency,
        withdrawalAmount,
      );
      
      if (!validation.isValid) {
        print('Validation failed: ${validation.error}');
      } else {
        print('Withdrawal amount is valid');
      }
    },
  );
}

/// Example 7: Format Amount by Currency Precision
Future<void> exampleFormatAmount() async {
  final getCurrencyUseCase = sl<GetCurrencyBySymbolUseCase>();
  final currencyResult = await getCurrencyUseCase('BTC');
  
  currencyResult.fold(
    (failure) => print('Error: ${failure.message}'),
    (currency) {
      const amount = 0.123456789;
      final formatted = CurrencyValidator.formatAmountByCurrency(currency, amount);
      print('Formatted: $formatted'); // "0.12345679" for BTC (8 decimals)
    },
  );
}

/// Example 8: Create Currency (Admin Only)
Future<void> exampleCreateCurrency() async {
  // Validate input first
  final dto = CreateCurrencyDto(
    symbol: 'DOGE',
    name: 'Dogecoin',
    precisionScale: 8,
    minWithdraw: '10',
    isTradable: true,
    isActive: true,
  );
  
  // Validate before sending
  final validation = CurrencyValidator.validateCreateCurrencyDto(dto);
  if (!validation.isValid) {
    print('Validation failed: ${validation.error}');
    return;
  }
  
  final useCase = sl<CreateCurrencyUseCase>();
  final result = await useCase(CreateCurrencyParams(dto: dto));
  
  result.fold(
    (failure) {
      if (failure is ValidationFailure) {
        print('Validation error: ${failure.message}');
      } else if (failure is ServerFailure) {
        print('Server error: ${failure.message}'); // Might be 409 Conflict
      } else {
        print('Error: ${failure.message}');
      }
    },
    (currency) {
      print('Currency created: ${currency.symbol} - ${currency.name}');
      // Clear cache after creating
      sl<CurrencyCacheService>().clearCache();
    },
  );
}

/// Example 9: Update Currency (Admin Only)
Future<void> exampleUpdateCurrency() async {
  final dto = UpdateCurrencyDto(
    name: 'Bitcoin Updated',
    isActive: false,
    // Only include fields you want to update
  );
  
  final useCase = sl<UpdateCurrencyUseCase>();
  final result = await useCase(
    UpdateCurrencyParams(
      currencyId: 1,
      dto: dto,
    ),
  );
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (currency) {
      print('Currency updated: ${currency.symbol}');
      // Clear cache after updating
      sl<CurrencyCacheService>().clearCache();
    },
  );
}

/// Example 10: Delete Currency (Admin Only - Soft Delete)
Future<void> exampleDeleteCurrency() async {
  final useCase = sl<DeleteCurrencyUseCase>();
  final result = await useCase(1); // Currency ID
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (_) {
      print('Currency deleted successfully');
      // Clear cache after deleting
      sl<CurrencyCacheService>().clearCache();
    },
  );
}

/// Example 11: Using Cache Service
Future<void> exampleUsingCache() async {
  final cacheService = sl<CurrencyCacheService>();
  
  // Try to get from cache first
  final cached = await cacheService.getCachedActiveCurrencies();
  
  if (cached != null) {
    print('Using cached currencies: ${cached.length}');
    return;
  }
  
  // Cache miss - fetch from API
  final useCase = sl<GetActiveCurrenciesUseCase>();
  final result = await useCase(NoParams());
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (currencies) {
      // Cache the result
      cacheService.cacheActiveCurrencies(currencies);
      print('Fetched and cached: ${currencies.length} currencies');
    },
  );
}

/// Example 12: Error Handling with Retry
Future<void> exampleErrorHandlingWithRetry() async {
  final useCase = sl<GetActiveCurrenciesUseCase>();
  
  int retries = 3;
  while (retries > 0) {
    final result = await useCase(NoParams());
    
    result.fold(
      (failure) {
        retries--;
        if (retries > 0) {
          print('Retry ${3 - retries}/3...');
          // Wait before retry (exponential backoff)
          Future.delayed(Duration(seconds: 3 - retries));
        } else {
          print('Failed after 3 retries: ${failure.message}');
        }
      },
      (currencies) {
        print('Success: ${currencies.length} currencies');
        retries = 0; // Success - stop retrying
      },
    );
  }
}

/// Example 13: React Hook-like Pattern with Provider
/// This would be used in a Flutter widget with Provider
/*
class CurrencyDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final useCase = sl<GetActiveCurrenciesUseCase>();
    
    return FutureBuilder(
      future: useCase(NoParams()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        
        return snapshot.data?.fold(
          (failure) => Text('Error: ${failure.message}'),
          (currencies) => DropdownButton(
            items: currencies.map((currency) {
              return DropdownMenuItem(
                value: currency.currencyId,
                child: Text('${currency.symbol} - ${currency.name}'),
              );
            }).toList(),
            onChanged: (value) {
              // Handle selection
            },
          ),
        ) ?? Text('No data');
      },
    );
  }
}
*/
*/

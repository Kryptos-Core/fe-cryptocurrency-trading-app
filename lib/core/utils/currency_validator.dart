import 'package:crypto_trading_app/features/markets/domain/entities/currency.dart';
import 'package:crypto_trading_app/features/markets/domain/dtos/create_currency_dto.dart';

/// Currency Validator
/// Following Single Responsibility Principle (SRP) - only handles validation
/// Following Strategy Pattern - different validation strategies
class CurrencyValidator {
  /// Validate currency symbol
  /// Pattern: ^[A-Z0-9]+$ (uppercase letters and numbers only)
  /// Length: 2-16 characters
  static ValidationResult validateSymbol(String symbol) {
    if (symbol.isEmpty) {
      return const ValidationResult(
        isValid: false,
        error: 'Symbol is required',
      );
    }

    if (symbol.length < 2 || symbol.length > 16) {
      return const ValidationResult(
        isValid: false,
        error: 'Symbol must be between 2 and 16 characters',
      );
    }

    final pattern = RegExp(r'^[A-Z0-9]+$');
    if (!pattern.hasMatch(symbol)) {
      return const ValidationResult(
        isValid: false,
        error: 'Symbol must contain only uppercase letters and numbers',
      );
    }

    return const ValidationResult(isValid: true);
  }

  /// Validate currency name
  /// Length: 1-64 characters
  static ValidationResult validateName(String name) {
    if (name.isEmpty) {
      return const ValidationResult(
        isValid: false,
        error: 'Name is required',
      );
    }

    if (name.length > 64) {
      return const ValidationResult(
        isValid: false,
        error: 'Name must be at most 64 characters',
      );
    }

    return const ValidationResult(isValid: true);
  }

  /// Validate precision scale
  /// Range: 0-18
  static ValidationResult validatePrecisionScale(int? precisionScale) {
    if (precisionScale == null) {
      return const ValidationResult(isValid: true); // Optional
    }

    if (precisionScale < 0 || precisionScale > 18) {
      return const ValidationResult(
        isValid: false,
        error: 'Precision scale must be between 0 and 18',
      );
    }

    return const ValidationResult(isValid: true);
  }

  /// Validate minimum withdrawal amount
  /// Must be a valid decimal string with up to 18 decimal places
  static ValidationResult validateMinWithdraw(String? minWithdraw) {
    if (minWithdraw == null || minWithdraw.isEmpty) {
      return const ValidationResult(isValid: true); // Optional, defaults to "0"
    }

    try {
      final amount = double.parse(minWithdraw);
      if (amount < 0) {
        return const ValidationResult(
          isValid: false,
          error: 'Minimum withdrawal must be >= 0',
        );
      }

      // Check decimal places (max 18)
      final parts = minWithdraw.split('.');
      if (parts.length == 2 && parts[1].length > 18) {
        return const ValidationResult(
          isValid: false,
          error: 'Minimum withdrawal must have at most 18 decimal places',
        );
      }

      return const ValidationResult(isValid: true);
    } catch (e) {
      return const ValidationResult(
        isValid: false,
        error: 'Invalid decimal format for minimum withdrawal',
      );
    }
  }

  /// Validate CreateCurrencyDto
  static ValidationResult validateCreateCurrencyDto(CreateCurrencyDto dto) {
    // Validate symbol
    final symbolResult = validateSymbol(dto.symbol);
    if (!symbolResult.isValid) {
      return symbolResult;
    }

    // Validate name
    final nameResult = validateName(dto.name);
    if (!nameResult.isValid) {
      return nameResult;
    }

    // Validate precision scale
    final precisionResult = validatePrecisionScale(dto.precisionScale);
    if (!precisionResult.isValid) {
      return precisionResult;
    }

    // Validate min withdraw
    final minWithdrawResult = validateMinWithdraw(dto.minWithdraw);
    if (!minWithdrawResult.isValid) {
      return minWithdrawResult;
    }

    return const ValidationResult(isValid: true);
  }

  /// Validate withdrawal amount against currency
  static ValidationResult validateWithdrawalAmount(
    Currency currency,
    String amount,
  ) {
    // Check if currency is active
    if (!currency.isActive) {
      return ValidationResult(
        isValid: false,
        error: '${currency.symbol} is not active',
      );
    }

    try {
      final amountNum = double.parse(amount);
      final minWithdraw = double.parse(currency.minWithdraw);

      if (amountNum < minWithdraw) {
        return ValidationResult(
          isValid: false,
          error:
              'Amount must be >= ${currency.minWithdraw} ${currency.symbol}',
        );
      }

      // Check precision
      final parts = amount.split('.');
      if (parts.length == 2 && parts[1].length > currency.precisionScale) {
        return ValidationResult(
          isValid: false,
          error:
              'Amount must have at most ${currency.precisionScale} decimal places',
        );
      }

      return const ValidationResult(isValid: true);
    } catch (e) {
      return const ValidationResult(
        isValid: false,
        error: 'Invalid amount format',
      );
    }
  }

  /// Format amount according to currency precision
  static String formatAmountByCurrency(Currency currency, double amount) {
    return amount.toStringAsFixed(currency.precisionScale);
  }
}

/// Validation Result
/// Following Value Object Pattern
class ValidationResult {
  final bool isValid;
  final String? error;

  const ValidationResult({
    required this.isValid,
    this.error,
  });
}

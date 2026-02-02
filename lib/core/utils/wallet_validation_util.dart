import 'package:crypto_trading_app/domain/entities/wallet_transaction.dart';

/// Utility class for wallet validation and formatting
///
/// This class provides validation methods for wallet operations following
/// best practices for decimal precision and business rule enforcement.
class WalletValidationUtil {
  /// Check if amount is valid decimal format
  ///
  /// Valid formats:
  /// - "5" (integer)
  /// - "5.5" (decimal)
  /// - "5.123456789012345678" (max 18 decimals)
  ///
  /// Invalid formats:
  /// - "5.1234567890123456789" (19 decimals)
  /// - "-5.5" (negative)
  /// - "abc" (non-numeric)
  static bool isValidDecimalAmount(String amount) {
    try {
      final decimalRegex = RegExp(r'^\d+(\.\d{1,18})?$');
      if (!decimalRegex.hasMatch(amount)) {
        return false;
      }
      // Additional check: ensure it parses as valid number
      double.parse(amount);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get error message for invalid amount
  static String getAmountErrorMessage(String amount) {
    if (amount.isEmpty) {
      return 'Amount is required';
    }

    if (!isValidDecimalAmount(amount)) {
      final decimalRegex = RegExp(r'^\d+(\.\d{1,18})?$');
      if (!decimalRegex.hasMatch(amount)) {
        // Check for specific issues
        if (amount.startsWith('-')) {
          return 'Amount cannot be negative';
        }
        if (amount.contains(RegExp(r'\.\d{19,}'))) {
          return 'Amount can have maximum 18 decimal places';
        }
        return 'Invalid amount format (e.g., "5.5", "10.123456789012345678")';
      }
      return 'Invalid amount';
    }

    try {
      final value = double.parse(amount);
      if (value <= 0) {
        return 'Amount must be greater than 0';
      }
    } catch (e) {
      return 'Invalid amount value';
    }

    return '';
  }

  /// Validate transaction request before sending to API
  ///
  /// Returns:
  ///   - Empty string if valid
  ///   - Error message if invalid
  static String validateTransactionRequest(WalletTransactionRequest request) {
    // Validate amount
    final amountError = getAmountErrorMessage(request.amount);
    if (amountError.isNotEmpty) {
      return amountError;
    }

    // Validate currencyId
    if (request.currencyId <= 0) {
      return 'Invalid currency ID';
    }

    // Validate refId
    if (request.refId <= 0) {
      return 'Invalid reference ID';
    }

    // Validate TRANSFER action has targetUserId
    if (request.action == WalletTransactionAction.transfer) {
      if (request.targetUserId == null || request.targetUserId! <= 0) {
        return 'Target user ID is required for transfer';
      }
    }

    // Validate targetUserId is not set for non-TRANSFER actions
    if (request.action != WalletTransactionAction.transfer &&
        request.targetUserId != null) {
      return 'Target user ID should only be specified for transfer';
    }

    return ''; // Valid
  }

  /// Format amount as currency string
  ///
  /// Example:
  /// ```dart
  /// formatAmount('50.5', 'BTC') → '50.5 BTC'
  /// ```
  static String formatAmount(String amount, String? currencySymbol) {
    if (currencySymbol == null || currencySymbol.isEmpty) {
      return amount;
    }
    return '$amount $currencySymbol';
  }

  /// Truncate amount to specific decimal places
  ///
  /// Example:
  /// ```dart
  /// truncateAmount('5.123456789', 8) → '5.12345678'
  /// ```
  static String truncateAmount(String amount, int decimals) {
    if (!amount.contains('.')) {
      return amount;
    }

    final parts = amount.split('.');
    if (parts[1].length <= decimals) {
      return amount;
    }

    return '${parts[0]}.${parts[1].substring(0, decimals)}';
  }

  /// Check if user has sufficient balance
  ///
  /// Example:
  /// ```dart
  /// hasSufficientBalance('50.5', '10.0') → true
  /// hasSufficientBalance('10.0', '50.5') → false
  /// ```
  static bool hasSufficientBalance(String available, String required) {
    try {
      final availableNum = double.parse(available);
      final requiredNum = double.parse(required);
      return availableNum >= requiredNum;
    } catch (e) {
      return false;
    }
  }

  /// Get balance error message
  static String getBalanceErrorMessage(
    String available,
    String required, {
    String? currencySymbol,
  }) {
    if (!hasSufficientBalance(available, required)) {
      final formatted = currencySymbol != null ? ' $currencySymbol' : '';
      return 'Insufficient balance. Available: $available$formatted';
    }
    return '';
  }

  /// Check if amount is close to available balance (warning)
  ///
  /// Returns true if amount is > 90% of available balance
  static bool isHighAmount(String available, String amount) {
    try {
      final availableNum = double.parse(available);
      final amountNum = double.parse(amount);
      return amountNum > (availableNum * 0.9);
    } catch (e) {
      return false;
    }
  }
}

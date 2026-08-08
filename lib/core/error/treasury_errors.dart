/// Treasury / wallet-related errors.
library;

import 'app_error.dart';

sealed class TreasuryError extends AppError {
  const TreasuryError({
    required super.code,
    required super.userMessageKey,
    super.metadata,
    super.cause,
  });
}

class InsufficientBalanceError extends TreasuryError {
  const InsufficientBalanceError({super.metadata, super.cause})
    : super(
        code: 'TREASURY/INSUFFICIENT_BALANCE',
        userMessageKey: 'error.treasury.insufficientBalance',
      );
}

class WalletLockedError extends TreasuryError {
  const WalletLockedError({super.metadata, super.cause})
    : super(code: 'TREASURY/WALLET_LOCKED', userMessageKey: 'error.treasury.walletLocked');
}

class ChainUnavailableError extends TreasuryError {
  const ChainUnavailableError({super.metadata, super.cause})
    : super(
        code: 'TREASURY/CHAIN_UNAVAILABLE',
        userMessageKey: 'error.treasury.chainUnavailable',
      );
}

class AmountBelowMinError extends TreasuryError {
  const AmountBelowMinError({super.metadata, super.cause})
    : super(code: 'TREASURY/AMOUNT_BELOW_MIN', userMessageKey: 'error.treasury.amountBelowMin');
}

class AmountAboveMaxError extends TreasuryError {
  const AmountAboveMaxError({super.metadata, super.cause})
    : super(code: 'TREASURY/AMOUNT_ABOVE_MAX', userMessageKey: 'error.treasury.amountAboveMax');
}

class WalletNotFoundError extends TreasuryError {
  const WalletNotFoundError({super.metadata, super.cause})
    : super(code: 'TREASURY/WALLET_NOT_FOUND', userMessageKey: 'error.treasury.walletNotFound');
}

class InvalidAddressError extends TreasuryError {
  const InvalidAddressError({super.metadata, super.cause})
    : super(code: 'TREASURY/INVALID_ADDRESS', userMessageKey: 'error.treasury.invalidAddress');
}

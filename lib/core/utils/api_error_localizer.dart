import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

/// Single dispatcher that maps every BE `AppException` `code` to a localized
/// Flutter string. Replaces the legacy per-feature adapters
/// (`order_api_error_localization.dart`, `treasury_api_error_localization.dart`,
/// `blockchain_public_error_localization.dart`, and the market-maker inline
/// localizer) so the FE has a single contract surface with the BE.
///
/// The mapping is hand-written and complete — adding a new code means adding
/// one `case` here AND the corresponding `apiError<PascalCase>` key in
/// `lib/core/l10n/app_en.arb` + `app_vi.arb`. Mirror the BE registry at
/// `be-cryptocurrency-trading-app/docs/ERROR_CODES.md`.
String localizeApiError(
  AppLocalizations l10n, {
  required String? code,
  String? message,
}) {
  final normalizedCode = code?.trim().toUpperCase();
  final fallbackMessage = message?.trim() ?? '';

  // Substring fallback: TRON preflight RPC errors that the BE may not wrap
  // with a specific code (e.g. raw `Contract validate error : account ... does
  // not exist` from the node). Treat as destination-not-activated.
  if (fallbackMessage.isNotEmpty &&
      RegExp(
        r'Contract validate error\s*:\s*account\s*\[.+\]\s*does not exist',
        caseSensitive: false,
      ).hasMatch(fallbackMessage) &&
      normalizedCode != 'TRON_USDT_DESTINATION_NOT_ACTIVATED') {
    return l10n.apiErrorTronUsdtDestinationNotActivated;
  }

  switch (normalizedCode) {
    // ─── Generic ────────────────────────────────────────────────────────
    case 'BAD_REQUEST':
    case 'NOT_FOUND':
    case 'CONFLICT':
    case 'VALIDATION_ERROR':
    case 'INTERNAL_SERVER_ERROR':
    case 'SERVICE_UNAVAILABLE':
      return fallbackMessage.isNotEmpty ? fallbackMessage : l10n.requestFailed;
    case 'UNAUTHORIZED':
      return l10n.ordersSessionExpiredTitle;
    case 'FORBIDDEN':
      return fallbackMessage.isNotEmpty
          ? fallbackMessage
          : l10n.unknownError;

    // ─── Auth & users ───────────────────────────────────────────────────
    case 'EMAIL_EXISTS':
      return l10n.apiErrorEmailExists;
    case 'INVALID_OTP':
      return l10n.apiErrorInvalidOtp;
    case 'OTP_REQUIRED':
      return l10n.apiErrorOtpRequired;
    case 'OTP_COOLDOWN':
      return l10n.apiErrorOtpCooldown(60);
    case 'OTP_ATTEMPT_LIMIT_EXCEEDED':
      return l10n.apiErrorOtpAttemptLimitExceeded(900);
    case 'TWO_FA_REQUIRED':
      return l10n.apiErrorTwoFaRequired;
    case 'ACCOUNT_BANNED':
      return l10n.apiErrorAccountBanned;
    case 'EMAIL_VERIFICATION_DISABLED':
      return l10n.apiErrorEmailVerificationDisabled;
    case 'NOT_WALLET_PLACEHOLDER':
      return l10n.apiErrorNotWalletPlaceholder;
    case 'USE_CONTACT_EMAIL_VERIFICATION':
      return l10n.apiErrorUseContactEmailVerification;
    case 'USE_CHANGE_PASSWORD_ENDPOINT':
      return l10n.apiErrorUseChangePasswordEndpoint;
    case 'INVALID_PAYLOAD':
      return l10n.apiErrorInvalidPayload;
    case 'INVALID_CHANGE_TYPE':
      return l10n.apiErrorInvalidChangeType;
    case 'AVATAR_UPLOAD_DISABLED':
      return l10n.apiErrorAvatarUploadDisabled;
    case 'CONTACT_EMAIL_REQUIRED':
      return l10n.apiErrorContactEmailRequired;
    case 'INVALID_AVATAR_FORMAT':
      return l10n.apiErrorInvalidAvatarFormat;
    case 'AVATAR_REQUIRED':
      return l10n.apiErrorAvatarRequired;

    // ─── Withdrawals / onchain (user) ──────────────────────────────────
    case 'WITHDRAWAL_PROCESSING':
      return l10n.apiErrorWithdrawalProcessing;
    case 'WITHDRAWAL_DUPLICATE':
      return l10n.apiErrorWithdrawalDuplicate;
    case 'WITHDRAWAL_NOT_FOUND':
      return l10n.apiErrorWithdrawalNotFound;
    case 'WITHDRAWAL_PENDING_EXISTS':
      return l10n.apiErrorWithdrawalPendingExists(1);
    case 'PENDING_WITHDRAWALS':
      return l10n.apiErrorPendingWithdrawals;
    case 'USER_NOT_FOUND':
      return l10n.apiErrorUserNotFound;
    case 'WALLET_NOT_FOUND':
      return l10n.apiErrorWalletNotFound;
    case 'INVALID_AMOUNT':
      return l10n.apiErrorInvalidAmount;
    case 'INVALID_TARGET':
      return l10n.apiErrorInvalidTarget;
    case 'TARGET_REQUIRED':
      return l10n.apiErrorTargetRequired;
    case 'INVALID_ACTION':
      return l10n.apiErrorInvalidAction;
    case 'INSUFFICIENT_BALANCE':
      return l10n.apiErrorInsufficientBalance;
    case 'ACCOUNT_FROZEN':
      return l10n.apiErrorAccountFrozen;
    case 'CHAIN_REQUIRED':
      return l10n.apiErrorChainRequired;
    case 'TX_HASH_REQUIRED':
      return l10n.apiErrorTxHashRequired;
    case 'ADMIN_INGEST_MISSING_PARAMS':
      return l10n.apiErrorAdminIngestMissingParams;
    case 'INVALID_ADDRESS':
      return l10n.apiErrorInvalidAddress('the chain');
    case 'INVALID_TRON_ADDRESS':
      return l10n.apiErrorInvalidTronAddress;
    case 'INVALID_EVM_ADDRESS':
      return l10n.apiErrorInvalidEvmAddress;
    case 'INVALID_SIGNATURE':
      return l10n.apiErrorInvalidSignature;
    case 'WALLET_ALREADY_LINKED':
      return l10n.apiErrorWalletAlreadyLinked;
    case 'WALLET_INACTIVE':
      return l10n.apiErrorWalletInactive;
    case 'LINK_NOT_FOUND':
      return l10n.apiErrorLinkNotFound;

    // ─── Treasury / transaction wallets ────────────────────────────────
    case 'TREASURY_WALLET_BUSY':
      return l10n.apiErrorTreasuryWalletBusy;
    case 'TREASURY_WALLET_BUSY_TIMEOUT':
      return l10n.apiErrorTreasuryWalletBusyTimeout;
    case 'TREASURY_WALLET_INACTIVE':
      return l10n.apiErrorTreasuryWalletInactive;
    case 'TREASURY_WALLET_LOCKED':
      return l10n.apiErrorTreasuryWalletLocked;
    case 'TREASURY_CHAIN_UNSUPPORTED':
      return l10n.apiErrorTreasuryChainUnsupported;
    case 'TREASURY_CHAIN_NOT_EVM':
      return l10n.apiErrorTreasuryChainNotEvm;
    case 'TREASURY_INVALID_AMOUNT':
      return l10n.apiErrorTreasuryInvalidAmount;
    case 'TREASURY_SWEEP_USDT_ZERO':
      return l10n.apiErrorTreasurySweepUsdtZero;
    case 'TREASURY_USDT_CHAIN':
      return l10n.apiErrorTreasuryUsdtChain;
    case 'TREASURY_CONFIRM_NO_WALLET':
      return l10n.apiErrorTreasuryConfirmNoWallet;
    case 'TREASURY_MANUAL_SETTLE_TX_EMPTY':
      return l10n.apiErrorTreasuryManualSettleTxEmpty;
    case 'TREASURY_OPERATION_NOT_FOUND':
      return l10n.apiErrorTreasuryOperationNotFound;
    case 'TREASURY_OPERATION_STATE_INVALID':
      return l10n.apiErrorTreasuryOperationStateInvalid;
    case 'TREASURY_OPERATION_NOT_QUEUED':
      return l10n.apiErrorTreasuryOperationNotQueued;
    case 'TREASURY_OPERATION_NOT_PROCESSING':
      return l10n.apiErrorTreasuryOperationNotProcessing;
    case 'TREASURY_OPERATION_NOT_CONFIRMING':
      return l10n.apiErrorTreasuryOperationNotConfirming;
    case 'TREASURY_OPERATION_NOT_COMPLETED':
      return l10n.apiErrorTreasuryOperationNotCompleted;
    case 'TREASURY_OPERATION_NOT_FAILED':
      return l10n.apiErrorTreasuryOperationNotFailed;
    case 'TREASURY_TX_HASH_NOT_FOUND':
      return l10n.apiErrorTreasuryTxHashNotFound;
    case 'TREASURY_INSUFFICIENT_FUNDS':
      return l10n.apiErrorTreasuryInsufficientFunds;
    case 'TREASURY_BALANCE_RECONCILE_FAILED':
      return l10n.apiErrorTreasuryBalanceReconcileFailed;
    case 'TREASURY_OPERATION_TYPE_UNSUPPORTED':
      return l10n.apiErrorTreasuryOperationTypeUnsupported;
    case 'TREASURY_RPC_UNAVAILABLE':
      return l10n.apiErrorTreasuryRpcUnavailable;
    case 'TREASURY_RPC_TIMEOUT':
      return l10n.apiErrorTreasuryRpcTimeout;
    case 'TREASURY_GAS_ESTIMATE_FAILED':
      return l10n.apiErrorTreasuryGasEstimateFailed;
    case 'TREASURY_NONCE_CONFLICT':
      return l10n.apiErrorTreasuryNonceConflict;
    case 'TREASURY_TX_REVERTED':
      return l10n.apiErrorTreasuryTxReverted;
    case 'TREASURY_TX_BROADCAST_FAILED':
      return l10n.apiErrorTreasuryTxBroadcastFailed;
    case 'TX_WALLET_EXISTS':
      return l10n.apiErrorTxWalletExists;
    case 'TX_WALLET_NOT_FOUND':
      return l10n.apiErrorTxWalletNotFound;
    case 'TX_WALLET_NON_ZERO_BALANCE':
      // The BE includes `{maxAmount} {symbol}` in `message`. Show it verbatim.
      return fallbackMessage.isNotEmpty
          ? fallbackMessage
          : l10n.apiErrorTxWalletNonZeroBalanceShort;
    case 'TX_WALLET_USDT_NON_ZERO':
      return l10n.apiErrorTxWalletUsdtNonZero;
    case 'TX_WALLET_DEFAULT_DEPOSIT_DELETE_FORBIDDEN':
      return l10n.apiErrorTxWalletDefaultDepositDelete;
    case 'TX_WALLET_OPERATION_IN_FLIGHT':
      return l10n.apiErrorTxWalletOperationInFlight;
    case 'DEFAULT_USER_DEPOSIT_DEACTIVATE_FORBIDDEN':
      return l10n.apiErrorDefaultUserDepositDeactivate;
    case 'TRON_USDT_DESTINATION_NOT_ACTIVATED':
      return l10n.apiErrorTronUsdtDestinationNotActivated;
    case 'TRON_ACCOUNT_PREFLIGHT_UNAVAILABLE':
      return l10n.apiErrorTronAccountPreflightUnavailable;
    case 'TREASURY_MAIN_WALLET_NOT_FOUND':
      return l10n.apiErrorTreasuryMainWalletNotFound;
    case 'TREASURY_MAIN_WALLET_CONFLICT':
      return l10n.apiErrorTreasuryMainWalletConflict;

    // ─── Orders / matching ─────────────────────────────────────────────
    case 'ORDER_NOT_FOUND':
      return l10n.apiErrorOrderNotFound;
    case 'ORDER_NOT_OPEN':
      return l10n.apiErrorOrderNotOpen;
    case 'INVALID_PRICE':
      return l10n.apiErrorInvalidPrice;
    case 'INVALID_INPUT':
      return l10n.apiErrorInvalidInput;
    case 'INVALID_MARKET_BUY_RESERVE':
      return l10n.apiErrorInvalidMarketBuyReserve;
    case 'NO_LIQUIDITY':
      return l10n.apiErrorNoLiquidity;
    case 'ORDER_CREATE_FAILED':
      return l10n.apiErrorOrderCreateFailed;
    case 'INVALID_STATE':
      return l10n.apiErrorInvalidState;
    case 'OVERFILL_ATTEMPT':
      return l10n.apiErrorOverfillAttempt;
    case 'CANCEL_FAILED':
      return l10n.apiErrorCancelFailed;
    case 'PAIR_NOT_FOUND':
      return l10n.apiErrorPairNotFound;
    case 'INVALID_ORDER_TYPE':
      return l10n.apiErrorInvalidOrderType;
    case 'ORDER_BOOK_SERVICE_UNAVAILABLE':
      return l10n.apiErrorOrderBookServiceUnavailable;
    case 'INVALID_DEPTH_LIMIT':
      return l10n.apiErrorInvalidDepthLimit;
    case 'INVALID_INTERVAL':
      return l10n.apiErrorInvalidInterval;
    case 'MARKET_PAIR_SYMBOL_EXISTS':
      return l10n.apiErrorMarketPairSymbolExists;
    case 'BASE_QUOTE_SAME':
      return l10n.apiErrorBaseQuoteSame;
    case 'BASE_QUOTE_REQUIRED':
      return l10n.apiErrorBaseQuoteRequired;

    // ─── Markets / currencies ──────────────────────────────────────────
    case 'CURRENCY_NOT_FOUND':
      return l10n.apiErrorCurrencyNotFound;
    case 'CURRENCY_SYMBOL_EXISTS':
      return l10n.apiErrorCurrencySymbolExists;
    case 'CURRENCY_DISABLED':
      return l10n.apiErrorCurrencyDisabled;

    // ─── Market maker ──────────────────────────────────────────────────
    case 'MARKET_MAKER_CONFIG_NOT_FOUND':
      return l10n.apiErrorMarketMakerConfigNotFound;
    case 'MARKET_MAKER_CONFIG_CONFLICT':
      return l10n.apiErrorMarketMakerConfigConflict;
    case 'MARKET_MAKER_INVALID_SPREAD':
      return l10n.apiErrorMarketMakerInvalidSpread;
    case 'MARKET_MAKER_INVALID_AMOUNT':
      return l10n.apiErrorMarketMakerInvalidAmount;
    case 'MARKET_MAKER_NO_ACTIVE_PAIRS':
      return l10n.apiErrorMarketMakerNoActivePairs;
    case 'MARKET_MAKER_PLACE_FAILED':
      return l10n.apiErrorMarketMakerPlaceFailed;

    // ─── System config / admin authz ──────────────────────────────────
    case 'CONFIG_KEY_NOT_FOUND':
      return l10n.apiErrorConfigKeyNotFound;
    case 'CONFIG_KEY_DISALLOWED':
      return l10n.apiErrorConfigKeyDisallowed;
    case 'CONFIG_KEY_READ_ONLY':
      return l10n.apiErrorConfigKeyReadOnly;
    case 'CONFIG_VALUE_INVALID':
      return l10n.apiErrorConfigValueInvalid;
    case 'ADMIN_REQUIRED':
      return l10n.apiErrorAdminRequired;
    case 'RISK_OFFICER_REQUIRED':
      return l10n.apiErrorRiskOfficerRequired;
    case 'FINANCE_MANAGER_REQUIRED':
      return l10n.apiErrorFinanceManagerRequired;

    // ─── Deposits ──────────────────────────────────────────────────────
    case 'DEPOSIT_NOT_FOUND':
      return l10n.apiErrorDepositNotFound;
    case 'DEPOSIT_ALREADY_PAID':
      return l10n.apiErrorDepositAlreadyPaid;
    case 'DEPOSIT_AMOUNT_INVALID':
      return l10n.apiErrorDepositAmountInvalid;
    case 'DEPOSIT_CHAIN_UNSUPPORTED':
      return l10n.apiErrorDepositChainUnsupported;
    case 'DEPOSIT_POLL_FAILED':
      return l10n.apiErrorDepositPollFailed;
    case 'TX_FAILED':
      return l10n.apiErrorTxFailed;

    // ─── Encryption / infra ────────────────────────────────────────────
    case 'ENCRYPTION_FAILED':
      return l10n.apiErrorEncryptionFailed;
    case 'DECRYPTION_FAILED':
      return l10n.apiErrorDecryptionFailed;
    case 'ENCRYPTED_PAYLOAD_MALFORMED':
      return l10n.apiErrorEncryptedPayloadMalformed;
    case 'DECRYPTED_PAYLOAD_INVALID':
      return l10n.apiErrorDecryptedPayloadInvalid;
    case 'EXTERNAL_PROVIDER_UNAVAILABLE':
      return l10n.apiErrorExternalProviderUnavailable;
    case 'EXTERNAL_PROVIDER_RATE_LIMITED':
      return l10n.apiErrorExternalProviderRateLimited;

    // ─── Notifications / push ──────────────────────────────────────────
    case 'NOTIFICATION_DELIVERY_FAILED':
      return l10n.apiErrorNotificationDeliveryFailed;
    case 'FCM_NOT_CONFIGURED':
      return l10n.apiErrorFcmNotConfigured;

    // ─── Tron send ─────────────────────────────────────────────────────
    case 'TRON_SEND_FAILED':
      return l10n.apiErrorTronSendFailed;
  }

  // Unknown code — fall back to whatever BE sent, otherwise a generic notice.
  return fallbackMessage.isNotEmpty ? fallbackMessage : l10n.apiErrorGeneric;
}
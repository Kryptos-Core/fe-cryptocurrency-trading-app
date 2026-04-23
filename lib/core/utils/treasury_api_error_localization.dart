import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

/// Maps treasury API [code] (Nest [AppException]) to localized copy. Falls back to [message]
/// when the code is unknown so the UI is never empty.
String localizeTreasuryApiError(
  AppLocalizations l10n, {
  required String? code,
  required String? message,
}) {
  final m = (message ?? '').trim();
  switch (code) {
    case 'TX_WALLET_NON_ZERO_BALANCE':
      final match = RegExp(r'must be at most\s+(\S+)\s+(\S+)').firstMatch(m);
      if (match != null) {
        return l10n.apiErrorTxWalletNonZeroBalance(match[1]!, match[2]!);
      }
      return l10n.apiErrorTxWalletNonZeroBalanceShort;
    case 'TX_WALLET_USDT_NON_ZERO':
      return l10n.apiErrorTxWalletUsdtNonZero;
    case 'TX_WALLET_DEFAULT_DEPOSIT_DELETE_FORBIDDEN':
      return l10n.apiErrorTxWalletDefaultDepositDelete;
    case 'TX_WALLET_OPERATION_IN_FLIGHT':
      return l10n.apiErrorTxWalletOperationInFlight;
    case 'TX_WALLET_EXISTS':
      return l10n.apiErrorTxWalletExists;
    case 'TREASURY_WALLET_INACTIVE':
      return l10n.apiErrorTreasuryWalletInactive;
    case 'TREASURY_WALLET_LOCKED':
      return l10n.apiErrorTreasuryWalletLocked;
    case 'TREASURY_WALLET_BUSY':
      return l10n.apiErrorTreasuryWalletBusy;
    case 'TREASURY_WALLET_BUSY_TIMEOUT':
      return l10n.apiErrorTreasuryWalletBusyTimeout;
    case 'DEFAULT_USER_DEPOSIT_DEACTIVATE_FORBIDDEN':
      return l10n.apiErrorDefaultUserDepositDeactivate;
    case 'TRON_USDT_DESTINATION_NOT_ACTIVATED':
      return l10n.apiErrorTronUsdtDestinationNotActivated;
    case 'TRON_ACCOUNT_PREFLIGHT_UNAVAILABLE':
      return l10n.apiErrorTronAccountPreflightUnavailable;
    default:
      if (RegExp(
        r'Contract validate error\s*:\s*account\s*\[.+\]\s*does not exist',
        caseSensitive: false,
      ).hasMatch(m)) {
        return l10n.apiErrorTronUsdtDestinationNotActivated;
      }
      if (m.isNotEmpty) return m;
      return l10n.apiErrorGeneric;
  }
}

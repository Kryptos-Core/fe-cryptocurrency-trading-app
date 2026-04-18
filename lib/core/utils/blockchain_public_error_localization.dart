import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

/// How to present the empty deposit-address slot (platform section).
enum DepositAddressEmptyKind {
  /// No API error — generic “could not load” copy.
  generic,

  /// Treasury / default wallet not configured — “not supported” style messaging.
  configurationUnavailable,

  /// Other API or server failures.
  error,
}

/// True when the backend indicates deposit is not configured for this chain.
bool isDepositConfigurationUnavailable({
  String? code,
  String? serverMessage,
}) {
  switch (code) {
    case 'TREASURY_MAIN_WALLET_NOT_CONFIGURED':
    case 'DEPOSIT_DEFAULT_NOT_CONFIGURED':
      return true;
    default:
      break;
  }
  final msg = serverMessage ?? '';
  if (msg.contains('No active default main wallet configured')) {
    return true;
  }
  return false;
}

/// Maps provider error state to [DepositAddressEmptyKind] for inline UI.
DepositAddressEmptyKind resolveDepositAddressEmptyKind({
  required bool hasErrorOrCode,
  String? code,
  String? serverMessage,
}) {
  if (!hasErrorOrCode) {
    return DepositAddressEmptyKind.generic;
  }
  if (isDepositConfigurationUnavailable(
    code: code,
    serverMessage: serverMessage,
  )) {
    return DepositAddressEmptyKind.configurationUnavailable;
  }
  return DepositAddressEmptyKind.error;
}

/// True when deposit address is missing by configuration — UI already shows inline
/// “Chưa mở nạp”; avoid a redundant error snackbar on load.
bool suppressDepositAddressUnavailableSnackBar({
  String? code,
  String? serverMessage,
}) {
  return isDepositConfigurationUnavailable(
    code: code,
    serverMessage: serverMessage,
  );
}

/// User-facing copy for deposit flows. Avoids showing ops/API hints to traders.
String localizeBlockchainDepositUserMessage(
  AppLocalizations l10n, {
  String? code,
  String? serverMessage,
}) {
  if (isDepositConfigurationUnavailable(
    code: code,
    serverMessage: serverMessage,
  )) {
    return l10n.depositMethodUnavailable;
  }

  final msg = serverMessage ?? '';

  if (msg.isNotEmpty) return msg;
  return l10n.requestFailed;
}

import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';

/// User-facing copy for deposit flows. Avoids showing ops/API hints to traders.
String localizeBlockchainDepositUserMessage(
  AppLocalizations l10n, {
  String? code,
  String? serverMessage,
}) {
  switch (code) {
    case 'TREASURY_MAIN_WALLET_NOT_CONFIGURED':
    case 'DEPOSIT_DEFAULT_NOT_CONFIGURED':
      return l10n.depositMethodUnavailable;
    default:
      break;
  }

  final msg = serverMessage ?? '';
  if (msg.contains('No active default main wallet configured')) {
    return l10n.depositMethodUnavailable;
  }

  if (msg.isNotEmpty) return msg;
  return l10n.requestFailed;
}

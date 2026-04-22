import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/onchain_tx_status.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

String onchainTxStatusUiLabel(AppLocalizations l10n, OnchainTxStatus status) {
  switch (status) {
    case OnchainTxStatus.pending:
      return l10n.onchainTxStatusPending;
    case OnchainTxStatus.confirming:
      return l10n.onchainTxStatusConfirming;
    case OnchainTxStatus.completed:
      return l10n.onchainTxStatusCompleted;
    case OnchainTxStatus.failed:
      return l10n.onchainTxStatusFailed;
    case OnchainTxStatus.txBroadcast:
      return l10n.onchainTxStatusTxBroadcast;
    case OnchainTxStatus.unmatched:
      return l10n.onchainTxStatusUnmatched;
    case OnchainTxStatus.unknown:
      return l10n.onchainTxStatusUnknown;
  }
}

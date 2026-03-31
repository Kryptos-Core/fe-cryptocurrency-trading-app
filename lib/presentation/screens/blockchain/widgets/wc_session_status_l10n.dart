import 'package:crypto_trading_app/domain/entities/blockchain/wc_session_status.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';

extension WcSessionStatusL10n on WcSessionStatus {
  String label(AppLocalizations l10n) {
    switch (this) {
      case WcSessionStatus.idle:
        return l10n.wcStatusIdle;
      case WcSessionStatus.pending:
        return l10n.wcStatusPending;
      case WcSessionStatus.connected:
        return l10n.wcStatusConnected;
      case WcSessionStatus.signed:
        return l10n.wcStatusSigned;
      case WcSessionStatus.expired:
        return l10n.wcStatusExpired;
      case WcSessionStatus.failed:
        return l10n.wcStatusFailed;
    }
  }
}

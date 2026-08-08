import 'package:crypto_trading_app/features/settings/domain/models/runtime_setting_row.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

/// Localized title/description for [RuntimeSettingRow]; keys match BE `RUNTIME_SETTING_KEYS`.
class RuntimeSettingRowL10n {
  RuntimeSettingRowL10n._();

  static String name(AppLocalizations l10n, RuntimeSettingRow r) {
    switch (r.key) {
      case 'WALLET_SYNC_INTERVAL':
        return l10n.runtimeSettingWalletSyncIntervalName;
      case 'WALLET_RECONCILIATION_THRESHOLD':
        return l10n.runtimeSettingWalletReconciliationThresholdName;
      case 'TRON_NILE_FULL_HOST':
        return l10n.runtimeSettingTronNileFullHostName;
      case 'TRON_SHASTA_FULL_HOST':
        return l10n.runtimeSettingTronShastaFullHostName;
      case 'TRON_DEFAULT_NETWORK':
        return l10n.runtimeSettingTronDefaultNetworkName;
      case 'SOLANA_DEVNET_URL':
        return l10n.runtimeSettingSolanaDevnetUrlName;
      case 'BLOCKCHAIN_ALLOW_TEST_SIGNATURE':
        return l10n.runtimeSettingBlockchainAllowTestSignatureName;
      case 'BLOCKCHAIN_WITHDRAW_AUTO_MAX':
        return l10n.runtimeSettingBlockchainWithdrawAutoMaxName;
      case 'BLOCKCHAIN_WITHDRAW_AUTO_MAX_SOLANA_DEVNET':
        return l10n.runtimeSettingBlockchainWithdrawAutoMaxSolanaDevnetName;
      case 'BLOCKCHAIN_WITHDRAW_AUTO_MAX_TRON_NILE':
        return l10n.runtimeSettingBlockchainWithdrawAutoMaxTronNileName;
      case 'BLOCKCHAIN_WITHDRAW_AUTO_MAX_TRON_SHASTA':
        return l10n.runtimeSettingBlockchainWithdrawAutoMaxTronShastaName;
      case 'BLOCKCHAIN_WITHDRAW_ETH_SYMBOL':
        return l10n.runtimeSettingBlockchainWithdrawEthSymbolName;
      case 'BLOCKCHAIN_WITHDRAW_SOL_SYMBOL':
        return l10n.runtimeSettingBlockchainWithdrawSolSymbolName;
      case 'BLOCKCHAIN_WITHDRAW_TRON_SYMBOL':
        return l10n.runtimeSettingBlockchainWithdrawTronSymbolName;
      case 'PLATFORM_CASH_CURRENCY_SYMBOL':
        return l10n.runtimeSettingPlatformCashCurrencySymbolName;
      case 'BLOCKCHAIN_DEPOSIT_TRX_TO_USDT_RATE':
        return l10n.runtimeSettingBlockchainDepositTrxToUsdtRateName;
      case 'BLOCKCHAIN_DEPOSIT_ETH_TO_USDT_RATE':
        return l10n.runtimeSettingBlockchainDepositEthToUsdtRateName;
      case 'BLOCKCHAIN_DEPOSIT_SOL_TO_USDT_RATE':
        return l10n.runtimeSettingBlockchainDepositSolToUsdtRateName;
      case 'EMAIL_VERIFICATION_REQUIRED':
        return l10n.runtimeSettingEmailVerificationRequiredName;
      default:
        return r.name;
    }
  }

  static String? description(AppLocalizations l10n, RuntimeSettingRow r) {
    switch (r.key) {
      case 'WALLET_SYNC_INTERVAL':
        return l10n.runtimeSettingWalletSyncIntervalDesc;
      case 'WALLET_RECONCILIATION_THRESHOLD':
        return l10n.runtimeSettingWalletReconciliationThresholdDesc;
      case 'TRON_NILE_FULL_HOST':
        return l10n.runtimeSettingTronNileFullHostDesc;
      case 'TRON_SHASTA_FULL_HOST':
        return l10n.runtimeSettingTronShastaFullHostDesc;
      case 'TRON_DEFAULT_NETWORK':
        return l10n.runtimeSettingTronDefaultNetworkDesc;
      case 'SOLANA_DEVNET_URL':
        return l10n.runtimeSettingSolanaDevnetUrlDesc;
      case 'BLOCKCHAIN_ALLOW_TEST_SIGNATURE':
        return l10n.runtimeSettingBlockchainAllowTestSignatureDesc;
      case 'BLOCKCHAIN_WITHDRAW_AUTO_MAX':
        return l10n.runtimeSettingBlockchainWithdrawAutoMaxDesc;
      case 'BLOCKCHAIN_WITHDRAW_AUTO_MAX_SOLANA_DEVNET':
        return l10n.runtimeSettingBlockchainWithdrawAutoMaxSolanaDevnetDesc;
      case 'BLOCKCHAIN_WITHDRAW_AUTO_MAX_TRON_NILE':
        return l10n.runtimeSettingBlockchainWithdrawAutoMaxTronNileDesc;
      case 'BLOCKCHAIN_WITHDRAW_AUTO_MAX_TRON_SHASTA':
        return l10n.runtimeSettingBlockchainWithdrawAutoMaxTronShastaDesc;
      case 'BLOCKCHAIN_WITHDRAW_ETH_SYMBOL':
        return l10n.runtimeSettingBlockchainWithdrawEthSymbolDesc;
      case 'BLOCKCHAIN_WITHDRAW_SOL_SYMBOL':
        return l10n.runtimeSettingBlockchainWithdrawSolSymbolDesc;
      case 'BLOCKCHAIN_WITHDRAW_TRON_SYMBOL':
        return l10n.runtimeSettingBlockchainWithdrawTronSymbolDesc;
      case 'PLATFORM_CASH_CURRENCY_SYMBOL':
        return l10n.runtimeSettingPlatformCashCurrencySymbolDesc;
      case 'BLOCKCHAIN_DEPOSIT_TRX_TO_USDT_RATE':
        return l10n.runtimeSettingBlockchainDepositTrxToUsdtRateDesc;
      case 'BLOCKCHAIN_DEPOSIT_ETH_TO_USDT_RATE':
        return l10n.runtimeSettingBlockchainDepositEthToUsdtRateDesc;
      case 'BLOCKCHAIN_DEPOSIT_SOL_TO_USDT_RATE':
        return l10n.runtimeSettingBlockchainDepositSolToUsdtRateDesc;
      case 'EMAIL_VERIFICATION_REQUIRED':
        return l10n.runtimeSettingEmailVerificationRequiredDesc;
      default:
        return r.description;
    }
  }

  static String dataTypeSuffix(AppLocalizations l10n, String type) {
    switch (type.toUpperCase()) {
      case 'STRING':
        return l10n.paymentConfigRuntimeTypeString;
      case 'INTEGER':
        return l10n.paymentConfigRuntimeTypeInteger;
      case 'BOOLEAN':
        return l10n.paymentConfigRuntimeTypeBoolean;
      case 'FLOAT':
        return l10n.paymentConfigRuntimeTypeFloat;
      default:
        return type;
    }
  }
}

import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';

/// True when [ApiConstants.env] is `production` (case-insensitive): treasury pickers use mainnet only.
bool get treasuryChainsUseMainnetOnly =>
    ApiConstants.env.trim().toLowerCase() == 'production';

const Set<String> _kTreasuryMainWalletMainnetChains = <String>{
  'TRON_MAINNET',
  'BSC_MAINNET',
  'SOLANA_MAINNET',
};

const Set<String> _kTreasuryOpsMainnetChains = <String>{
  'TRON_MAINNET',
  'ETH_MAINNET',
};

/// Hot wallet / main-wallet API chains (Fund–Sweep style).
const List<String> kTreasuryMainWalletChainValues = <String>[
  'TRON_NILE',
  'TRON_MAINNET',
  'BSC_TESTNET',
  'BSC_MAINNET',
  'SOLANA_DEVNET',
  'SOLANA_MAINNET',
];

/// Payment config → operational treasury wallets (create / filter).
const List<String> kTreasuryOpsChainValues = <String>[
  'TRON_NILE',
  'TRON_SHASTA',
  'TRON_MAINNET',
  'ETH_SEPOLIA',
  'ETH_MAINNET',
];

/// History filter (subset).
const List<String> kTreasuryHistoryFilterChainValues = <String>[
  'TRON_NILE',
  'TRON_SHASTA',
  'ETH_SEPOLIA',
];

/// Withdrawal admin list filter.
const List<String> kWithdrawalFilterChainValues = <String>[
  'TRON_NILE',
  'TRON_SHASTA',
  'ETH_SEPOLIA',
  'SOLANA_DEVNET',
];

/// Managed deposit wallets — recommended chain + defaults rows.
const List<String> kManagedWalletsChainValues = <String>[
  'TRON_NILE',
  'TRON_SHASTA',
];

/// Main-wallet screen / API: mainnet in production, testnet otherwise.
List<String> treasuryMainWalletChainsForCurrentEnv() {
  if (treasuryChainsUseMainnetOnly) {
    return kTreasuryMainWalletChainValues
        .where(_kTreasuryMainWalletMainnetChains.contains)
        .toList(growable: false);
  }
  return kTreasuryMainWalletChainValues
      .where((c) => !_kTreasuryMainWalletMainnetChains.contains(c))
      .toList(growable: false);
}

/// Payment ops wallets (create / filter): mainnet in production, testnet otherwise.
List<String> treasuryOpsChainsForCurrentEnv() {
  if (treasuryChainsUseMainnetOnly) {
    return kTreasuryOpsChainValues
        .where(_kTreasuryOpsMainnetChains.contains)
        .toList(growable: false);
  }
  return kTreasuryOpsChainValues
      .where((c) => !_kTreasuryOpsMainnetChains.contains(c))
      .toList(growable: false);
}

/// Treasury history chain filter: mirrors ops (ETH + TRON) per environment.
List<String> treasuryHistoryFilterChainsForCurrentEnv() {
  if (treasuryChainsUseMainnetOnly) {
    return const <String>['TRON_MAINNET', 'ETH_MAINNET'];
  }
  return kTreasuryHistoryFilterChainValues;
}

/// Withdrawal admin filter chains per environment.
List<String> withdrawalFilterChainsForCurrentEnv() {
  if (treasuryChainsUseMainnetOnly) {
    return const <String>[
      'TRON_MAINNET',
      'ETH_MAINNET',
      'SOLANA_MAINNET',
    ];
  }
  return kWithdrawalFilterChainValues;
}

/// Managed deposit wallets: Tron testnets vs mainnet.
List<String> managedWalletsChainsForCurrentEnv() {
  if (treasuryChainsUseMainnetOnly) {
    return const <String>['TRON_MAINNET'];
  }
  return kManagedWalletsChainValues;
}

/// Default hot-wallet chain for the current [ENV].
String treasuryDefaultMainWalletChainForCurrentEnv() =>
    treasuryMainWalletChainsForCurrentEnv().first;

/// Whether [chain] is allowed for main-wallet flows in the current [ENV].
bool isTreasuryMainWalletChainAllowedForCurrentEnv(String chain) =>
    treasuryMainWalletChainsForCurrentEnv().contains(chain);

/// User-facing label for a chain API constant (e.g. `TRON_NILE`).
String treasuryChainDisplayLabel(AppLocalizations l10n, String chain) {
  switch (chain) {
    case 'TRON_NILE':
      return l10n.treasuryChainTronNile;
    case 'TRON_MAINNET':
      return l10n.treasuryChainTronMainnet;
    case 'TRON_SHASTA':
      return l10n.treasuryChainTronShasta;
    case 'BSC_TESTNET':
      return l10n.treasuryChainBscTestnet;
    case 'BSC_MAINNET':
      return l10n.treasuryChainBscMainnet;
    case 'SOLANA_DEVNET':
      return l10n.treasuryChainSolanaDevnet;
    case 'SOLANA_MAINNET':
      return l10n.treasuryChainSolanaMainnet;
    case 'ETH_SEPOLIA':
      return l10n.treasuryChainEthSepolia;
    case 'ETH_MAINNET':
      return l10n.treasuryChainEthMainnet;
    default:
      return chain;
  }
}

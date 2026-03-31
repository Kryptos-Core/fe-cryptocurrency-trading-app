import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';

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

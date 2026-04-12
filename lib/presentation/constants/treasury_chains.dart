import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';

/// Whether treasury / withdrawal chain pickers list **mainnet-only** API values.
///
/// Aligns with backend [ONCHAIN_OPERATOR_MODE] when that key is set in `.env`:
/// - `sandbox` → testnet-only lists (Nile, Shasta, BSC Chapel, …).
/// - anything else (e.g. `production`) → mainnet-only lists.
///
/// If [ONCHAIN_OPERATOR_MODE] is unset or blank, falls back to legacy
/// [ApiConstants.env] == `production` so existing installs keep prior behavior.
bool get treasuryChainsUseMainnetOnly {
  if (!dotenv.isInitialized) {
    // Widget tests / callers before main() loads .env — prefer testnet lists.
    return false;
  }
  final raw = dotenv.env['ONCHAIN_OPERATOR_MODE']?.trim();
  if (raw != null && raw.isNotEmpty) {
    return parseOnChainOperatorMode(dotenv.env) == OnChainOperatorMode.production;
  }
  return ApiConstants.env.trim().toLowerCase() == 'production';
}

/// Actionable chains (no TON) — order aligned with backend [listActionableOnchainChainCodes].
const List<String> kOnchainActionableProductionCodes = <String>[
  'BSC_MAINNET',
  'SOLANA_MAINNET',
  'ETH_MAINNET',
  'BASE_MAINNET',
  'ARBITRUM_MAINNET',
  'OPTIMISM_MAINNET',
  'POLYGON_MAINNET',
  'AVALANCHE_MAINNET',
  'GNOSIS_MAINNET',
  'LINEA_MAINNET',
  'FANTOM_MAINNET',
  'TRON_MAINNET',
];

List<String> kOnchainActionableSandboxCodes(String tronDefault) {
  final tron = tronDefault == 'TRON_SHASTA' ? 'TRON_SHASTA' : 'TRON_NILE';
  return <String>[
    'BSC_CHAPEL',
    'SOLANA_DEVNET',
    'ETH_SEPOLIA',
    'BASE_SEPOLIA',
    'ARBITRUM_SEPOLIA',
    'OPTIMISM_SEPOLIA',
    'POLYGON_AMOY',
    'AVALANCHE_FUJI',
    'GNOSIS_CHIADO',
    'LINEA_SEPOLIA',
    'FANTOM_TESTNET',
    tron,
  ];
}

/// Legacy export for audits — production actionable codes (same as default treasury ops in prod).
const List<String> kTreasuryOpsChainValues = kOnchainActionableProductionCodes;

/// Managed deposit wallets — recommended chain + defaults rows.
/// Includes mainnet so the picker matches [deposit.recommended_chain] even in non-production.
const List<String> kManagedWalletsChainValues = <String>[
  'TRON_MAINNET',
  'TRON_NILE',
  'TRON_SHASTA',
];

/// Payment ops wallets (create / filter): mainnet in production, testnet otherwise.
List<String> treasuryOpsChainsForCurrentEnv() {
  if (treasuryChainsUseMainnetOnly) {
    return List<String>.from(kOnchainActionableProductionCodes);
  }
  return kOnchainActionableSandboxCodes(treasurySandboxDefaultTronChain());
}

/// Treasury history chain filter: same universe as creatable ops wallets so filters match list/search.
List<String> treasuryHistoryFilterChainsForCurrentEnv() =>
    treasuryOpsWalletCreationChainsForCurrentEnv();

/// System **main / hot wallet** picker (`/treasury/main-wallets`): same chain codes and
/// [ONCHAIN_OPERATOR_MODE] / [TRON_DEFAULT_NETWORK] rules as payment config operational wallets.
List<String> treasuryMainWalletChainsForCurrentEnv() =>
    treasuryOpsWalletCreationChainsForCurrentEnv();

/// Withdrawal admin filter chains per environment.
List<String> withdrawalFilterChainsForCurrentEnv() {
  return treasuryOpsChainsForCurrentEnv();
}

/// Managed deposit wallets: mainnet-only in production; mainnet + Tron testnets otherwise.
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

/// Tron testnet used when sandbox UI offers a single "Tron (TRC-20 testnet)" row.
/// Matches backend `TRON_DEFAULT_NETWORK` (TRON_NILE | TRON_SHASTA).
String treasurySandboxDefaultTronChain() {
  if (!dotenv.isInitialized) {
    return 'TRON_NILE';
  }
  final raw = dotenv.env['TRON_DEFAULT_NETWORK']?.trim().toUpperCase();
  if (raw == 'TRON_SHASTA') return 'TRON_SHASTA';
  if (raw == 'TRON_NILE') return 'TRON_NILE';
  return 'TRON_NILE';
}

/// Chains for **POST /treasury/wallets** (create transaction wallet).
///
/// Sandbox: full multichain testnet list (see backend `treasury_ops` picker).
/// Production: mainnet actionable chains.
List<String> treasuryOpsWalletCreationChainsForCurrentEnv() {
  return treasuryOpsChainsForCurrentEnv();
}

/// EVM + Solana networks offered in [LinkWalletDialog] (WalletConnect relay).
///
/// Sandbox / dev: testnets only so the list matches the orange sandbox banner.
/// Production: mainnets only.
List<BlockchainNetwork> walletConnectLinkNetworksForCurrentEnv() {
  final codes = treasuryChainsUseMainnetOnly
      ? kOnchainActionableProductionCodes
      : kOnchainActionableSandboxCodes(treasurySandboxDefaultTronChain());
  return codes
      .where((c) => !c.startsWith('TRON_'))
      .map(BlockchainNetworkX.tryFromApiValue)
      .whereType<BlockchainNetwork>()
      .toList(growable: false);
}

/// Tron rows in [LinkWalletDialog] (Chrome extension — web only).
///
/// Sandbox: single default testnet from [treasurySandboxDefaultTronChain].
/// Production: mainnet only.
List<BlockchainNetwork> tronExtensionLinkNetworksForCurrentEnv() {
  if (treasuryChainsUseMainnetOnly) {
    return const [BlockchainNetwork.tronMainnet];
  }
  switch (treasurySandboxDefaultTronChain()) {
    case 'TRON_SHASTA':
      return const [BlockchainNetwork.tronShasta];
    case 'TRON_NILE':
    default:
      return const [BlockchainNetwork.tronNile];
  }
}

/// Fallback when GET /treasury/chain-picker-options is missing or fails.
///
/// Server should return the same codes under `pickers.onchain_deposit_withdraw`; the app maps
/// those strings to [BlockchainNetwork] via [BlockchainNetworkX.tryFromApiValue].
///
/// Same universe as [walletConnectLinkNetworksForCurrentEnv] plus one Tron (see
/// [tronExtensionLinkNetworksForCurrentEnv]) — no mixing mainnet + testnet in sandbox.
List<BlockchainNetwork> onchainDepositWithdrawNetworksForCurrentEnv() {
  final codes = treasuryChainsUseMainnetOnly
      ? kOnchainActionableProductionCodes
      : kOnchainActionableSandboxCodes(treasurySandboxDefaultTronChain());
  return codes
      .map(BlockchainNetworkX.tryFromApiValue)
      .whereType<BlockchainNetwork>()
      .toList(growable: false);
}

/// Friendly labels for the create-wallet sheet (ecosystem / wallet type), while values stay API enums.
String treasuryWalletCreationDisplayLabel(AppLocalizations l10n, String chain) {
  if (treasuryChainsUseMainnetOnly) {
    return treasuryChainDisplayLabel(l10n, chain);
  }
  switch (chain) {
    case 'TRON_NILE':
    case 'TRON_SHASTA':
      return l10n.treasuryCreateWalletNetworkTronTrc20Testnet;
    case 'SOLANA_DEVNET':
      return l10n.treasuryCreateWalletNetworkSolanaSplDevnet;
    case 'BSC_CHAPEL':
      return l10n.treasuryCreateWalletNetworkBscMetaMaskChapel;
    default:
      return treasuryChainDisplayLabel(l10n, chain);
  }
}

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
    case 'BSC_CHAPEL':
      return l10n.treasuryChainBscTestnet;
    case 'BSC_MAINNET':
      return l10n.treasuryChainBscMainnet;
    case 'SOLANA_DEVNET':
      return l10n.treasuryChainSolanaDevnet;
    case 'SOLANA_MAINNET':
      return l10n.treasuryChainSolanaMainnet;
    case 'ETH_MAINNET':
      return l10n.treasuryChainEthMainnet;
    case 'ETH_SEPOLIA':
      return l10n.treasuryChainEthSepolia;
    case 'BASE_MAINNET':
      return l10n.treasuryChainBaseMainnet;
    case 'BASE_SEPOLIA':
      return l10n.treasuryChainBaseSepolia;
    case 'ARBITRUM_MAINNET':
      return l10n.treasuryChainArbitrumMainnet;
    case 'ARBITRUM_SEPOLIA':
      return l10n.treasuryChainArbitrumSepolia;
    case 'OPTIMISM_MAINNET':
      return l10n.treasuryChainOptimismMainnet;
    case 'OPTIMISM_SEPOLIA':
      return l10n.treasuryChainOptimismSepolia;
    case 'POLYGON_MAINNET':
      return l10n.treasuryChainPolygonMainnet;
    case 'POLYGON_AMOY':
      return l10n.treasuryChainPolygonAmoy;
    case 'AVALANCHE_MAINNET':
      return l10n.treasuryChainAvalancheMainnet;
    case 'AVALANCHE_FUJI':
      return l10n.treasuryChainAvalancheFuji;
    case 'GNOSIS_MAINNET':
      return l10n.treasuryChainGnosisMainnet;
    case 'GNOSIS_CHIADO':
      return l10n.treasuryChainGnosisChiado;
    case 'LINEA_MAINNET':
      return l10n.treasuryChainLineaMainnet;
    case 'LINEA_SEPOLIA':
      return l10n.treasuryChainLineaSepolia;
    case 'FANTOM_MAINNET':
      return l10n.treasuryChainFantomMainnet;
    case 'FANTOM_TESTNET':
      return l10n.treasuryChainFantomTestnet;
    case 'TON_MAINNET':
      return l10n.treasuryChainTonMainnet;
    case 'TON_TESTNET':
      return l10n.treasuryChainTonTestnet;
    default:
      return chain;
  }
}

/// Short badge text for deposit method rows (Latin, readable — avoids truncated API enums).
String depositChainBadgeLabel(String chain) {
  switch (chain.toUpperCase()) {
    case 'TRON_NILE':
      return 'TRON Nile';
    case 'TRON_SHASTA':
      return 'TRON Shasta';
    case 'TRON_MAINNET':
      return 'TRON';
    case 'ETH_MAINNET':
      return 'Ethereum';
    case 'ETH_SEPOLIA':
      return 'Sepolia';
    case 'BSC_MAINNET':
      return 'BNB Chain';
    case 'BSC_CHAPEL':
    case 'BSC_TESTNET':
      return 'BNB Chapel';
    case 'SOLANA_MAINNET':
      return 'Solana';
    case 'SOLANA_DEVNET':
      return 'Solana Devnet';
    case 'BASE_MAINNET':
      return 'Base';
    case 'BASE_SEPOLIA':
      return 'Base Sepolia';
    case 'ARBITRUM_MAINNET':
      return 'Arbitrum';
    case 'ARBITRUM_SEPOLIA':
      return 'Arbitrum Sepolia';
    case 'OPTIMISM_MAINNET':
      return 'Optimism';
    case 'OPTIMISM_SEPOLIA':
      return 'Optimism Sepolia';
    case 'POLYGON_MAINNET':
      return 'Polygon';
    case 'POLYGON_AMOY':
      return 'Polygon Amoy';
    case 'AVALANCHE_MAINNET':
      return 'Avalanche';
    case 'AVALANCHE_FUJI':
      return 'Avalanche Fuji';
    case 'GNOSIS_MAINNET':
      return 'Gnosis';
    case 'GNOSIS_CHIADO':
      return 'Gnosis Chiado';
    case 'LINEA_MAINNET':
      return 'Linea';
    case 'LINEA_SEPOLIA':
      return 'Linea Sepolia';
    case 'FANTOM_MAINNET':
      return 'Fantom';
    case 'FANTOM_TESTNET':
      return 'Fantom Testnet';
    case 'TON_MAINNET':
      return 'TON';
    case 'TON_TESTNET':
      return 'TON testnet';
    default:
      final u = chain.toUpperCase();
      if (u.length <= 12) return u;
      return u.substring(0, 12);
  }
}

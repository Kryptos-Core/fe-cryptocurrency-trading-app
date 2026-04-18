import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

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

/// Actionable chains (single default Tron testnet in sandbox) — mirrors backend
/// [listActionableOnchainChainCodes] / user-facing pickers (`managed_wallets`, …).
List<String> actionableOnchainChainsForCurrentEnv() {
  if (treasuryChainsUseMainnetOnly) {
    return List<String>.from(kOnchainActionableProductionCodes);
  }
  return kOnchainActionableSandboxCodes(treasurySandboxDefaultTronChain());
}

void _appendSandboxAltTron(List<String> base, String defaultTron) {
  final alt = defaultTron == 'TRON_SHASTA' ? 'TRON_NILE' : 'TRON_SHASTA';
  final i = base.indexWhere((c) => c == 'TRON_NILE' || c == 'TRON_SHASTA');
  if (i >= 0 && !base.contains(alt)) {
    base.insert(i + 1, alt);
  }
}

/// Treasury ops create-wallet fallback — sandbox lists **both** Tron testnets (matches backend
/// [listTreasuryOpsChainCodes]).
List<String> treasuryOpsChainsForCurrentEnv() {
  if (treasuryChainsUseMainnetOnly) {
    return List<String>.from(kOnchainActionableProductionCodes);
  }
  final base = List<String>.from(kOnchainActionableSandboxCodes(treasurySandboxDefaultTronChain()));
  _appendSandboxAltTron(base, treasurySandboxDefaultTronChain());
  return base;
}

/// Treasury history chain filter: same universe as creatable ops wallets so filters match list/search.
List<String> treasuryHistoryFilterChainsForCurrentEnv() =>
    treasuryOpsWalletCreationChainsForCurrentEnv();

/// System **main / hot wallet** picker (`/treasury/main-wallets`): same chain codes and
/// [ONCHAIN_OPERATOR_MODE] / [TRON_DEFAULT_NETWORK] rules as payment config operational wallets.
List<String> treasuryMainWalletChainsForCurrentEnv() =>
    treasuryOpsWalletCreationChainsForCurrentEnv();

/// Withdrawal admin filter — matches backend `withdrawal_admin_filter` / actionable list.
List<String> withdrawalFilterChainsForCurrentEnv() => actionableOnchainChainsForCurrentEnv();

/// Managed deposit — matches backend `managed_wallets` / single Tron testnet in sandbox.
List<String> managedWalletsChainsForCurrentEnv() => actionableOnchainChainsForCurrentEnv();

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

/// High-level chain family for treasury ops UI (first dropdown in create-wallet sheet).
enum TreasuryChainEcosystem {
  tron,
  ethereum,
  bsc,
  solana,
  base,
  arbitrum,
  optimism,
  polygon,
  avalanche,
  gnosis,
  linea,
  fantom,
}

TreasuryChainEcosystem ecosystemForChain(String apiCode) {
  final u = apiCode.toUpperCase();
  if (u.startsWith('TRON_')) return TreasuryChainEcosystem.tron;
  if (u.startsWith('ETH_')) return TreasuryChainEcosystem.ethereum;
  if (u.startsWith('BSC_')) return TreasuryChainEcosystem.bsc;
  if (u.startsWith('SOLANA_')) return TreasuryChainEcosystem.solana;
  if (u.startsWith('BASE_')) return TreasuryChainEcosystem.base;
  if (u.startsWith('ARBITRUM_')) return TreasuryChainEcosystem.arbitrum;
  if (u.startsWith('OPTIMISM_')) return TreasuryChainEcosystem.optimism;
  if (u.startsWith('POLYGON_')) return TreasuryChainEcosystem.polygon;
  if (u.startsWith('AVALANCHE_')) return TreasuryChainEcosystem.avalanche;
  if (u.startsWith('GNOSIS_')) return TreasuryChainEcosystem.gnosis;
  if (u.startsWith('LINEA_')) return TreasuryChainEcosystem.linea;
  if (u.startsWith('FANTOM_')) return TreasuryChainEcosystem.fantom;
  throw ArgumentError.value(apiCode, 'apiCode', 'Unknown treasury chain ecosystem');
}

/// Distinct ecosystems in [availableChains], preserving first-seen order.
List<TreasuryChainEcosystem> treasuryOpsEcosystems(List<String> availableChains) {
  final seen = <TreasuryChainEcosystem>{};
  final out = <TreasuryChainEcosystem>[];
  for (final c in availableChains) {
    final e = ecosystemForChain(c);
    if (seen.add(e)) out.add(e);
  }
  return out;
}

bool _treasuryChainLooksMainnet(String code) => code.toUpperCase().contains('MAINNET');

/// Networks for one ecosystem from the picker list; mainnets before testnets, order preserved
/// within each group (matches API list order).
List<String> treasuryOpsNetworksForEcosystem(
  TreasuryChainEcosystem eco,
  List<String> availableChains,
) {
  final filtered = availableChains.where((c) => ecosystemForChain(c) == eco).toList();
  final mainnets = <String>[];
  final testnets = <String>[];
  for (final c in filtered) {
    if (_treasuryChainLooksMainnet(c)) {
      mainnets.add(c);
    } else {
      testnets.add(c);
    }
  }
  return [...mainnets, ...testnets];
}

/// Sandbox Tron: prefer [apiTronDefaultNetwork] from chain-picker-options when listed,
/// else [.env] [treasurySandboxDefaultTronChain].
String? preferredTreasuryOpsNetworkCode(
  TreasuryChainEcosystem eco,
  List<String> networks, {
  String? apiTronDefaultNetwork,
}) {
  if (networks.isEmpty) return null;
  if (!treasuryChainsUseMainnetOnly && eco == TreasuryChainEcosystem.tron) {
    final api = apiTronDefaultNetwork?.trim().toUpperCase();
    if (api != null && api.isNotEmpty) {
      for (final n in networks) {
        if (n.toUpperCase() == api) return n;
      }
    }
    final pref = treasurySandboxDefaultTronChain();
    if (networks.contains(pref)) return pref;
  }
  return networks.first;
}

String treasuryEcosystemLabel(AppLocalizations l10n, TreasuryChainEcosystem eco) {
  switch (eco) {
    case TreasuryChainEcosystem.tron:
      return l10n.treasuryChainEcosystemTron;
    case TreasuryChainEcosystem.ethereum:
      return l10n.treasuryChainEcosystemEthereum;
    case TreasuryChainEcosystem.bsc:
      return l10n.treasuryChainEcosystemBsc;
    case TreasuryChainEcosystem.solana:
      return l10n.treasuryChainEcosystemSolana;
    case TreasuryChainEcosystem.base:
      return l10n.treasuryChainEcosystemBase;
    case TreasuryChainEcosystem.arbitrum:
      return l10n.treasuryChainEcosystemArbitrum;
    case TreasuryChainEcosystem.optimism:
      return l10n.treasuryChainEcosystemOptimism;
    case TreasuryChainEcosystem.polygon:
      return l10n.treasuryChainEcosystemPolygon;
    case TreasuryChainEcosystem.avalanche:
      return l10n.treasuryChainEcosystemAvalanche;
    case TreasuryChainEcosystem.gnosis:
      return l10n.treasuryChainEcosystemGnosis;
    case TreasuryChainEcosystem.linea:
      return l10n.treasuryChainEcosystemLinea;
    case TreasuryChainEcosystem.fantom:
      return l10n.treasuryChainEcosystemFantom;
  }
}

/// EVM + Solana networks offered in [LinkWalletDialog] (WalletConnect relay).
///
/// Sandbox / dev: testnets only so the list matches the orange sandbox banner.
/// Production: mainnets only.
List<BlockchainNetwork> walletConnectLinkNetworksForCurrentEnv() {
  final codes = actionableOnchainChainsForCurrentEnv();
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
  final codes = actionableOnchainChainsForCurrentEnv();
  return codes
      .map(BlockchainNetworkX.tryFromApiValue)
      .whereType<BlockchainNetwork>()
      .toList(growable: false);
}

/// Default network for the on-chain deposit form.
///
/// Sandbox [kOnchainActionableSandboxCodes] lists EVM/Solana before Tron, but managed
/// deposit addresses are often configured for the default Tron testnet first — pre-select
/// Tron when present so `/blockchain/deposit/address` succeeds on tab open.
///
/// Production: keep API/env order ([kOnchainActionableProductionCodes] first entry).
BlockchainNetwork preferredOnchainDepositWithdrawNetwork(
  List<BlockchainNetwork> networks,
) {
  if (networks.isEmpty) {
    throw ArgumentError.value(networks, 'networks', 'must not be empty');
  }
  if (!treasuryChainsUseMainnetOnly) {
    for (final n in networks) {
      if (n.apiValue.toUpperCase().startsWith('TRON_')) return n;
    }
  }
  return networks.first;
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

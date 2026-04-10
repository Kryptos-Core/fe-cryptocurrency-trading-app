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

const Set<String> _kTreasuryOpsMainnetChains = <String>{
  'TRON_MAINNET',
  'ETH_MAINNET',
};

/// Payment config → operational treasury wallets (create / filter).
const List<String> kTreasuryOpsChainValues = <String>[
  'TRON_NILE',
  'TRON_SHASTA',
  'TRON_MAINNET',
  'ETH_MAINNET',
];

/// Withdrawal admin list filter.
const List<String> kWithdrawalFilterChainValues = <String>[
  'TRON_NILE',
  'TRON_SHASTA',
  'SOLANA_DEVNET',
  'BSC_CHAPEL',
];

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
    return kTreasuryOpsChainValues
        .where(_kTreasuryOpsMainnetChains.contains)
        .toList(growable: false);
  }
  return kTreasuryOpsChainValues
      .where((c) => !_kTreasuryOpsMainnetChains.contains(c))
      .toList(growable: false);
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
  if (treasuryChainsUseMainnetOnly) {
    return const <String>[
      'TRON_MAINNET',
      'ETH_MAINNET',
      'SOLANA_MAINNET',
    ];
  }
  return kWithdrawalFilterChainValues;
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
/// Sandbox: one Tron testnet (see [treasurySandboxDefaultTronChain]) + Solana devnet + BSC Chapel
/// (EVM/MetaMask testnet). Same API codes as [CreateTransactionWalletDto].
/// Production: unchanged ([treasuryOpsChainsForCurrentEnv]).
List<String> treasuryOpsWalletCreationChainsForCurrentEnv() {
  if (treasuryChainsUseMainnetOnly) {
    return treasuryOpsChainsForCurrentEnv();
  }
  return <String>[
    treasurySandboxDefaultTronChain(),
    'SOLANA_DEVNET',
    'BSC_CHAPEL',
  ];
}

/// EVM + Solana networks offered in [LinkWalletDialog] (WalletConnect relay).
///
/// Sandbox / dev: testnets only so the list matches the orange sandbox banner.
/// Production: mainnets only.
List<BlockchainNetwork> walletConnectLinkNetworksForCurrentEnv() {
  if (treasuryChainsUseMainnetOnly) {
    return const [
      BlockchainNetwork.ethMainnet,
      BlockchainNetwork.bscMainnet,
      BlockchainNetwork.solanaMainnet,
    ];
  }
  return const [
    BlockchainNetwork.bscChapel,
    BlockchainNetwork.solanaDevnet,
  ];
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
  if (treasuryChainsUseMainnetOnly) {
    return const [
      BlockchainNetwork.ethMainnet,
      BlockchainNetwork.bscMainnet,
      BlockchainNetwork.solanaMainnet,
      BlockchainNetwork.tronMainnet,
    ];
  }
  return [
    ...walletConnectLinkNetworksForCurrentEnv(),
    ...tronExtensionLinkNetworksForCurrentEnv(),
  ];
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
    default:
      return chain;
  }
}

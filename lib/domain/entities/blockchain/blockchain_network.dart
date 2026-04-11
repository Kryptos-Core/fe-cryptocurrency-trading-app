/// On-chain networks — API string values must match backend [BlockchainNetwork] enum.
enum BlockchainNetwork {
  tronMainnet,
  tronNile,
  tronShasta,
  solanaMainnet,
  solanaDevnet,
  ethMainnet,
  ethSepolia,
  bscMainnet,
  bscChapel,
  baseMainnet,
  baseSepolia,
  arbitrumMainnet,
  arbitrumSepolia,
  optimismMainnet,
  optimismSepolia,
  polygonMainnet,
  polygonAmoy,
  avalancheMainnet,
  avalancheFuji,
  gnosisMainnet,
  gnosisChiado,
  lineaMainnet,
  lineaSepolia,
  fantomMainnet,
  fantomTestnet,
  tonMainnet,
  tonTestnet,
}

/// UI grouping: pick family + read deployment mode from env / public config to resolve concrete chain.
enum OnChainNetworkFamily { tron, evmEth, evmBsc, solana, ton }

enum OnChainOperatorMode { production, sandbox }

/// Đọc từ map env (ví dụ [dotenv.env]). Khớp BE `ONCHAIN_OPERATOR_MODE`: `sandbox` | còn lại → production.
OnChainOperatorMode parseOnChainOperatorMode(Map<String, String>? env) {
  final raw = env?['ONCHAIN_OPERATOR_MODE']?.trim().toLowerCase();
  if (raw == 'sandbox') {
    return OnChainOperatorMode.sandbox;
  }
  return OnChainOperatorMode.production;
}

/// Nhãn ChoiceChip / filter mạng: thêm `(sandboxShort)` khi [BlockchainNetwork.isSandbox].
///
/// Dùng khi **không** có banner sandbox cùng màn (ví dụ dialog liên kết ví).
String onchainNetworkFilterChipLabel(
  BlockchainNetwork network,
  String sandboxShortL10n,
) {
  if (!network.isSandbox) {
    return network.label;
  }
  return '${network.label} ($sandboxShortL10n)';
}

/// Nhãn chip lọc mạng trên màn nạp/rút: chỉ [BlockchainNetwork.label] — tránh lặp
/// “(Sandbox)” khi đã có [OnchainSandboxOperatorBanner] phía trên.
String onchainRecentTxNetworkChipLabel(BlockchainNetwork network) => network.label;

extension BlockchainNetworkX on BlockchainNetwork {
  String get apiValue {
    switch (this) {
      case BlockchainNetwork.tronMainnet:
        return 'TRON_MAINNET';
      case BlockchainNetwork.tronNile:
        return 'TRON_NILE';
      case BlockchainNetwork.tronShasta:
        return 'TRON_SHASTA';
      case BlockchainNetwork.solanaMainnet:
        return 'SOLANA_MAINNET';
      case BlockchainNetwork.solanaDevnet:
        return 'SOLANA_DEVNET';
      case BlockchainNetwork.ethMainnet:
        return 'ETH_MAINNET';
      case BlockchainNetwork.ethSepolia:
        return 'ETH_SEPOLIA';
      case BlockchainNetwork.bscMainnet:
        return 'BSC_MAINNET';
      case BlockchainNetwork.bscChapel:
        return 'BSC_CHAPEL';
      case BlockchainNetwork.baseMainnet:
        return 'BASE_MAINNET';
      case BlockchainNetwork.baseSepolia:
        return 'BASE_SEPOLIA';
      case BlockchainNetwork.arbitrumMainnet:
        return 'ARBITRUM_MAINNET';
      case BlockchainNetwork.arbitrumSepolia:
        return 'ARBITRUM_SEPOLIA';
      case BlockchainNetwork.optimismMainnet:
        return 'OPTIMISM_MAINNET';
      case BlockchainNetwork.optimismSepolia:
        return 'OPTIMISM_SEPOLIA';
      case BlockchainNetwork.polygonMainnet:
        return 'POLYGON_MAINNET';
      case BlockchainNetwork.polygonAmoy:
        return 'POLYGON_AMOY';
      case BlockchainNetwork.avalancheMainnet:
        return 'AVALANCHE_MAINNET';
      case BlockchainNetwork.avalancheFuji:
        return 'AVALANCHE_FUJI';
      case BlockchainNetwork.gnosisMainnet:
        return 'GNOSIS_MAINNET';
      case BlockchainNetwork.gnosisChiado:
        return 'GNOSIS_CHIADO';
      case BlockchainNetwork.lineaMainnet:
        return 'LINEA_MAINNET';
      case BlockchainNetwork.lineaSepolia:
        return 'LINEA_SEPOLIA';
      case BlockchainNetwork.fantomMainnet:
        return 'FANTOM_MAINNET';
      case BlockchainNetwork.fantomTestnet:
        return 'FANTOM_TESTNET';
      case BlockchainNetwork.tonMainnet:
        return 'TON_MAINNET';
      case BlockchainNetwork.tonTestnet:
        return 'TON_TESTNET';
    }
  }

  String get label {
    switch (this) {
      case BlockchainNetwork.tronMainnet:
        return 'Tron (mainnet)';
      case BlockchainNetwork.tronNile:
        return 'Tron (Nile)';
      case BlockchainNetwork.tronShasta:
        return 'Tron (Shasta)';
      case BlockchainNetwork.solanaMainnet:
        return 'Solana (mainnet)';
      case BlockchainNetwork.solanaDevnet:
        return 'Solana (devnet)';
      case BlockchainNetwork.ethMainnet:
        return 'Ethereum (mainnet)';
      case BlockchainNetwork.ethSepolia:
        return 'Ethereum (Sepolia)';
      case BlockchainNetwork.bscMainnet:
        return 'BNB Smart Chain (mainnet)';
      case BlockchainNetwork.bscChapel:
        return 'BNB Smart Chain (Chapel)';
      case BlockchainNetwork.baseMainnet:
        return 'Base (mainnet)';
      case BlockchainNetwork.baseSepolia:
        return 'Base (Sepolia)';
      case BlockchainNetwork.arbitrumMainnet:
        return 'Arbitrum One';
      case BlockchainNetwork.arbitrumSepolia:
        return 'Arbitrum Sepolia';
      case BlockchainNetwork.optimismMainnet:
        return 'Optimism (mainnet)';
      case BlockchainNetwork.optimismSepolia:
        return 'Optimism Sepolia';
      case BlockchainNetwork.polygonMainnet:
        return 'Polygon (mainnet)';
      case BlockchainNetwork.polygonAmoy:
        return 'Polygon Amoy';
      case BlockchainNetwork.avalancheMainnet:
        return 'Avalanche C-Chain';
      case BlockchainNetwork.avalancheFuji:
        return 'Avalanche Fuji';
      case BlockchainNetwork.gnosisMainnet:
        return 'Gnosis Chain';
      case BlockchainNetwork.gnosisChiado:
        return 'Gnosis Chiado';
      case BlockchainNetwork.lineaMainnet:
        return 'Linea (mainnet)';
      case BlockchainNetwork.lineaSepolia:
        return 'Linea Sepolia';
      case BlockchainNetwork.fantomMainnet:
        return 'Fantom (mainnet)';
      case BlockchainNetwork.fantomTestnet:
        return 'Fantom (testnet)';
      case BlockchainNetwork.tonMainnet:
        return 'TON (mainnet)';
      case BlockchainNetwork.tonTestnet:
        return 'TON (testnet)';
    }
  }

  /// Native coin symbol for UI hints.
  String get nativeSymbol {
    switch (this) {
      case BlockchainNetwork.tronMainnet:
      case BlockchainNetwork.tronNile:
      case BlockchainNetwork.tronShasta:
        return 'TRX';
      case BlockchainNetwork.solanaMainnet:
      case BlockchainNetwork.solanaDevnet:
        return 'SOL';
      case BlockchainNetwork.ethMainnet:
      case BlockchainNetwork.ethSepolia:
      case BlockchainNetwork.baseMainnet:
      case BlockchainNetwork.baseSepolia:
      case BlockchainNetwork.arbitrumMainnet:
      case BlockchainNetwork.arbitrumSepolia:
      case BlockchainNetwork.optimismMainnet:
      case BlockchainNetwork.optimismSepolia:
      case BlockchainNetwork.lineaMainnet:
      case BlockchainNetwork.lineaSepolia:
        return 'ETH';
      case BlockchainNetwork.bscMainnet:
      case BlockchainNetwork.bscChapel:
        return 'BNB';
      case BlockchainNetwork.polygonMainnet:
      case BlockchainNetwork.polygonAmoy:
        return 'POL';
      case BlockchainNetwork.avalancheMainnet:
      case BlockchainNetwork.avalancheFuji:
        return 'AVAX';
      case BlockchainNetwork.gnosisMainnet:
      case BlockchainNetwork.gnosisChiado:
        return 'XDAI';
      case BlockchainNetwork.fantomMainnet:
      case BlockchainNetwork.fantomTestnet:
        return 'FTM';
      case BlockchainNetwork.tonMainnet:
      case BlockchainNetwork.tonTestnet:
        return 'TON';
    }
  }

  bool get isSandbox {
    switch (this) {
      case BlockchainNetwork.tronNile:
      case BlockchainNetwork.tronShasta:
      case BlockchainNetwork.solanaDevnet:
      case BlockchainNetwork.bscChapel:
      case BlockchainNetwork.ethSepolia:
      case BlockchainNetwork.baseSepolia:
      case BlockchainNetwork.arbitrumSepolia:
      case BlockchainNetwork.optimismSepolia:
      case BlockchainNetwork.polygonAmoy:
      case BlockchainNetwork.avalancheFuji:
      case BlockchainNetwork.gnosisChiado:
      case BlockchainNetwork.lineaSepolia:
      case BlockchainNetwork.fantomTestnet:
      case BlockchainNetwork.tonTestnet:
        return true;
      default:
        return false;
    }
  }

  bool get isTronFamily {
    switch (this) {
      case BlockchainNetwork.tronMainnet:
      case BlockchainNetwork.tronNile:
      case BlockchainNetwork.tronShasta:
        return true;
      default:
        return false;
    }
  }

  /// CAIP-2 cho EVM (WalletConnect / Reown). Null với Tron / Solana / TON.
  String? get evmCaip2 {
    switch (this) {
      case BlockchainNetwork.ethMainnet:
        return 'eip155:1';
      case BlockchainNetwork.ethSepolia:
        return 'eip155:11155111';
      case BlockchainNetwork.bscMainnet:
        return 'eip155:56';
      case BlockchainNetwork.bscChapel:
        return 'eip155:97';
      case BlockchainNetwork.baseMainnet:
        return 'eip155:8453';
      case BlockchainNetwork.baseSepolia:
        return 'eip155:84532';
      case BlockchainNetwork.arbitrumMainnet:
        return 'eip155:42161';
      case BlockchainNetwork.arbitrumSepolia:
        return 'eip155:421614';
      case BlockchainNetwork.optimismMainnet:
        return 'eip155:10';
      case BlockchainNetwork.optimismSepolia:
        return 'eip155:11155420';
      case BlockchainNetwork.polygonMainnet:
        return 'eip155:137';
      case BlockchainNetwork.polygonAmoy:
        return 'eip155:80002';
      case BlockchainNetwork.avalancheMainnet:
        return 'eip155:43114';
      case BlockchainNetwork.avalancheFuji:
        return 'eip155:43113';
      case BlockchainNetwork.gnosisMainnet:
        return 'eip155:100';
      case BlockchainNetwork.gnosisChiado:
        return 'eip155:10200';
      case BlockchainNetwork.lineaMainnet:
        return 'eip155:59144';
      case BlockchainNetwork.lineaSepolia:
        return 'eip155:59141';
      case BlockchainNetwork.fantomMainnet:
        return 'eip155:250';
      case BlockchainNetwork.fantomTestnet:
        return 'eip155:4002';
      default:
        return null;
    }
  }

  OnChainNetworkFamily get networkFamily {
    switch (this) {
      case BlockchainNetwork.tronMainnet:
      case BlockchainNetwork.tronNile:
      case BlockchainNetwork.tronShasta:
        return OnChainNetworkFamily.tron;
      case BlockchainNetwork.bscMainnet:
      case BlockchainNetwork.bscChapel:
        return OnChainNetworkFamily.evmBsc;
      case BlockchainNetwork.solanaMainnet:
      case BlockchainNetwork.solanaDevnet:
        return OnChainNetworkFamily.solana;
      case BlockchainNetwork.tonMainnet:
      case BlockchainNetwork.tonTestnet:
        return OnChainNetworkFamily.ton;
      default:
        return OnChainNetworkFamily.evmEth;
    }
  }

  /// Maps operator family + deployment mode to concrete chain (same table as Nest `resolveBlockchainNetwork`).
  static BlockchainNetwork resolveForFamily(
    OnChainNetworkFamily family,
    OnChainOperatorMode mode,
  ) {
    final sandbox = mode == OnChainOperatorMode.sandbox;
    switch (family) {
      case OnChainNetworkFamily.tron:
        return sandbox ? BlockchainNetwork.tronNile : BlockchainNetwork.tronMainnet;
      case OnChainNetworkFamily.evmEth:
        return sandbox ? BlockchainNetwork.bscChapel : BlockchainNetwork.ethMainnet;
      case OnChainNetworkFamily.evmBsc:
        return sandbox ? BlockchainNetwork.bscChapel : BlockchainNetwork.bscMainnet;
      case OnChainNetworkFamily.solana:
        return sandbox ? BlockchainNetwork.solanaDevnet : BlockchainNetwork.solanaMainnet;
      case OnChainNetworkFamily.ton:
        return sandbox ? BlockchainNetwork.tonTestnet : BlockchainNetwork.tonMainnet;
    }
  }

  /// Map CAIP-2 EVM (ví dụ `eip155:1`) sang enum; null nếu không hỗ trợ.
  static BlockchainNetwork? tryFromEvmCaip2(String? caip2) {
    if (caip2 == null || caip2.isEmpty) return null;
    switch (caip2) {
      case 'eip155:1':
        return BlockchainNetwork.ethMainnet;
      case 'eip155:11155111':
        return BlockchainNetwork.ethSepolia;
      case 'eip155:56':
        return BlockchainNetwork.bscMainnet;
      case 'eip155:97':
        return BlockchainNetwork.bscChapel;
      case 'eip155:8453':
        return BlockchainNetwork.baseMainnet;
      case 'eip155:84532':
        return BlockchainNetwork.baseSepolia;
      case 'eip155:42161':
        return BlockchainNetwork.arbitrumMainnet;
      case 'eip155:421614':
        return BlockchainNetwork.arbitrumSepolia;
      case 'eip155:10':
        return BlockchainNetwork.optimismMainnet;
      case 'eip155:11155420':
        return BlockchainNetwork.optimismSepolia;
      case 'eip155:137':
        return BlockchainNetwork.polygonMainnet;
      case 'eip155:80002':
        return BlockchainNetwork.polygonAmoy;
      case 'eip155:43114':
        return BlockchainNetwork.avalancheMainnet;
      case 'eip155:43113':
        return BlockchainNetwork.avalancheFuji;
      case 'eip155:100':
        return BlockchainNetwork.gnosisMainnet;
      case 'eip155:10200':
        return BlockchainNetwork.gnosisChiado;
      case 'eip155:59144':
        return BlockchainNetwork.lineaMainnet;
      case 'eip155:59141':
        return BlockchainNetwork.lineaSepolia;
      case 'eip155:250':
        return BlockchainNetwork.fantomMainnet;
      case 'eip155:4002':
        return BlockchainNetwork.fantomTestnet;
      default:
        return null;
    }
  }

  static BlockchainNetwork? tryFromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'TRON_MAINNET':
        return BlockchainNetwork.tronMainnet;
      case 'TRON_NILE':
        return BlockchainNetwork.tronNile;
      case 'TRON_SHASTA':
        return BlockchainNetwork.tronShasta;
      case 'SOLANA_MAINNET':
        return BlockchainNetwork.solanaMainnet;
      case 'SOLANA_DEVNET':
        return BlockchainNetwork.solanaDevnet;
      case 'ETH_MAINNET':
        return BlockchainNetwork.ethMainnet;
      case 'ETH_SEPOLIA':
        return BlockchainNetwork.ethSepolia;
      case 'BSC_MAINNET':
        return BlockchainNetwork.bscMainnet;
      case 'BSC_CHAPEL':
        return BlockchainNetwork.bscChapel;
      case 'BASE_MAINNET':
        return BlockchainNetwork.baseMainnet;
      case 'BASE_SEPOLIA':
        return BlockchainNetwork.baseSepolia;
      case 'ARBITRUM_MAINNET':
        return BlockchainNetwork.arbitrumMainnet;
      case 'ARBITRUM_SEPOLIA':
        return BlockchainNetwork.arbitrumSepolia;
      case 'OPTIMISM_MAINNET':
        return BlockchainNetwork.optimismMainnet;
      case 'OPTIMISM_SEPOLIA':
        return BlockchainNetwork.optimismSepolia;
      case 'POLYGON_MAINNET':
        return BlockchainNetwork.polygonMainnet;
      case 'POLYGON_AMOY':
        return BlockchainNetwork.polygonAmoy;
      case 'AVALANCHE_MAINNET':
        return BlockchainNetwork.avalancheMainnet;
      case 'AVALANCHE_FUJI':
        return BlockchainNetwork.avalancheFuji;
      case 'GNOSIS_MAINNET':
        return BlockchainNetwork.gnosisMainnet;
      case 'GNOSIS_CHIADO':
        return BlockchainNetwork.gnosisChiado;
      case 'LINEA_MAINNET':
        return BlockchainNetwork.lineaMainnet;
      case 'LINEA_SEPOLIA':
        return BlockchainNetwork.lineaSepolia;
      case 'FANTOM_MAINNET':
        return BlockchainNetwork.fantomMainnet;
      case 'FANTOM_TESTNET':
        return BlockchainNetwork.fantomTestnet;
      case 'TON_MAINNET':
        return BlockchainNetwork.tonMainnet;
      case 'TON_TESTNET':
        return BlockchainNetwork.tonTestnet;
      default:
        return null;
    }
  }

  static BlockchainNetwork fromApiValue(String value) {
    final resolved = tryFromApiValue(value);
    if (resolved == null) {
      throw ArgumentError('Unsupported blockchain network: $value');
    }
    return resolved;
  }
}

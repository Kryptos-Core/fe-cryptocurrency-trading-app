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
}

/// UI grouping: pick family + read deployment mode from env / public config to resolve concrete chain.
enum OnChainNetworkFamily { tron, evmEth, evmBsc, solana }

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
String onchainNetworkFilterChipLabel(
  BlockchainNetwork network,
  String sandboxShortL10n,
) {
  if (!network.isSandbox) {
    return network.label;
  }
  return '${network.label} ($sandboxShortL10n)';
}

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
        return 'BSC (mainnet)';
      case BlockchainNetwork.bscChapel:
        return 'BSC (Chapel)';
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
        return 'ETH';
      case BlockchainNetwork.bscMainnet:
      case BlockchainNetwork.bscChapel:
        return 'BNB';
    }
  }

  bool get isSandbox {
    switch (this) {
      case BlockchainNetwork.tronNile:
      case BlockchainNetwork.tronShasta:
      case BlockchainNetwork.solanaDevnet:
      case BlockchainNetwork.ethSepolia:
      case BlockchainNetwork.bscChapel:
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

  /// CAIP-2 cho EVM (WalletConnect / Reown). Null với Tron / Solana.
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
      case BlockchainNetwork.ethMainnet:
      case BlockchainNetwork.ethSepolia:
        return OnChainNetworkFamily.evmEth;
      case BlockchainNetwork.bscMainnet:
      case BlockchainNetwork.bscChapel:
        return OnChainNetworkFamily.evmBsc;
      case BlockchainNetwork.solanaMainnet:
      case BlockchainNetwork.solanaDevnet:
        return OnChainNetworkFamily.solana;
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
        return sandbox ? BlockchainNetwork.ethSepolia : BlockchainNetwork.ethMainnet;
      case OnChainNetworkFamily.evmBsc:
        return sandbox ? BlockchainNetwork.bscChapel : BlockchainNetwork.bscMainnet;
      case OnChainNetworkFamily.solana:
        return sandbox ? BlockchainNetwork.solanaDevnet : BlockchainNetwork.solanaMainnet;
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
      default:
        return null;
    }
  }

  static BlockchainNetwork fromApiValue(String value) {
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
      default:
        throw ArgumentError('Unsupported blockchain network: $value');
    }
  }
}
